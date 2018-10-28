//
//  MJClangTool.m
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/17.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJClangTool.h"
#import "clang-c/Index.h"
#import "NSFileManager+Extension.h"
#import "NSString+Extension.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "HGJunkCodeClientData.h"

/** 类名、方法名 */
@interface MJTokensClientData : NSObject
@property (nonatomic, strong) NSArray *prefixes;
@property (nonatomic, strong) NSMutableSet *tokens;
@property (nonatomic, copy) NSString *file;
@end

@implementation MJTokensClientData
@end

/** 字符串 */
@interface MJStringsClientData : NSObject
@property (nonatomic, strong) NSMutableSet *strings;
@property (nonatomic, copy) NSString *file;
@end

@implementation MJStringsClientData
@end

@implementation MJClangTool

static const char *_getFilename(CXCursor cursor) {
    CXSourceRange range = clang_getCursorExtent(cursor);
    CXSourceLocation location = clang_getRangeStart(range);
    CXFile file;
    clang_getFileLocation(location, &file, NULL, NULL, NULL);
    return clang_getCString(clang_getFileName(file));
}

static const char *_getCursorName(CXCursor cursor) {
    return clang_getCString(clang_getCursorSpelling(cursor));
}

static bool _isFromFile(const char *filepath, CXCursor cursor) {
    if (filepath == NULL) return 0;
    const char *cursorPath = _getFilename(cursor);
    if (cursorPath == NULL) return 0;
    return strstr(cursorPath, filepath) != NULL;
}

enum CXChildVisitResult _visitTokens(CXCursor cursor,
                                      CXCursor parent,
                                      CXClientData clientData) {
    if (clientData == NULL) return CXChildVisit_Break;
    
    MJTokensClientData *data = (__bridge MJTokensClientData *)clientData;
    if (!_isFromFile(data.file.UTF8String, cursor)) return CXChildVisit_Continue;
    
    if (cursor.kind == CXCursor_ObjCInstanceMethodDecl ||
        cursor.kind == CXCursor_ObjCClassMethodDecl ||
        cursor.kind == CXCursor_ObjCImplementationDecl) {
        NSString *name = [NSString stringWithUTF8String:_getCursorName(cursor)];
        NSArray *tokens = [name componentsSeparatedByString:@":"];
        
        // 前缀过滤
        for (NSString *token in tokens) {
            for (NSString *prefix in data.prefixes) {
                if ([token rangeOfString:prefix].location == 0) {
                    [data.tokens addObject:token];
                }
            }
        }
    }
    
    return CXChildVisit_Recurse;
}

// 花指令
enum CXChildVisitResult _visitJunkCodes(CXCursor cursor,
                                        CXCursor parent,
                                        CXClientData clientData) {
    if (clientData == NULL) return CXChildVisit_Break;
    
    HGJunkCodeClientData *data = (__bridge HGJunkCodeClientData *)clientData;
    if (!_isFromFile(data.file.UTF8String, cursor)) return CXChildVisit_Continue;
    
    // 仅仅是这些种类的节点才进行花指令处理
    if (cursor.kind == CXCursor_ObjCImplementationDecl ||
        cursor.kind == CXCursor_ObjCInstanceMethodDecl ||
        cursor.kind == CXCursor_ObjCClassMethodDecl ||
        cursor.kind ==  CXCursor_ObjCPropertyDecl ||
        cursor.kind == CXCursor_ObjCIvarDecl) {
        
        // 肯定是英文的不用转
        NSString *name = [NSString stringWithUTF8String:_getCursorName(cursor)];
        // 为了找到插入代码的那一行
        CXSourceRange range = clang_getCursorExtent(cursor);
        CXSourceLocation startLocation = clang_getRangeStart(range);
        CXSourceLocation endLocation = clang_getRangeEnd(range);
        
        // 偏移量
        unsigned startOffset;
        unsigned endOffset;
        clang_getFileLocation(startLocation, NULL, NULL, NULL, &startOffset);
        clang_getSpellingLocation(endLocation, NULL, NULL, NULL, &endOffset);
        // 当前节点的内容描述
        NSData* fileData = [data.fileData subdataWithRange:NSMakeRange(startOffset, endOffset-startOffset)];
        NSString* declString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        
        // 节点
        HGJunkCodeClientNode* node = [HGJunkCodeClientNode new];
        
        if (cursor.kind == CXCursor_ObjCImplementationDecl) {
            // 会找到 name 第一次出现的位置
            NSRange implDeclRang = [declString rangeOfString:name];
            // 在 startOffset ~ startOffset+implDeclRang.location+implDeclRang.length; 的这个区间不可能出现非英文字符
            // 所以正确的位置就是: startOffset+implDeclRang.location+implDeclRang.length;
            node.offset = (unsigned)(startOffset+implDeclRang.location+implDeclRang.length);
            node.jcType = HGJCTypeImplementationDecl;
        } else if (cursor.kind == CXCursor_ObjCInstanceMethodDecl || cursor.kind == CXCursor_ObjCClassMethodDecl) {
            // 会找到 { 第一次出现的位置
            NSRange methodRang = [declString rangeOfString:@"{"];
            // 如果是属性没有重写 setter | getter 的情况, 会出现找不到的情况
            if (methodRang.location != NSNotFound) {
                node.offset = (unsigned)(startOffset+methodRang.location+methodRang.length);
                node.jcType = (cursor.kind == CXCursor_ObjCInstanceMethodDecl)?HGJCTypeInstanceMethodDecl:HGJCTypeClassMethodDecl;
            }
        } else if (cursor.kind ==  CXCursor_ObjCPropertyDecl || cursor.kind == CXCursor_ObjCIvarDecl) {
            fileData = [data.fileData subdataWithRange:NSMakeRange(startOffset, data.file_int_data_length-startOffset)];
            NSString* declString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            
            // 会找到 ; 第一次出现的位置
            NSRange maohaoRang = [declString rangeOfString:@";"];
            node.offset = (unsigned)(startOffset+maohaoRang.location+maohaoRang.length);
            node.jcType = (cursor.kind ==  CXCursor_ObjCPropertyDecl)?HGJCTypePropertyDecl:HGJCTypeIvarDecl;
            
            { // 上面的 declString 主要是为了找到对应的 ;, 接下来的主要是为了记录
                fileData = [data.fileData subdataWithRange:NSMakeRange(startOffset, endOffset-startOffset)];
                declString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
                node.declString = declString;
            }
        }
        
        if ((node.offset != NSNotFound) || !name) {
            node.name = name;
            [data.nodes addObject:node];
            
            // 每个成员变量与属性对应一个垃圾节点
            if ((node.jcType == HGJCTypePropertyDecl) || (node.jcType == HGJCTypeIvarDecl)) {
                NSString* obfuscation = nil;
                while (!obfuscation || [data.obfuscations containsObject:obfuscation]) {
                    obfuscation = [NSString mj_randomStringWithoutDigitalWithLength:10];
                }
                [data.obfuscations addObject:obfuscation];
            }
        }
    }
    
    return CXChildVisit_Recurse;
}

enum CXChildVisitResult _visitStrings(CXCursor cursor,
                                      CXCursor parent,
                                      CXClientData clientData) {
    if (clientData == NULL) return CXChildVisit_Break;
    
    MJStringsClientData *data = (__bridge MJStringsClientData *)clientData;
    if (!_isFromFile(data.file.UTF8String, cursor)) return CXChildVisit_Continue;
    
    if (cursor.kind == CXCursor_StringLiteral) {
        const char *name = _getCursorName(cursor);
        NSString *js = [NSString stringWithFormat:@"decodeURIComponent(escape(%s))", name];
        NSString *string = [[[JSContext alloc] init] evaluateScript:js].toString;
        [data.strings addObject:string];
    }

    return CXChildVisit_Recurse;
}

+ (NSSet *)stringsWithFile:(NSString *)file
                searchPath:(NSString *)searchPath
{
    MJStringsClientData *data = [[MJStringsClientData alloc] init];
    data.file = file;
    data.strings = [NSMutableSet set];
    [self _visitASTWithFile:file
                 searchPath:searchPath
                    visitor:_visitStrings
                 clientData:(__bridge void *)data];
    return data.strings;
}

+ (NSSet *)classesAndMethodsWithFile:(NSString *)file
                            prefixes:(NSArray *)prefixes
                          searchPath:(NSString *)searchPath
{
    MJTokensClientData *data = [[MJTokensClientData alloc] init];
    data.file = file;
    data.prefixes = prefixes;
    data.tokens = [NSMutableSet set];
    [self _visitASTWithFile:file
                 searchPath:searchPath
                    visitor:_visitTokens
                 clientData:(__bridge void *)data];
    return data.tokens;
}

/** 花指令 */
+ (BOOL)junkCodeWithFile:(NSString *)file
                prefixes:(NSArray *)prefixes
              searchPath:(NSString *)searchPath {
    HGJunkCodeClientData* data = [HGJunkCodeClientData new];
    data.file = file;
    data.prefixes = prefixes;
    data.nodes = [NSMutableArray array];
    [self _visitASTWithFile:file
                 searchPath:searchPath
                    visitor:_visitJunkCodes
                 clientData:(__bridge void *)data];
    
    return [data updateContent];
}

/** 遍历某个文件的语法树 */
+ (void)_visitASTWithFile:(NSString *)file
               searchPath:(NSString *)searchPath
                  visitor:(CXCursorVisitor)visitor
               clientData:(CXClientData)clientData
{
    if (file.length == 0) return;
    
    // 文件路径
    const char *filepath = file.UTF8String;
    
    // 创建index
    CXIndex index = clang_createIndex(1, 1);
    
    // 搜索路径
    int argCount = 5;
    NSArray *subDirs = nil;
    if (searchPath.length) {
        subDirs = [NSFileManager mj_subdirsAtPath:searchPath];
        argCount += ((int)subDirs.count + 1) * 2;
    }
    
    int argIndex = 0;
    const char **args = malloc(sizeof(char *) * argCount);
    args[argIndex++] = "-c";
    args[argIndex++] = "-arch";
    args[argIndex++] = "i386";
    args[argIndex++] = "-isysroot";
    args[argIndex++] = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk";
    if (searchPath.length) {
        args[argIndex++] = "-I";
        args[argIndex++] = searchPath.UTF8String;
    }
    for (NSString *subDir in subDirs) {
        args[argIndex++] = "-I";
        args[argIndex++] = subDir.UTF8String;
    }
    
    // 解析语法树，返回根节点TranslationUnit
    CXTranslationUnit tu = clang_parseTranslationUnit(index, filepath,
                                                      args,
                                                      argCount,
                                                      NULL, 0, CXTranslationUnit_None);
    free(args);
    
    if (!tu) return;
    
    // 解析语法树
    clang_visitChildren(clang_getTranslationUnitCursor(tu),
                        visitor, clientData);
    
    // 销毁
    clang_disposeTranslationUnit(tu);
    clang_disposeIndex(index);
}

@end
