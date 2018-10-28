//
//  NSArray+Extension.m
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "NSArray+Extension.h"
#import "NSString+Extension.h"

@implementation NSArray (Extension)

// 获取随机字符列表
+ (instancetype)hg_randomListWithLength:(NSInteger)length {
    NSMutableArray* randomArrM = [NSMutableArray array];
    for (int i=0; i<length; i++) {
        NSString *obfuscation = nil;
        while (!obfuscation || [randomArrM containsObject:obfuscation]) {
            // obfuscation 为空 或者已经在 randomArrM 了, name 需要重新生成
            obfuscation = [NSString mj_randomStringWithoutDigitalWithLength:16];
        }
        [randomArrM addObject:obfuscation];
    }
    return randomArrM.copy;
}

// 返回一个字符串格式的数组
+ (NSString*)hg_randomStringWithLength:(NSInteger)length {
    NSMutableString* stringM = [NSMutableString stringWithString:@"@["];
    NSArray* randomArr = [self hg_randomListWithLength:length];
    for (int j=0; j<length; j++) {
        NSString* content = randomArr[j];
        NSString* text = [NSString stringWithFormat:@"@\"%@\"", content];
        if (j == (length - 1)) {
            [stringM appendFormat:@"%@", text];
        } else {
            [stringM appendFormat:@"%@, ", text];
        }
    }
    [stringM appendString:@"]"];
    
    return stringM.copy;
}

// 文件的总大小
- (NSUInteger)hg_fileSize {
    // 定义记录大小
    NSInteger totalSize = 0;
    // 创建一个文件管理对象
    NSFileManager * manager = [NSFileManager defaultManager];
    // 遍历获取文件名称
    for (NSString * subPath in self) {
        // 获取文件属性
        NSDictionary *dict = [manager attributesOfItemAtPath:subPath error:nil];
        // 累加
        totalSize += [dict fileSize];
    }
    
    // 返回
    return totalSize;
}

@end
