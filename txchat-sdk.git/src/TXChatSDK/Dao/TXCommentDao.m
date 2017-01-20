//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXCommentDao.h"


@implementation TXCommentDao {

}
- (NSArray *)queryComments:(int64_t)targetId targetType:(TXPBTargetType)targetType
               commentType:(TXPBCommentType)commentType maxCommentId:(int64_t)maxCommentId
                     count:(int64_t)count
                     error:(NSError **)outError {
    __block NSMutableArray *txComments = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM comment WHERE target_id=? AND target_type=? AND comment_type=? AND comment_id<? ORDER BY comment_id ASC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql,
                                                  @(targetId),
                                                  @(targetType),
                                                  @(commentType),
                                                  @(maxCommentId),
                                                  @(count)];
        while (resultSet.next) {
            TXComment *txComment = [[[TXComment alloc] init] loadValueFromFMResultSet:resultSet];
            [txComments addObject:txComment];
        }
        [resultSet close];
    }];
    return txComments;
}

- (void)deleteCommentByCommentId:(int64_t)commentId error:(NSError **)outError {
    NSString *sql = @"DELETE FROM comment WHERE comment_id=?";
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql withErrorAndBindings:outError, @(commentId)]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}


- (void)addComment:(TXComment *)txComment error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO comment(created_on,updated_on,comment_id,content,comment_type,target_id,target_user_id,target_type,to_user_id,to_user_nickname,user_id,user_nickname,user_avatar_url) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txComment.createdOn),
                               @(TIMESTAMP_OF_NOW),
                               @(txComment.commentId),
                               txComment.content,
                               @(txComment.commentType),
                               @(txComment.targetId),
                               @(txComment.targetUserId),
                               @(txComment.targetType),
                               @(txComment.toUserId),
                               txComment.toUserNickname,
                               @(txComment.userId),
                               txComment.userNickname,
                               txComment.userAvatarUrl]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}
@end