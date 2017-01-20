//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "TXPBChat.pb.h"


@interface TXDepartment : TXEntityBase
@property(nonatomic) int64_t departmentId;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *nameFirstLetter;
@property(nonatomic) int64_t parentId;
@property(nonatomic) TXPBDepartmentType departmentType;
@property(nonatomic, strong) NSString *avatarUrl;
@property(nonatomic, strong) NSString *groupId;
@property(nonatomic) BOOL showParent;
@end