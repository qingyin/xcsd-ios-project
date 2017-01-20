//
// Created by lingqingwan on 9/22/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"

@interface TXDepartmentPhoto : TXEntityBase
@property(nonatomic) int64_t departmentPhotoId;
@property(nonatomic) int64_t departmentId;
@property(nonatomic, strong) NSString *fileUrl;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(TXPBDepartmentPhoto *)txpbDepartmentPhoto
                         departmentId:(int64_t)departmentId;
@end