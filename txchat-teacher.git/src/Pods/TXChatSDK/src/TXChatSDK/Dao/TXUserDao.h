//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXUser.h"
#import "TXChatDaoBase.h"

@interface TXUserDao : TXChatDaoBase
- (TXUser *)queryUserByUserId:(int64_t)userId error:(NSError **)outError;

- (TXUser *)queryUserByUsername:(NSString *)username error:(NSError **)outError;

- (void)addUser:(TXUser *)txUser error:(NSError **)outError;

- (void)deleteUserByUserId:(int64_t)userId error:(NSError **)outError;

- (void)deleteDepartmentUserWithUserId:(int64_t)userId departmentId:(int64_t)departmentId;

- (void)putUsers:(NSArray *)userIds toDepartment:(int64_t)departmentId error:(NSError **)outError;

- (NSArray *)queryUsersByDepartmentId:(int64_t)departmentId userType:(TXPBUserType)userType error:(NSError **)outError;

- (NSArray *)queryParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError;
@end