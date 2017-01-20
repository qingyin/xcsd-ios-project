//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"

@interface TXCounterManager : TXChatManagerBase

/**
* 计数器k-v
*/
@property(strong, readonly) NSMutableDictionary *countersDictionary;

/**
*从服务端获取计数器
*/
- (void)fetchCounters:(void (^)(NSError *error, NSMutableDictionary *countersDictionary))onCompleted;

/**
* 设置计数器字典key-value
*/
- (void)setCountersDictionaryValue:(int)value forKey:(NSString *)key;

@end