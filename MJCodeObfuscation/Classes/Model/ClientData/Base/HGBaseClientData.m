//
//  HGBaseClientData.m
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "HGBaseClientData.h"

@implementation HGBaseClientData

// setter
- (void)setFile:(NSString *)file {
    _file = file.copy;
    
    _fileData = [NSData dataWithContentsOfFile:_file];
    _file_int_data_length = _fileData.length;
}

/** 更新文本内容 */
- (BOOL)updateContent {
    
    if (self.nodes.count == 0) {
        return YES;
    }
    
    // 降序排列
    NSSortDescriptor* sortOffset = [NSSortDescriptor sortDescriptorWithKey:@"offset" ascending:NO];
    NSArray* nodes = [self.nodes sortedArrayUsingDescriptors:@[sortOffset]];
    // 替换
    self.nodes = nodes.mutableCopy;
    
    return YES;
}

@end
