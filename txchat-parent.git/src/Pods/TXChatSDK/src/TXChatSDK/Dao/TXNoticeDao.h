//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXNotice.h"
#import "TXChatDaoBase.h"

@interface TXNoticeDao : TXChatDaoBase
- (void)addNotice:(TXNotice *)txNotice error:(NSError **)outError;

- (NSArray *)queryNotices:(int64_t)maxNoticeId count:(int64_t)count error:(NSError **)outError;

- (NSArray *)queryNotices:(int64_t)maxNoticeId
                    count:(int64_t)count
                  isInbox:(BOOL)isInbox
                    error:(NSError **)outError;

- (TXNotice *)queryNoticeById:(int64_t)id error:(NSError **)outError;

- (TXNotice *)queryNoticeByNoticeId:(int64_t)noticeId error:(NSError **)outError;

- (TXNotice *)queryLastNotice;

- (TXNotice *)queryLastInboxNotice;

- (void)deleteAllNotice;

- (void)deleteAllNotice:(BOOL)isInbox;

- (void)markNoticeAsRead:(int64_t)noticeId error:(NSError **)outError;


@end