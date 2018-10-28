//
//  HGJunkCodeClientNode.h
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "HGBaseClientNode.h"

/** 花指令节点类型 */
typedef NS_ENUM(NSInteger, HGJCType) {
    HGJCTypeOther,
    HGJCTypeImplementationDecl,
    HGJCTypeInstanceMethodDecl,
    HGJCTypeClassMethodDecl,
    HGJCTypePropertyDecl,
    HGJCTypeIvarDecl
};

/** 花指令节点 */
@interface HGJunkCodeClientNode : HGBaseClientNode

@property (nonatomic, assign) HGJCType jcType;
// 用于 CXCursor_ObjCPropertyDecl 与 CXCursor_ObjCIvarDecl
@property (nonatomic, copy) NSString* declString;

@end
