//
//  NSArray+Extension.h
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extension)

// 获取随机字符列表
+ (instancetype)hg_randomListWithLength:(NSInteger)length;

/** 返回一个字符串格式的数组 */
+ (NSString*)hg_randomStringWithLength:(NSInteger)length;

/** 文件的总大小 */
- (NSUInteger)hg_fileSize;

@end
