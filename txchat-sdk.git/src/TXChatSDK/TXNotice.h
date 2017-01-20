//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"


@interface TXNotice : TXEntityBase
@property(nonatomic) int64_t noticeId;
@property(nonatomic) int64_t fromUserId;
@property(nonatomic) int64_t sentOn;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSMutableArray *attaches;
@property(nonatomic) BOOL isInbox;
@property(nonatomic) BOOL isRead;
@property(nonatomic, strong) NSString *senderAvatar;
@property(nonatomic, strong) NSString *senderName;
@end