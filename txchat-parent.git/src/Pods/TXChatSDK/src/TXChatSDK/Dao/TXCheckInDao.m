//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXCheckInDao.h"


@implementation TXCheckInDao {

}

- (NSArray *)queryCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *checkIns = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM checkin WHERE checkin_id<? ORDER BY checkin_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxCheckInId), @(count)];
        while (resultSet.next) {
            TXCheckIn *txCheckIn = [[[TXCheckIn alloc] init] loadValueFromFMResultSet:resultSet];
            [checkIns addObject:txCheckIn];
        }
        [resultSet close];
    }];
    return checkIns;
}

- (void)addCheckIn:(TXCheckIn *)txCheckIn error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO checkin("
            "checkin_id,card_code,attaches,user_id,username,checkin_time,garden_id,machine_id,client_key,parent_name,class_name,updated_on,created_on) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (uint i = 0; i < txCheckIn.attaches.count; ++i) {
        BOOL isLast = i == txCheckIn.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txCheckIn.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txCheckIn.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txCheckIn.checkInId),
                               txCheckIn.cardCode,
                               attachesValue,
                               @(txCheckIn.userId),
                               txCheckIn.username,
                               @(txCheckIn.checkInTime),
                               @(txCheckIn.gardenId),
                               @(txCheckIn.machineId),
                               @(txCheckIn.clientKey),
                               txCheckIn.parentName,
                               txCheckIn.className,
                               @(TIMESTAMP_OF_NOW),
                               @(txCheckIn.createdOn)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}


- (TXCheckIn *)queryLastCheckIn {
    __block TXCheckIn *txCheckIn;
    NSString *sql = @"SELECT * FROM checkin ORDER BY checkin_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            txCheckIn = [[[TXCheckIn alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txCheckIn;
}

- (void)deleteAllCheckIn {
    NSString *sql = @"DELETE FROM checkin";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

@end