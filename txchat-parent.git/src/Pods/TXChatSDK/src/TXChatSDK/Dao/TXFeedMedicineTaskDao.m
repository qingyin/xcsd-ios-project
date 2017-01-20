//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXFeedMedicineTaskDao.h"


@implementation TXFeedMedicineTaskDao {

}
- (NSArray *)queryFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *tasks = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM feed_medicine_task WHERE feed_medicine_task_id<? ORDER BY updated_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(maxId), @(count)];
        while (resultSet.next) {
            TXFeedMedicineTask *txFeedMedicineTask = [[[TXFeedMedicineTask alloc] init] loadValueFromFMResultSet:resultSet];
            [tasks addObject:txFeedMedicineTask];
        }
        [resultSet close];
    }];
    return tasks;
}

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId error:(NSError **)outError {
    NSString *sql = @"UPDATE feed_medicine_task SET is_read=1 WHERE feed_medicine_task_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(feedMedicineTaskId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteAllFeedMedicineTask {
    NSString *sql = @"DELETE FROM feed_medicine_task";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

- (void)addFeedMedicineTask:(TXFeedMedicineTask *)txFeedMedicineTask error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO feed_medicine_task"
            "(updated_on,created_on,feed_medicine_task_id,content,attaches,"
            "parent_user_id,parent_user_name,parent_user_avatar_url,"
            "class_id,class_name,class_avatar_url,begin_date,is_read) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

    NSString *attachesValue = @"";
    for (uint i = 0; i < txFeedMedicineTask.attaches.count; ++i) {
        BOOL isLast = i == txFeedMedicineTask.attaches.count - 1;
        attachesValue = isLast
                ? [attachesValue stringByAppendingFormat:@"%@", txFeedMedicineTask.attaches[i]]
                : [attachesValue stringByAppendingFormat:@"%@,", txFeedMedicineTask.attaches[i]];
    }

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txFeedMedicineTask.updatedOn),
                               @(txFeedMedicineTask.createdOn),
                               @(txFeedMedicineTask.feedMedicineTaskId),
                               txFeedMedicineTask.content,
                               attachesValue,
                               @(txFeedMedicineTask.parentUserId),
                               txFeedMedicineTask.parentUsername,
                               txFeedMedicineTask.parentAvatarUrl,
                               @(txFeedMedicineTask.classId),
                               txFeedMedicineTask.className,
                               txFeedMedicineTask.classAvatarUrl,
                               @(txFeedMedicineTask.beginDate),
                               @(txFeedMedicineTask.isRead)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

@end