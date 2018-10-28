//
//  HGJunkCodeClientData.h
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "HGBaseClientData.h"
#import "HGJunkCodeClientNode.h"

/** 花指令 */
@interface HGJunkCodeClientData : HGBaseClientData

@property (nonatomic, strong) NSArray *prefixes;

// 用于 CXCursor_ObjCPropertyDecl 与 CXCursor_ObjCIvarDecl
@property (nonatomic, strong) NSMutableArray* obfuscations;

@end
