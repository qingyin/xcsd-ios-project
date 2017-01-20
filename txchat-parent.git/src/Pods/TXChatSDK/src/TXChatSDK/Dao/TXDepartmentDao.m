//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDepartmentDao.h"


@implementation TXDepartmentDao {

}
- (TXDepartment *)queryDepartmentByGroupId:(NSString *)groupId error:(NSError **)outError {
    __block TXDepartment *txDepartment;
    NSString *sql = @"SELECT * FROM department WHERE group_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, groupId];
        if (resultSet.next) {
            txDepartment = [[[TXDepartment alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txDepartment;
}

- (TXDepartment *)queryDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    __block TXDepartment *txDepartment;
    NSString *sql = @"SELECT * FROM department WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(departmentId)];
        if (resultSet.next) {
            txDepartment = [[[TXDepartment alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txDepartment;
}

- (NSArray *)queryAllDepartment:(NSError **)outError {
    __block NSMutableArray *departments = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM department";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            TXDepartment *txDepartment = [[[TXDepartment alloc] init] loadValueFromFMResultSet:resultSet];
            [departments addObject:txDepartment];
        }
    }];
    return departments;
}

- (void)addDepartment:(TXDepartment *)department error:(NSError **)outError {
    [self insertObject:department error:outError];
    return;

    /*
    NSString *sql = @"REPLACE INTO department(department_id,name,avatar_url,group_id,department_type,show_parent,created_on,updated_on) VALUES (?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(department.departmentId),
                               department.name,
                               department.avatarUrl,
                               department.groupId,
                               @(department.departmentType),
                               @(department.showParent),
                               @(TIMESTAMP_OF_NOW),
                               @(TIMESTAMP_OF_NOW)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
     */
}

- (void)deleteDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM department WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(departmentId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteDepartmentMembersByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM department_user WHERE department_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(departmentId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

@end