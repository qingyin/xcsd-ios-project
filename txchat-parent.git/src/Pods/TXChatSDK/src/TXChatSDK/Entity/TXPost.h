//
// Created by lingqingwan on 7/15/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXPBChat.pb.h"
#import "TXEntityBase.h"

@interface TXPost : TXEntityBase
@property(nonatomic) int64_t postId;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *summary;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSString *coverImageUrl;
@property(nonatomic) TXPBPostType postType;
@property(nonatomic) int64_t groupId;
@property(nonatomic) int64_t orderValue;
@property(nonatomic, strong) NSString *postUrl;
@property(nonatomic) int64_t gardenId;
@property(nonatomic) BOOL isRead;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(TXPBPost *)txpbPost groupId:(int64_t)groupId;
@end