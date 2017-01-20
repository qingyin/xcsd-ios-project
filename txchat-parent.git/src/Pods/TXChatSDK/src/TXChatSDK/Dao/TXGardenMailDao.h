//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXGardenMail.h"
#import "TXChatDaoBase.h"

@interface TXGardenMailDao : TXChatDaoBase

- (void)addGardenMail:(TXGardenMail *)txGardenMail error:(NSError **)outError;


- (NSArray *)queryGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;


- (void)deleteAllGardenMail;

- (void)markGardenMailAsRead:(int64_t)gardenMailId error:(NSError **)outError;


@end