//
// Created by lingqingwan on 9/23/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXQrCheckInItemDao.h"


@implementation TXQrCheckInItemDao {

}

- (TXQrCheckInItem *)addQrCheckInItem:(TXQrCheckInItem *)txQrCheckInItem error:(NSError **)outError {
    NSString *sql = @"INSERT INTO qr_check_in_item(target_user_id,target_user_name,target_user_type,target_card_number, created_on,updated_on) "
            "VALUES(?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txQrCheckInItem.targetUserId),
                               txQrCheckInItem.targetUsername,
                               txQrCheckInItem.targetUserType,
                               txQrCheckInItem.targetCardNumber,
                               @(TIMESTAMP_OF_NOW),
                               @(TIMESTAMP_OF_NOW)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        } else {
            txQrCheckInItem.id = db.lastInsertRowId;
        }
    }];
    return txQrCheckInItem;
}

/*
- (void)deleteQrCheckInItemWithItemId:(int64_t)itemId {
    NSString *sql = @"DELETE FROM qr_check_in_item WHERE id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(itemId)];
    }];
}
 */

- (int)queryQrCheckInItemCount {
    __block int count;
    NSString *sql = @"SELECT COUNT(*) FROM qr_check_in_item WHERE status=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        count = [db intForQuery:sql, @(TXQrCheckInItemStatusUploading)];
    }];

    return count;
}

- (NSArray *)queryQrCheckInItems:(int64_t)maxId count:(int64_t)count {
    __block NSMutableArray *results = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM qr_check_in_item WHERE id<? ORDER BY id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxId), @(count)];
        while (resultSet.next) {
            TXQrCheckInItem *txQrCheckInItem = [[[TXQrCheckInItem alloc] init] loadValueFromFMResultSet:resultSet];
            [results addObject:txQrCheckInItem];
        }
        [resultSet close];
    }];
    return results;
}

- (NSArray *)queryUploadRequiredQrCheckInItems {
    __block NSMutableArray *results = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM qr_check_in_item WHERE status!=? ";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(TXQrCheckInItemStatusUploadSucceed)];
        while (resultSet.next) {
            TXQrCheckInItem *txQrCheckInItem = [[[TXQrCheckInItem alloc] init] loadValueFromFMResultSet:resultSet];
            [results addObject:txQrCheckInItem];
        }
        [resultSet close];
    }];
    return results;
}

- (void)updateStatus:(int64_t)itemId newStatus:(TXQrCheckInItemStatus)newStatus {
    NSString *sql = @"UPDATE qr_check_in_item SET status=? WHERE id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(newStatus), @(itemId)];
    }];
}

- (void)deleteAllSucceedItems {
    NSString *sql = @"DELETE FROM qr_check_in_item WHERE status=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(TXQrCheckInItemStatusUploadSucceed)];
    }];
}


@end