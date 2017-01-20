//
// Created by lingqingwan on 9/23/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatDaoBase.h"
#import "TXQrCheckInItem.h"

@interface TXQrCheckInItemDao : TXChatDaoBase

- (TXQrCheckInItem *)addQrCheckInItem:(TXQrCheckInItem *)txQrCheckInItem error:(NSError **)outError;

- (int)queryQrCheckInItemCount;

- (NSArray *)queryQrCheckInItems:(int64_t)maxId count:(int64_t)count;

- (NSArray *)queryUploadRequiredQrCheckInItems;

- (void)updateStatus:(int64_t)itemId newStatus:(TXQrCheckInItemStatus)newStatus;

- (void)deleteAllSucceedItems;

@end