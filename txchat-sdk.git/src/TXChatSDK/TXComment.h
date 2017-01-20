//
// Created by lingqingwan on 7/6/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "TXPBChat.pb.h"

@interface TXComment : TXEntityBase
@property(nonatomic) int64_t commentId;
@property(nonatomic, strong) NSString *content;
@property(nonatomic) TXPBCommentType commentType;
@property(nonatomic) int64_t targetId;
@property(nonatomic) int64_t targetUserId;
@property(nonatomic) TXPBTargetType targetType;
@property(nonatomic) int64_t toUserId;
@property(nonatomic, strong) NSString *toUserNickname;
@property(nonatomic) int64_t userId;
@property(nonatomic, strong) NSString *userNickname;
@property(nonatomic, strong) NSString *userAvatarUrl;
@end