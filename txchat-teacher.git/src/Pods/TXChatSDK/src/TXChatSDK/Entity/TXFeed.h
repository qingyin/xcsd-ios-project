//
// Created by lingqingwan on 7/5/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "TXPBChat.pb.h"

typedef NS_ENUM(SInt32, TXFeedType) {
    TXFeedTypePlain = 0,
    TXFeedTypeActivity = 1,
};

@interface TXFeed : TXEntityBase
@property(nonatomic) int64_t feedId;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSMutableArray/*<TXPBAttach>*/ *attaches;
@property(nonatomic) int64_t userId;
@property(nonatomic) NSString *userNickName;
@property(nonatomic) NSString *userAvatarUrl;
@property(nonatomic) BOOL isInbox;
@property(nonatomic) BOOL hasMoreComment;
@property(nonatomic) TXPBUserType userType;
@property(nonatomic) TXFeedType feedType;
@property(nonatomic, strong) NSString *activityUrl;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(TXPBFeed *)txpbFeed;

@end