//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXFeed.h"
#import "TXChatDaoBase.h"

@interface TXFeedDao : TXChatDaoBase
/**
* 从数据库中获取feed list
*/
- (NSArray *)queryFeeds:(int64_t)maxFeedId
                  count:(int64_t)count
                isInbox:(BOOL)isInbox
                  error:(NSError **)outError;

- (NSArray *)queryFeeds:(int64_t)maxFeedId count:(int64_t)count userId:(int64_t)userId error:(NSError **)outError;

- (void)addFeed:(TXFeed *)txFeed error:(NSError **)outError;

- (void)deleteFeedByFeedId:(int64_t)feedId error:(NSError **)outError;

- (void)deleteAllFeed;

- (void)deleteAllFeedByUserId:(int64_t)userId;

@end