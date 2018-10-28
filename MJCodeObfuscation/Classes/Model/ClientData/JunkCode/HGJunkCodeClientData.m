//
//  HGJunkCodeClientData.m
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "HGJunkCodeClientData.h"
#import "HGJunkCodeBuilder.h"

@implementation HGJunkCodeClientData

- (instancetype)init {
    self = [super init];
    _obfuscations = [NSMutableArray array];
    return self;
}

// 更新文本内容
- (BOOL)updateContent {
    [super updateContent];
    
    // 类方法 & 实例方法 随机数列表
    NSArray* declDataIArrM = [HGJunkCodeBuilder hg_randomMethodWithDeclMethod:HGDeclMethodInstance];
    NSArray* declDataCArrM = [HGJunkCodeBuilder hg_randomMethodWithDeclMethod:HGDeclMethodClass];
    
    NSMutableData* contentData = [NSMutableData dataWithData:self.fileData];

    for (HGJunkCodeClientNode* node in self.nodes) {
        NSString* insertContent = @"";
        switch (node.jcType) {
                case HGJCTypeImplementationDecl:
            {
                // 方法体
                NSString* codeOString = [HGJunkCodeBuilder hg_MethodDeclStringWithDeclMethods:@[declDataCArrM, declDataIArrM]];
                insertContent = codeOString;
            }
                break;
                case HGJCTypeInstanceMethodDecl:
            {
                // 随机获取两个实例方法的调用文本
                uint32_t upper_bound_int = (uint32_t)declDataIArrM.count;
                NSInteger index_ = arc4random_uniform(upper_bound_int);
                HGMethodDeclData* declData = declDataIArrM[index_];
                
                insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                declData = declDataIArrM[(index_+1)%declDataIArrM.count];
                insertContent = [NSString stringWithFormat:@"%@%@\n", insertContent, declData.callText];
            }
                break;
                case HGJCTypeClassMethodDecl:
            {
                // 随机获取两个类方法的调用文本
                uint32_t upper_bound_int = (uint32_t)declDataCArrM.count;
                NSInteger index_ = arc4random_uniform(upper_bound_int);
                HGMethodDeclData* declData = declDataCArrM[index_];
                insertContent = [NSString stringWithFormat:@"\n%@", declData.callText];
                
                declData = declDataCArrM[(index_+1)%declDataCArrM.count];
                insertContent = [NSString stringWithFormat:@"%@%@\n", insertContent, declData.callText];
            }
                break;
                case HGJCTypePropertyDecl:
            {
                if (self.obfuscations.count > 0) {
                    insertContent = [HGJunkCodeBuilder hg_randomPropertyTypeIvarWithDeclString:node.declString name:node.name randomString:self.obfuscations.lastObject];
                    [self.obfuscations removeLastObject];
                } else {
                    insertContent = @"\n// 这里是属性声明的开头\n";
                }
                
            }
                break;
                case HGJCTypeIvarDecl:
            {
                if (self.obfuscations.count > 0) {
                    insertContent = [HGJunkCodeBuilder hg_randomPropertyTypeIvarWithDeclString:node.declString name:node.name randomString:self.obfuscations.lastObject];
                    [self.obfuscations removeLastObject];
                } else {
                    insertContent = @"\n\t// 这里是成员变量声明的开头\n";
                }
                
            }
                break;
                
            default:
                insertContent = @"\n\t// 乱了吧 \n";
                break;
        }
        
        // 插入
        NSData* insertData = [insertContent dataUsingEncoding:NSUTF8StringEncoding];
        [contentData replaceBytesInRange:NSMakeRange(node.offset, 0) withBytes:insertData.bytes length:insertData.length];
    }
    
    self.fileContent = [[NSString alloc] initWithData:contentData encoding:NSUTF8StringEncoding];
    // NSLog(@"%@", self.fileContent);
    
    NSError* error;
    // 覆盖文件
    [self.fileContent writeToFile:self.file atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    return (!!self.fileContent) && (!error);
}


@end
