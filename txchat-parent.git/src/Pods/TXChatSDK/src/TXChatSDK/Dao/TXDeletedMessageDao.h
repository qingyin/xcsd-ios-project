//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXDeletedMessage.h"
#import "TXChatDaoBase.h"

@interface TXDeletedMessageDao : TXChatDaoBase
- (NSArray *)queryAllDeletedMessage;

- (void)addDeletedMessage:(TXDeletedMessage *)txDeletedMessage error:(NSError **)outError;

- (void)deleteDeletedMessageByMsgId:(NSString *)msgId;
@end