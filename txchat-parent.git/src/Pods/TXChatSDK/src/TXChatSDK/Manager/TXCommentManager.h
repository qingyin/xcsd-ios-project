//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXPBChat.pb.h"
#import "TXChatManagerBase.h"

@class TXApplicationManager;


@interface TXCommentManager : TXChatManagerBase

/**
* 添加评论
*/
- (void)sendComment:(NSString *)content
        commentType:(TXPBCommentType)commentType
           toUserId:(int64_t)toUserId
           targetId:(int64_t)targetId
         targetType:(TXPBTargetType)targetType
        onCompleted:(void (^)(NSError *error, int64_t commentId))onCompleted;

/**
* 删除评论
*/
- (void)deleteComment:(int64_t)commentId
          onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 发给我的评论
*/
- (void)fetchCommentsToMe:(int64_t)maxId
              onCompleted:(void (^)(NSError *error, NSArray *comments, NSArray *txFeeds, BOOL hasMore))onCompleted;

/**
* 获取目标的评论列表
*/
- (void)fetchCommentsByTargetId:(int64_t)targetId
                     targetType:(TXPBTargetType)targetType
                   maxCommentId:(int64_t)maxCommentId
                    onCompleted:(void (^)(NSError *error, NSArray *comments, BOOL hasMore))onCompleted;

/**
* 获取目标的评论列表
*/
- (void)fetchCommentsByTargetId:(int64_t)targetId
                     targetType:(TXPBTargetType)targetType
                   maxCommentId:(int64_t)maxCommentId
                   includeLikes:(BOOL)includeLikes
                    onCompleted:(void (^)(NSError *error, NSArray *comments, BOOL hasMore))onCompleted;

/**
* 从数据库中获取comment list
*/
- (NSArray *)getComments:(int64_t)targetId
              targetType:(TXPBTargetType)targetType
             commentType:(TXPBCommentType)commentType
            maxCommentId:(int64_t)maxCommentId
                   count:(int64_t)count
                   error:(NSError **)outError;


@end