//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"


@interface TXFeedManager : TXChatManagerBase

/**
* 发布亲子圈
*/
- (void)     sendFeed:(NSString *)content
             attaches:(NSArray *)attaches
        departmentIds:(NSArray *)departmentIds
syncToDepartmentPhoto:(BOOL)syncToDepartmentPhoto
          onCompleted:(void (^)(NSError *error))onCompleted;

/**
*
*/
- (void)fetchFeedsWithDepartmentId:(int64_t)departmentId
                             maxId:(int64_t)maxId
                           isInbox:(BOOL)isInbox
                       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted;

/**
* 获取亲子圈
*/
- (void)fetchFeeds:(int64_t)maxId
           isInbox:(BOOL)isInbox
       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted;

/**
* 从数据库中获取feed list
*/
- (NSArray *)getFeeds:(int64_t)maxFeedId
                count:(int64_t)count
              isInbox:(BOOL)isInbox
                error:(NSError **)outError;

/**
* 从数据库中获取feed list
*/
- (NSArray *)getFeeds:(int64_t)maxFeedId
                count:(int64_t)count
               userId:(int64_t)userId
                error:(NSError **)outError;

/**
* 获取指定用户的亲子圈
*/
- (void)fetchFeeds:(int64_t)maxId
            userId:(int64_t)userId
       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted;

/**
* 删除自己的亲子圈
*/
- (void)deleteFeed:(int64_t)feedId
       onCompleted:(void (^)(NSError *error))onCompleted;

- (void)blockActivityFeedWithFeedId:(int64_t)feedId;

@end