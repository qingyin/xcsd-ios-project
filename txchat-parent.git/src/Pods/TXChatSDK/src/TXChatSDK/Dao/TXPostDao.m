//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXPostDao.h"


@implementation TXPostDao {

}
- (TXPost *)queryLastPost:(TXPBPostType)postType error:(NSError **)outError {
    __block TXPost *txPost;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? ORDER BY id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType)];
        if (resultSet.next) {
            txPost = [[[TXPost alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txPost;
}

- (void)addPost:(TXPost *)txPost error:(NSError **)outError {
    NSString *sql = @"REPLACE INTO post(updated_on,created_on,post_id,title,summary,content,cover_image_url,post_type,group_id,order_value,post_url,garden_id) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        if (![db executeUpdate:sql
          withErrorAndBindings:outError,
                               @(txPost.updatedOn),
                               @(txPost.createdOn),
                               @(txPost.postId),
                               txPost.title,
                               txPost.summary,
                               txPost.content,
                               txPost.coverImageUrl,
                               @(txPost.postType),
                               @(txPost.groupId),
                               @(txPost.orderValue),
                               txPost.postUrl,
                               @(txPost.gardenId)
        ]) {
            FILL_OUT_ERROR_IF_NULL(sql);
        }
    }];
}

- (TXPost *)queryLastPost:(TXPBPostType)postType gardenId:(int64_t)gardenId error:(NSError **)outError {
    __block TXPost *txPost;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND garden_id=? ORDER BY id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType),@(gardenId)];
        if (resultSet.next) {
            txPost = [[[TXPost alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txPost;
}

- (NSArray *)queryPosts:(TXPBPostType)postType
              maxPostId:(int64_t)maxPostId
                  count:(int64_t)count
               gardenId:(int64_t)gardenId
                  error:(NSError **)outError {
    __block NSMutableArray *posts = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND post_id<? AND garden_id=? ORDER BY created_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql,
                                                  @(postType),
                                                  @(maxPostId),
                        @(gardenId),
                                                  @(count)
                        ];
        while (resultSet.next) {
            TXPost *txPost = [[[TXPost alloc] init] loadValueFromFMResultSet:resultSet];
            [posts addObject:txPost];
        }
        [resultSet close];
    }];
    return posts;
}

- (int64_t)queryLastGroupId:(TXPBPostType)postType gardenId:(int64_t)gardenId error:(NSError **)outError {
    __block int64_t groupId;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND garden_id=? ORDER BY group_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType),@(gardenId)];
        if (resultSet.next) {
            groupId = [resultSet longLongIntForColumn:@"group_id"];
        }
        [resultSet close];
    }];
    return groupId;
}

- (TXPost *)queryLastPostOfGroup:(TXPBPostType)postType groupId:(int64_t)groupId gardenId:(int64_t)gardenId error:(NSError **)outError {
    __block TXPost *txPost;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND group_id=? AND garden_id=? ORDER BY order_value ASC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType), @(groupId),@(gardenId)];
        if (resultSet.next) {
            txPost = [[[TXPost alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txPost;
}


- (NSArray *)queryPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError {
    __block NSMutableArray *posts = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND post_id<? ORDER BY created_on DESC LIMIT 0,?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql,
                                                  @(postType),
                                                  @(maxPostId),
                                                  @(count)];
        while (resultSet.next) {
            TXPost *txPost = [[[TXPost alloc] init] loadValueFromFMResultSet:resultSet];
            [posts addObject:txPost];
        }
        [resultSet close];
    }];
    return posts;
}

- (int64_t)queryLastGroupId:(TXPBPostType)postType error:(NSError **)outError {
    __block int64_t groupId;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? ORDER BY group_id DESC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType)];
        if (resultSet.next) {
            groupId = [resultSet longLongIntForColumn:@"group_id"];
        }
        [resultSet close];
    }];
    return groupId;
}

- (TXPost *)queryLastPostOfGroup:(TXPBPostType)postType groupId:(int64_t)groupId error:(NSError **)outError {
    __block TXPost *txPost;
    NSString *sql = @"SELECT * FROM post WHERE post_type=? AND group_id=? ORDER BY order_value ASC LIMIT 0,1";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql, @(postType), @(groupId)];
        if (resultSet.next) {
            txPost = [[[TXPost alloc] init] loadValueFromFMResultSet:resultSet];
        }
        [resultSet close];
    }];
    return txPost;
}

- (void)deleteAllPostByType:(TXPBPostType)txpbPostType {
    NSString *sql = @"DELETE FROM post where post_type=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(txpbPostType)];
    }];
}

- (void)deletePostByType:(TXPBPostType)txpbPostType gardenId:(int64_t)gardenId {
    NSString *sql = @"DELETE FROM post where post_type=? AND garden_id=?";

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql, @(txpbPostType),@(gardenId)];
    }];
}


@end