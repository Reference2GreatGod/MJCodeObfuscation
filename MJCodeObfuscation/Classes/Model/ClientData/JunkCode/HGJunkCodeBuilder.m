//
//  HGJunkCodeBuilder.m
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "HGJunkCodeBuilder.h"
#import "NSArray+Extension.h"
#import "NSString+Extension.h"

#define HGSelString  @"#selString#"
#define HGMethodType @"#MethodType#"
#define HGIvar       @"#ivar#"
#define HGIvarValue  @"#ivarValue#"

@implementation HGJunkCodeBuilder

/** 随机生成 类方法 & 实例方法 */
+ (NSArray*)hg_randomMethodWithDeclMethod:(HGDeclMethod)declMethod {
    return [self hg_randomMethodWithDeclMethod:declMethod length:5];
}

/** 随机生成 类方法 & 实例方法 */
+ (NSArray*)hg_randomMethodWithDeclMethod:(HGDeclMethod)declMethod length:(NSInteger)length {
    // 生成的随机字符串
    NSArray* randomArr = [NSArray hg_randomListWithLength:length];
    // 记录生成的所有方法
    NSMutableArray* declDataArrM = [NSMutableArray array];
    
    // 生成简单的随机模板方法 没有参数, 可以适当的添加参数
    for (NSString* randomString in randomArr) {
        HGMethodDeclData* declData = [HGMethodDeclData new];
        // 方法类型
        declData.declMethod = declMethod;
        
        // call
        NSMutableString *content = [NSMutableString string];
        [content appendString:[NSString mj_stringWithFilename:@"HGDeclMethodCall" extension:@"tpl"]];
        [content replaceOccurrencesOfString:HGSelString
                                 withString:randomString
                                    options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
        // 赋值
        declData.callText = content;
        
        // dcel
        content = [NSMutableString string];
        [content appendString:[NSString mj_stringWithFilename:@"HGDeclMethodDecl" extension:@"tpl"]];
        // 方法类型
        [content replaceOccurrencesOfString:HGMethodType
                                 withString:((declMethod == HGDeclMethodClass)?@"+":@"-")
                                    options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
        // sel
        [content replaceOccurrencesOfString:HGSelString
                                 withString:randomString
                                    options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
        // 变量名称
        NSString* ivar = [NSString mj_randomStringWithoutDigitalWithLength:16];
        // 变量名称
        [content replaceOccurrencesOfString:HGIvar
                                 withString:ivar
                                    options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
        // 随机生成一个数字
        int randomInt = arc4random_uniform(999)+99;
        // 变量名称
        [content replaceOccurrencesOfString:HGIvarValue
                                 withString:[NSString stringWithFormat:@"%d", randomInt]
                                    options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
        
        // 赋值
        declData.declText = content;
        
        // 添加
        [declDataArrM addObject:declData];
    }
    return declDataArrM.copy;
}

/** 返回方法体 */
+ (NSString*)hg_MethodDeclStringWithDeclMethods:(NSArray*)declMethods {
    
    NSMutableString* declMethodStringM = [NSMutableString string];
    for (NSArray* arr in declMethods) {
        for (HGMethodDeclData* declData in arr) {
            [declMethodStringM appendString:declData.declText];
        }
    }
    
    return declMethodStringM.copy;
}

// 属性与成员变量的随机生成
+ (NSString*)hg_randomPropertyTypeIvarWithDeclString:(NSString*)declString name:(NSString*)name randomString:(NSString*)randomString {
    declString = [declString stringByReplacingOccurrencesOfString:name withString:randomString options:NSBackwardsSearch range:NSMakeRange(0, declString.length)];
    declString = [NSString stringWithFormat:@"\n%@;\n", declString];
    return declString;
}

@end
