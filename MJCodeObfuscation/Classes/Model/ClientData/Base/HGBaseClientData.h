//
//  HGBaseClientData.h
//  MJCodeObfuscation
//
//  Created by ZhuHong on 2018/10/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGBaseClientNode;

@interface HGBaseClientData : NSObject

@property (nonatomic, copy) NSString *file;
@property (nonatomic, strong, readonly) NSData* fileData;
@property (nonatomic, assign, readonly) NSInteger file_int_data_length;
@property (nonatomic, copy) NSString* fileContent;

/** 所有的节点 */
@property (nonatomic, strong) NSMutableArray<HGBaseClientNode*> *nodes;

/** 更新文本内容 */
- (BOOL)updateContent NS_REQUIRES_SUPER;

@end
