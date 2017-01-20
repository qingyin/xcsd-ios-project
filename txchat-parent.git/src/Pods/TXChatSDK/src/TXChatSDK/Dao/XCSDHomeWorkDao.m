//
//  XCSDHomeWorkDao.m
//  Pods
//
//  Created by gaoju on 16/3/15.
//
//

#import "XCSDHomeWorkDao.h"

@implementation XCSDHomeWorkDao{
    
}
- (NSArray *)queryHomeWork:(int64_t)maxhomeWorkId count:(int64_t)count error:(NSError **)outError{
    __block NSMutableArray *homeWorks = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM homeWork WHERE homeWorkId<? ORDER BY homeWorkId DESC LIMIT 0,?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxhomeWorkId), @(count)];
        while (resultSet.next) {
            XCSDHomeWork *homeWork = [[[XCSDHomeWork alloc] init] loadValueFromFMResultSet:resultSet];
            [homeWorks addObject:homeWork];
        }
        [resultSet close];
    }];
    return homeWorks;
}

- (void)addHomeWork:(XCSDHomeWork *)homeWork error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO HomeWork("
    "homeWorkId, memberId, title, sendUserId, senderName, senderAvatar, targetName, status, hasRead, sendTime,updated_on,created_on) "
    "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
              @(homeWork.HomeWorkId),
              @(homeWork.memberId),
              homeWork.title,
              @(homeWork.sendUserId),
              homeWork.senderName,
              homeWork.senderAvatar,
              homeWork.targetName,
              @(homeWork.status),
              @(homeWork.hasRead),
              @(homeWork.sendTime),
              @(TIMESTAMP_OF_NOW),
              @(homeWork.sendTime )]
            ) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}


- (XCSDHomeWork *)queryLastHomework:(NSError **)outError;
 {
    __block XCSDHomeWork *homeWork;
    NSString *sql = @"SELECT * FROM homeWork ORDER BY homeWorkId DESC LIMIT 0,1";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        if (resultSet.next) {
            homeWork = [[[XCSDHomeWork alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return homeWork;
}

- (void)markHomeworkAsRead:(int64_t)homeworkId error:(NSError **)outError {
    NSString *sql = @"UPDATE homeWork SET hasRead=1 WHERE homeWorkId=?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(homeworkId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllHomework {
    NSString *sql = @"DELETE FROM homeWork";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}
- (void)deleteAllHomework:(BOOL)isInbox {
    NSString *sql = @"DELETE FROM homeWork WHERE is_inbox=?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(isInbox)];
    }];
}
-(void)deleteHomework:(int64_t)homeWorkId {
    NSString *sql = @"DELETE FROM homeWork WHERE homeWorkId=?";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(homeWorkId)];
    }];
}
@end
