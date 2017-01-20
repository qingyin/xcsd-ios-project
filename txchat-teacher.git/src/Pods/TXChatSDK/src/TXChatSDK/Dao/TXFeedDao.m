//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXFeedDao.h"


@implementation TXFeedDao {

}
- (NSArray *)queryFeeds:(int64_t)maxFeedId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    __block NSMutableArray *txFeeds = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM feed WHERE feed_id<? AND is_inbox=? ORDER BY created_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxFeedId), @(isInbox), @(count)];
        while (resultSet.next) {
            TXFeed *txFeed = [[[TXFeed alloc] init] loadValueFromFMResultSet:resultSet];
            [txFeeds addObject:txFeed];
        }
        [resultSet close];
    }];
    return txFeeds;
}

- (NSArray *)queryFeeds:(int64_t)maxFeedId count:(int64_t)count userId:(int64_t)userId error:(NSError **)outError {
    __block NSMutableArray *txFeeds = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM feed WHERE feed_id<? AND user_id=? ORDER BY created_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxFeedId), @(userId), @(count)];
        while (resultSet.next) {
            TXFeed *txFeed = [[[TXFeed alloc] init] loadValueFromFMResultSet:resultSet];
            [txFeeds addObject:txFeed];
        }
        [resultSet close];
    }];
    return txFeeds;
}

- (TXFeed *)getLastFeed {
    return nil;
}

- (void)addFeed:(TXFeed *)txFeed error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO feed(created_on,updated_on,feed_id,is_inbox,content,attaches,"
            "user_id,user_nick_name,user_avatar_url,user_type,feed_type) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?)";

    NSMutableArray *attaches = [NSMutableArray array];
    for (TXPBAttach *txpbAttach in txFeed.attaches) {
        [attaches addObject:@{@"type" : @(txpbAttach.attachType), @"url" : txpbAttach.fileurl}];
    }
    NSString *attachesValue = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:attaches options:0 error:nil]
                                                    encoding:NSUTF8StringEncoding];

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txFeed.createdOn),
                               @(txFeed.updatedOn),
                               @(txFeed.feedId),
                               @(txFeed.isInbox),
                               txFeed.content,
                               attachesValue,
                               @(txFeed.userId),
                               txFeed.userNickName,
                               txFeed.userAvatarUrl,
                               @(txFeed.userType),
                               @(txFeed.feedType)]
                ) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteFeedByFeedId:(int64_t)feedId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM feed WHERE feed_id=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(feedId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllFeed {
    NSString *sql = @"DELETE FROM feed";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)deleteAllFeedByUserId:(int64_t)userId {
    NSString *sql = @"DELETE FROM feed WHERE user_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(userId)];
    }];
}
@end