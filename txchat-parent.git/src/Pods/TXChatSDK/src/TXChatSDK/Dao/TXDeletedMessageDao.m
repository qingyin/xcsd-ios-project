//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDeletedMessageDao.h"


@implementation TXDeletedMessageDao {

}
- (NSArray *)queryAllDeletedMessage {
    __block NSMutableArray *deletedMessages = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM deleted_message";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            TXDeletedMessage *txDeletedMessage = [[[TXDeletedMessage alloc] init] loadValueFromFMResultSet:resultSet];
            [deletedMessages addObject:txDeletedMessage];
        }
        [resultSet close];
    }];
    return deletedMessages;
}

- (void)addDeletedMessage:(TXDeletedMessage *)txDeletedMessage error:(NSError **)outError {
    NSString *sql = @"INSERT INTO deleted_message(msg_id,cmd_msg_id,from,to,is_group,created_on,updated_on) VALUES(?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               txDeletedMessage.msgId,
                               txDeletedMessage.cmdMsgId,
                               txDeletedMessage.fromUserId,
                               txDeletedMessage.toUserId,
                               @(txDeletedMessage.isGroup),
                               @(TIMESTAMP_OF_NOW),
                               @(TIMESTAMP_OF_NOW)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (void)deleteDeletedMessageByMsgId:(NSString *)msgId {
    NSString *sql = @"DELETE FROM deleted_message WHERE msg_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, msgId];
    }];
}

@end