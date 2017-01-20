//
// Created by lingqingwan on 7/6/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"


@interface TXLike : TXEntityBase
@property(nonatomic) int64_t userId;
@property(nonatomic) NSString *userNickName;
@property(nonatomic) NSString *userAvatarUrl;

//- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

//- (instancetype)loadValueFromPbObject:(TXPBLike *)txpbLike;

@end