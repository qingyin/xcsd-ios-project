//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXUserDao.h"


@implementation TXUserDao {

}
- (TXUser *)queryUserByUserId:(int64_t)userId error:(NSError **)outError {
    __block TXUser *txUser = nil;
    NSString *sql = @"SELECT * FROM user WHERE user_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(userId)];
        if (resultSet.next) {
            txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    txUser.childUserIdAndRelationsList = [self queryParentRelationsByParentId:txUser.userId];
    return txUser;
}

-(TXUser *)queryUserByUserId:(int64_t)userId departmentId:(int64_t)departmentId error:(NSError *__autoreleasing *)outError
{
    __block TXUser *txUser = nil;
    NSString *sql =nil;
    if(departmentId > 0)
    {
        sql = @"SELECT * FROM user  LEFT JOIN department_user on user.user_id=department_user.user_id  WHERE department_user.user_id=?";
        sql = [sql stringByAppendingString:@" AND department_user.department_id = ?"];
    }
    else
    {
        sql = @"SELECT * FROM user WHERE user_id=?";
    }
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(userId), @(departmentId)];
        if (resultSet.next) {
            txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    txUser.childUserIdAndRelationsList = [self queryParentRelationsByParentId:txUser.userId];
    
    return txUser;
}


- (TXUser *)queryUserByUsername:(NSString *)username error:(NSError **)outError {
    __block TXUser *txUser = nil;
    NSString *sql = @"SELECT * FROM user WHERE username=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, username];
        if (resultSet.next) {
            txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    txUser.childUserIdAndRelationsList = [self queryParentRelationsByParentId:txUser.userId];
    return txUser;
}

- (void)addUser:(TXUser *)txUser error:(NSError **)outError {
    [self insertObject:txUser error:outError];
    if(txUser.childUserIdAndRelationsList)
    {
        NSError *error = nil;
        [self PutUserId:txUser.userId inRelations:txUser.childUserIdAndRelationsList error:&error];
    }

    return;

  /*
    NSString *sql = @
            "REPLACE INTO user(updated_on,created_on,class_id,garden_id,user_id,username,is_init,child_user_id,"
            "mobile_phone_number,sign,user_type,avatar_url,birthday,class_name,garden_name,location,position_name,"
            "nickname,nickname_first_letter,real_name,parent_type,sex,position_id,guarder,activated) "
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL ok = [db executeUpdate:sql withArgumentsInArray:[txUser propertyValues]];
        if (!ok) {
            if (outError && !*outError) {
                NSString *errorMessage = [NSString stringWithFormat:@"ERROR:execute sql %@", sql];
                *outError = TX_ERROR_MAKE(TX_STATUS_UN_KNOW_ERROR, errorMessage);
            }
        }

       if (![db executeUpdate:sql
          withErrorAndBindings:outError, [txUser propertyValues]
                *//*  @(TIMESTAMP_OF_NOW),
                  @(txUser.createdOn),
                  @(txUser.classId),
                  @(txUser.gardenId),
                  @(txUser.userId),
                  txUser.username,
                  @(txUser.isInit),
                  @(txUser.childUserId),
                  txUser.mobilePhoneNumber,
                  txUser.sign != nil ? txUser.sign : @"",
                  @(txUser.userType),
                  txUser.avatarUrl,
                  @(txUser.birthday),
                  txUser.className != nil ? txUser.className : @"",
                  txUser.gardenName != nil ? txUser.gardenName : @"",
                  txUser.location != nil ? txUser.location : @"",
                  txUser.positionName,
                  txUser.nickname != nil ? txUser.nickname : @"",
                  txUser.nicknameFirstLetter != nil ? txUser.nicknameFirstLetter : @"",
                  txUser.realName != nil ? txUser.realName : @"",
                  @(txUser.parentType),
                  @(txUser.sex),
                  @(txUser.positionId),
                  txUser.guarder,
                  @(txUser.activated)*//*

        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];*/
}

- (void)deleteUserById:(int64_t)id error:(NSError **)outError {
    NSString *sql = @"DELETE FROM user WHERE id=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(id)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteUserByUserId:(int64_t)userId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM user WHERE user_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(userId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
    NSError *error = nil;
    [self delRelationsByUserId:userId error:&error];
    if(error)
    {
        DDLogDebug(@"error:%@", error);
    }

}

- (NSArray *)queryUsersByDepartmentId:(int64_t)departmentId userType:(TXPBUserType)userType error:(NSError **)outError {
    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM user LEFT JOIN department_user on user.user_id=department_user.user_id WHERE department_user.department_id=?  ";
    if (userType > 0) {
        sql = [sql stringByAppendingString:@" and user_type=?"];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(departmentId), @(userType)];
        while (resultSet.next) {
            TXUser *txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
            [txUsers addObject:txUser];
        }
        [resultSet close];
    }];
    NSMutableArray *existUsers = [NSMutableArray arrayWithCapacity:1];
    for(TXUser *userIndex in txUsers)
    {
        if(!userIndex)
        {
            continue;
        }
        if([self isUserExistInDepartment:userIndex departmentId:departmentId])
        {
            userIndex.childUserIdAndRelationsList = [self queryParentRelationsByParentId:userIndex.userId];
            [existUsers addObject:userIndex];
        }
    }

    return txUsers;
}

- (void)deleteDepartmentUserWithUserId:(int64_t)userId departmentId:(int64_t)departmentId {
    NSString *sql = @"DELETE FROM department_user WHERE user_id=? AND department_id=?";

    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:sql, @(userId), @(departmentId)];
    }];
    NSError *error = nil;
    [self delRelationsByUserId:userId error:&error];
    if(error)
    {
        DDLogDebug(@"error:%@", error);
    }

}

- (void)putUsers:(NSArray *)userIds toDepartment:(int64_t)departmentId error:(NSError **)outError {
     NSString *sqlInsert = @"REPLACE INTO department_user(department_id,user_id,updated_on,created_on, depart_nickname, depart_nickname_first_letter) VALUES (?,?,?,?, ?, ?)";

    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (uint i = 0; i < userIds.count; ++i) {
            TXUser *user = userIds[i];
            if (![db executeUpdate:sqlInsert
              withErrorAndBindings:outError,
                  @(departmentId),
                  @(user.userId),
                  @(TIMESTAMP_OF_NOW),
                  @(TIMESTAMP_OF_NOW),
                  user.nickname,
                  user.nicknameFirstLetter]) {
                FILL_OUT_ERROR_IF_NULL(sqlInsert);
                *rollback = TRUE;
                break;
            }
        }
    }];
}

//- (NSArray *)queryParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError {
//    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
//    NSString *sql = @"SELECT * FROM user where child_user_id=? ";
//
//    [_databaseQueue inDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:sql, @(childUserId)];
//        while (resultSet.next) {
//            TXUser *txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
//            [txUsers addObject:txUser];
//        }
//        [resultSet close];
//    }];
//    return txUsers;
//}


- (NSArray *)queryParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError {
    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM user LEFT JOIN user_relation on user.user_id = user_relation.parent_id where user_relation.child_id = ?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(childUserId)];
        while (resultSet.next) {
            TXUser *txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
            [txUsers addObject:txUser];
        }
        [resultSet close];
    }];
    
    
    for(TXUser *userIndex in txUsers)
    {
        if(!userIndex)
        {
            continue;
        }
        userIndex.childUserIdAndRelationsList = [self queryParentRelationsByParentId:userIndex.userId];
    }
    return txUsers;
}


- (NSArray *)queryParentUsersByChildUserIdAndDepartmentId:(int64_t)childUserId departmentId:(int64_t)departmentId  error:(NSError **)outError {
    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM user LEFT JOIN user_relation on user.user_id = user_relation.parent_id where user_relation.child_id = ?";
    
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(childUserId)];
        while (resultSet.next) {
            TXUser *txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
            [txUsers addObject:txUser];
        }
        [resultSet close];
    }];
    
    NSMutableArray *txExistUsers = [NSMutableArray arrayWithCapacity:1];
    for(TXUser *userIndex in txUsers)
    {
        if([self updateDepartmentNickName:userIndex departmentId:departmentId])
        {
            [txExistUsers addObject:userIndex];
        }
    }
    return txExistUsers;
}

-(BOOL)isUserExistInDepartment:(TXUser *)user departmentId:(int64_t)departmentId
{
    __block BOOL ret = NO;
    NSString *sql = @"SELECT COUNT(*) FROM department_user where department_id = ? and user_id = ?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(departmentId), @(user.userId)];
        while (resultSet.next) {
            int64_t count = [resultSet longForColumn:@"COUNT(*)"];
            if(count > 0)
            {
                ret = YES;
            }
        }
        [resultSet close];
    }];
    
    return ret;
}

-(BOOL)updateDepartmentNickName:(TXUser *)user departmentId:(int64_t)departmentId
{
    __block BOOL ret = NO;
    NSString *sql = @"SELECT depart_nickname, depart_nickname_first_letter FROM department_user where department_id = ? and user_id = ?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(departmentId), @(user.userId)];
        while (resultSet.next) {
            user.nickname = [resultSet stringForColumn:@"depart_nickname"];
            user.nicknameFirstLetter = [resultSet stringForColumn:@"depart_nickname_first_letter"];
            ret = YES;
        }
        [resultSet close];
    }];
    
    return ret;
}

/**
 *  获取 家长和幼儿的关系
 *
 *  @param parentId 家长id
 *
 *  @return 幼儿id 和对应关系
 */
-(NSArray *)queryParentRelationsByParentId:(int64_t)parentId
{
    NSMutableArray *parentRelations = [NSMutableArray arrayWithCapacity:1];
    
    NSString *sql = @"SELECT child_id, parent_type, ismaster FROM user_relation where parent_id = ?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(parentId)];
        while (resultSet.next) {
            TXPBChildBuilder *builder = [TXPBChild builder];
            builder.userId = [resultSet longForColumn:@"child_id"];
            builder.parentType = [resultSet intForColumn:@"parent_type"];
            builder.isMaster = [resultSet boolForColumn:@"ismaster"];
            [parentRelations addObject:[builder build]];
        }
        [resultSet close];
    }];
    //主账户排在第一位
    [parentRelations sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TXPBChild *firstChild = (TXPBChild *)obj1;
        TXPBChild *secondChild = (TXPBChild *)obj2;
        if(firstChild.isMaster)
        {
            return  NSOrderedAscending;
        }
        else if(secondChild.isMaster)
        {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    return [NSArray arrayWithArray:parentRelations];
}
/**
 *  更新 用户和幼儿的关系
 *
 *  @param parentId  parentId 家长id
 *  @param relations relations 关系信息
 *  @param outError  outError 错误信息
 *
 *  @return return value 操作结果
 */
-(BOOL)PutUserId:(int64_t)parentId inRelations:(NSArray *)relations  error:(NSError **)outError
{
    __block BOOL ret = NO;
    if(!relations)
    {
        return ret;
    }
    
    NSString *sql = @"REPLACE INTO  user_relation(updated_on, created_on, parent_id, child_id, parent_type, ismaster) VALUES(?, ?, ?, ?, ?, ?)";
    
    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for(TXPBChild *pbChildIndex in relations)
        {
            if(!pbChildIndex)
            {
                continue;
            }
            if(![db executeUpdate:sql withErrorAndBindings:outError, @(TIMESTAMP_OF_NOW),
                 @(TIMESTAMP_OF_NOW), @(parentId), @(pbChildIndex.userId), @(pbChildIndex.parentType), @(pbChildIndex.isMaster)])
            {
                FILL_OUT_ERROR_IF_NULL(sql);
                *rollback = YES;
                break;
            }
        }
        ret = YES;
    }];
    
    return ret;
}
/**
 *  删除用户关系
 *
 *  @param userId   userId 用户id
 *  @param outError outError 出错信息
 *
 *  @return return value 操作结果
 */
-(BOOL)delRelationsByUserId:(int64_t)userId  error:(NSError **)outError
{
    __block BOOL ret = NO;
    
    NSString *sql = @"DELETE FROM user_relation WHERE parent_id = ? OR child_id = ?";
    
    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [db executeUpdate:sql withErrorAndBindings:outError, @(userId),  @(userId)];
        if(!ret)
        {
            FILL_OUT_ERROR_IF_NULL(sql);
            *rollback = TRUE;
        }
    }];
    return ret;
}


- (NSArray *)queryChildIdsByParentUserId:(int64_t) parentUserId error:(NSError **)outError
{
    
}

@end