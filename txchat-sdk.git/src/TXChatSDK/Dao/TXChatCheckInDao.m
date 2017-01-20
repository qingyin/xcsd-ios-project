//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXChatCheckInDao.h"


@implementation TXChatCheckInDao {

}

- (void)setTXCheckInProperties:(TXCheckIn *)txCheckIn fromResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(txCheckIn);
    txCheckIn.clientKey = [resultSet longLongIntForColumn:@"client_key"];
    txCheckIn.userId = [resultSet longLongIntForColumn:@"user_id"];
    txCheckIn.username = [resultSet stringForColumn:@"username"];
    txCheckIn.gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    txCheckIn.machineId = [resultSet longLongIntForColumn:@"machine_id"];
    txCheckIn.checkInId = [resultSet longLongIntForColumn:@"checkin_id"];
    txCheckIn.checkInTime = [resultSet longLongIntForColumn:@"checkin_time"];
    txCheckIn.className = [resultSet stringForColumn:@"class_name"];
    txCheckIn.parentName = [resultSet stringForColumn:@"parent_name"];
    txCheckIn.cardCode = [resultSet stringForColumn:@"card_code"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    txCheckIn.attaches = attaches.length == 0 ? [NSMutableArray array] : [[attaches componentsSeparatedByString:@","] mutableCopy];
}

- (NSArray *)queryCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *checkIns = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM checkin WHERE checkin_id<? ORDER BY checkin_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxCheckInId), @(count)];
        while (resultSet.next) {
            TXCheckIn *txCheckIn = [[TXCheckIn alloc] init];
            [self setTXCheckInProperties:txCheckIn fromResultSet:resultSet];
            [checkIns addObject:txCheckIn];
        }
        [resultSet close];
    }];
    return checkIns;
}

@end