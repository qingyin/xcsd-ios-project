//
// Created by lingqingwan on 6/12/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "TXPBChat.pb.h"

@interface TXCheckIn : TXEntityBase
@property(nonatomic) int64_t checkInId;
@property(nonatomic, strong) NSString *cardCode;
@property(nonatomic, strong) NSMutableArray *attaches;
@property(nonatomic) int64_t userId;
@property(nonatomic, strong) NSString *username;
@property(nonatomic) int64_t checkInTime;
@property(nonatomic) int64_t gardenId;
@property(nonatomic) int64_t machineId;
@property(nonatomic) int64_t clientKey;
@property(nonatomic, strong) NSString *parentName;
@property(nonatomic, strong) NSString *className;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)fmResultSet;

- (instancetype)loadValueFromPbObject:(TXPBCheckin *)txpbCheckIn;

@end