//
// Created by lingqingwan on 9/7/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"


@interface TXDeletedMessage : TXEntityBase
@property(nonatomic, strong) NSString *msgId;
@property(nonatomic, strong) NSString *cmdMsgId;
@property(nonatomic, strong) NSString *fromUserId;
@property(nonatomic, strong) NSString *toUserId;
@property(nonatomic) BOOL isGroup;
@end