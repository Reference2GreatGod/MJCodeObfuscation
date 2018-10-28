//
//  HGMethodDeclData.h
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

// 类的类型定义: class & instance
typedef NS_ENUM(NSInteger, HGDeclMethod) {
    HGDeclMethodClass,
    HGDeclMethodInstance
};

/** 花指令节点 */
@interface HGMethodDeclData : NSObject
/** HGDeclMethod */
@property (nonatomic, assign) HGDeclMethod declMethod;
/** 调用文本*/
@property (nonatomic, copy) NSString* callText;
/** 实现文本 */
@property (nonatomic, copy) NSString* declText;
@end
