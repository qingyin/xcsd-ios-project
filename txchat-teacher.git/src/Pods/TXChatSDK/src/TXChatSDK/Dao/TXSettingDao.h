//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatDaoBase.h"


@interface TXSettingDao : TXChatDaoBase
- (void)saveSettingValue:(NSString *)value forKey:(NSString *)key error:(NSError **)outError;

- (NSString *)querySettingValueByKey:(NSString *)key;
@end