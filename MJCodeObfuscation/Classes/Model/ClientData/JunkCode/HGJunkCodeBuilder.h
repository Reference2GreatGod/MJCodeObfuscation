//
//  HGJunkCodeBuilder.h
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGMethodDeclData.h"

/**
 花指令生成器
 */
@interface HGJunkCodeBuilder : NSObject

/** 随机生成 类方法 & 实例方法 */
+ (NSArray*)hg_randomMethodWithDeclMethod:(HGDeclMethod)declMethod;

/** 随机生成 类方法 & 实例方法 */
+ (NSArray*)hg_randomMethodWithDeclMethod:(HGDeclMethod)declMethod length:(NSInteger)length;

/** 返回方法体 */
+ (NSString*)hg_MethodDeclStringWithDeclMethods:(NSArray*)declMethods;

/** 属性与成员变量的随机生成 */
+ (NSString*)hg_randomPropertyTypeIvarWithDeclString:(NSString*)declString name:(NSString*)name randomString:(NSString*)randomString;

@end
