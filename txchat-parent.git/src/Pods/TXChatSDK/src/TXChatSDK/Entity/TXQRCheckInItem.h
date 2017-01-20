//
// Created by lingqingwan on 9/23/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"

typedef NS_ENUM(SInt32, TXQrCheckInItemStatus) {
    TXQrCheckInItemStatusUploading = 1,
    TXQrCheckInItemStatusUploadSucceed = 2,
    TXQrCheckInItemStatusUploadFailed = 3,
};

@interface TXQrCheckInItem : TXEntityBase
@property(nonatomic) int64_t targetUserId;
@property(nonatomic, strong) NSString *targetUsername;
@property(nonatomic, strong) NSString *targetUserType;
@property(nonatomic, strong) NSString *targetCardNumber;
@property(nonatomic) TXQrCheckInItemStatus status;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

@end