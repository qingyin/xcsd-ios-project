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
    return txUser;
}

- (void)addUser:(TXUser *)txUser error:(NSError **)outError {
    [self insertObject:txUser error:outError];
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
    return txUsers;
}

- (void)deleteDepartmentUserWithUserId:(int64_t)userId departmentId:(int64_t)departmentId {
    NSString *sql = @"DELETE FROM department_user WHERE user_id=? AND department_id=?";

    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:sql, @(userId), @(departmentId)];
    }];
}

- (void)putUsers:(NSArray *)userIds toDepartment:(int64_t)departmentId error:(NSError **)outError {
    NSString *sqlInsert = @"REPLACE INTO department_user(department_id,user_id,updated_on,created_on) VALUES (?,?,?,?)";

    [_databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (uint i = 0; i < userIds.count; ++i) {
            if (![db executeUpdate:sqlInsert
              withErrorAndBindings:outError,
                                   @(departmentId),
                                   userIds[i],
                                   @(TIMESTAMP_OF_NOW),
                                   @(TIMESTAMP_OF_NOW)]) {
                FILL_OUT_ERROR_IF_NULL(sqlInsert);
                *rollback = TRUE;
                break;
            }
        }
    }];
}

- (NSArray *)queryParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError {
    __block NSMutableArray *txUsers = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM user where child_user_id=? ";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(childUserId)];
        while (resultSet.next) {
            TXUser *txUser = [[[TXUser alloc] init] loadValueFromFMResultSet:resultSet];
            [txUsers addObject:txUser];
        }
        [resultSet close];
    }];
    return txUsers;
}
@end