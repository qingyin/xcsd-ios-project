//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXDepartment.h"
#import "TXChatDaoBase.h"

@interface TXDepartmentDao : TXChatDaoBase

- (void)addDepartment:(TXDepartment *)department error:(NSError **)outError;

- (void)deleteDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError;

- (void)deleteDepartmentMembersByDepartmentId:(int64_t)departmentId error:(NSError **)outError;

- (TXDepartment *)queryDepartmentByGroupId:(NSString *)groupId error:(NSError **)outError;

- (TXDepartment *)queryDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError;

- (NSArray *)queryAllDepartment:(NSError **)outError;


@end