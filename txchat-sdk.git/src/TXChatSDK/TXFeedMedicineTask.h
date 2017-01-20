//
// Created by lingqingwan on 6/29/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"

@interface TXFeedMedicineTask : TXEntityBase
@property(nonatomic) int64_t feedMedicineTaskId;
@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSMutableArray *attaches;
@property(nonatomic) int64_t parentUserId;
@property(nonatomic, strong) NSString *parentUsername;
@property(nonatomic, strong) NSString *parentAvatarUrl;
@property(nonatomic) int64_t classId;
@property(nonatomic, strong) NSString *className;
@property(nonatomic, strong) NSString *classAvatarUrl;
@property(nonatomic) BOOL isRead;
@property(nonatomic) int64_t beginDate;
@property(nonatomic) BOOL isChanged;
@end