//
// Created by lingqingwan on 6/29/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"


@interface TXGardenMail : TXEntityBase
@property(nonatomic) int64_t gardenMailId;
@property(nonatomic) int64_t gardenId;
@property(nonatomic, strong) NSString *gardenName;
@property(nonatomic, strong) NSString *gardenAvatarUrl;
@property(nonatomic, strong) NSString *content;
@property(nonatomic) BOOL isAnonymous;
@property(nonatomic) int64_t fromUserId;
@property(nonatomic, strong) NSString *fromUsername;
@property(nonatomic, strong) NSString *fromUserAvatarUrl;
@property(nonatomic) BOOL isRead;
@property(nonatomic) BOOL isChanged;
@end