//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXGardenMailDao.h"


@implementation TXGardenMailDao {

}

- (NSArray *)queryGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *mails = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM garden_mail WHERE garden_mail_id<? ORDER BY updated_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxId), @(count)];
        while (resultSet.next) {
            TXGardenMail *txGardenMail = [[[TXGardenMail alloc] init] loadValueFromFMResultSet:resultSet];
            [mails addObject:txGardenMail];
        }
        [resultSet close];
    }];
    return mails;
}

- (void)markGardenMailAsRead:(int64_t)gardenMailId error:(NSError **)outError {
    NSString *sql = @"UPDATE garden_mail SET is_read=1 WHERE garden_mail_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(gardenMailId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllGardenMail {
    NSString *sql = @"DELETE FROM garden_mail";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)addGardenMail:(TXGardenMail *)txGardenMail error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO garden_mail(updated_on,created_on,garden_mail_id,garden_id,garden_name,garden_avatar_url,content,is_anonymous,from_user_id,from_user_name,from_user_avatar_url,is_read) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txGardenMail.updatedOn),
                               @(txGardenMail.createdOn),
                               @(txGardenMail.gardenMailId),
                               @(txGardenMail.gardenMailId),
                               txGardenMail.gardenName,
                               txGardenMail.gardenAvatarUrl,
                               txGardenMail.content,
                               @(txGardenMail.isAnonymous),
                               @(txGardenMail.fromUserId),
                               txGardenMail.fromUsername,
                               txGardenMail.fromUserAvatarUrl,
                               @(txGardenMail.isRead)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

@end