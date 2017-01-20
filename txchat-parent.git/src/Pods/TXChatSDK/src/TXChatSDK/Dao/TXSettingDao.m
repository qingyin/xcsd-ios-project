//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXSettingDao.h"


@implementation TXSettingDao {

}
- (void)saveSettingValue:(NSString *)value forKey:(NSString *)key error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO setting(key,value) VALUES(?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, key, value]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (NSString *)querySettingValueByKey:(NSString *)key {
    __block NSString *value = nil;
    NSString *sql = @"SELECT * FROM setting WHERE key=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, key];
        if (resultSet.next) {
            value = [resultSet stringForColumn:@"value"];
        }
        [resultSet close];
    }];
    return value;
}
@end