//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXNoticeDao.h"


@implementation TXNoticeDao {

}
- (NSArray *)queryNotices:(int64_t)maxNoticeId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *notices = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM notice WHERE notice_id<? ORDER BY notice_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxNoticeId), @(count)];
        while (resultSet.next) {
            TXNotice *txNotice = [[[TXNotice alloc] init] loadValueFromFMResultSet:resultSet];
            [notices addObject:txNotice];
        }
        [resultSet close];
    }];
    return notices;
}

- (NSArray *)queryNotices:(int64_t)maxNoticeId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    __block NSMutableArray *notices = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM notice WHERE notice_id<? AND is_inbox=? ORDER BY notice_id DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxNoticeId), @(isInbox), @(count)];
        while (resultSet.next) {
            TXNotice *txNotice = [[[TXNotice alloc] init] loadValueFromFMResultSet:resultSet];
            [notices addObject:txNotice];
        }
        [resultSet close];
    }];
    return notices;
}


- (TXNotice *)queryNoticeById:(int64_t)id error:(NSError **)outError {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice WHERE id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(id)];
        if (resultSet.next) {
            txNotice = [[[TXNotice alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (TXNotice *)queryNoticeByNoticeId:(int64_t)noticeId error:(NSError **)outError {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice WHERE notice_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(noticeId)];
        if (resultSet.next) {
            txNotice = [[[TXNotice alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (TXNotice *)queryLastInboxNotice {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice WHERE is_inbox=1 ORDER BY notice_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            txNotice = [[[TXNotice alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (TXNotice *)queryLastNotice {
    __block TXNotice *txNotice;
    NSString *sql = @"SELECT * FROM notice ORDER BY notice_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            txNotice = [[[TXNotice alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txNotice;
}

- (void)addNotice:(TXNotice *)txNotice error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO notice(notice_id,content,attaches,from_user_id,sender_avatar,sender_name, sent_on,is_inbox,is_read,updated_on,created_on) VALUES(?,?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (uint i = 0; i < txNotice.attaches.count; ++i) {
        BOOL isLast = i == txNotice.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txNotice.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txNotice.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txNotice.noticeId),
                               txNotice.content,
                               attachesValue,
                               @(txNotice.fromUserId),
                               txNotice.senderAvatar,
                               txNotice.senderName,
                               @(txNotice.sentOn),
                               @(txNotice.isInbox),
                               @(txNotice.isRead),
                               @(TIMESTAMP_OF_NOW),
                               @(txNotice.createdOn )]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)markNoticeAsRead:(int64_t)noticeId error:(NSError **)outError {
    NSString *sql = @"UPDATE notice SET is_read=1 WHERE notice_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(noticeId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllNotice {
    NSString *sql = @"DELETE FROM notice";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteAllNotice:(BOOL)isInbox {
    NSString *sql = @"DELETE FROM notice WHERE is_inbox=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(isInbox)];
    }];
}
@end