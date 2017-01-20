//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXPBChat.pb.h"
#import "TXChatManagerBase.h"


@interface TXPostManager : TXChatManagerBase

/**
* 公告 活动 微学院
*/
- (void)fetchPosts:(int64_t)maxId
          gardenId:(int64_t)gardenId
          postType:(TXPBPostType)postType
       onCompleted:(void (^)(NSError *error, NSArray *posts, BOOL hasMore))onCompleted;

/**
*微学园列表
*/
- (void)fetchPostGroups:(int64_t)maxId
               gardenId:(int64_t)gardenId //0表示获取土星官方公众号post
            onCompleted:(void (^)(NSError *error, NSArray *postGroups, BOOL hasMore))onCompleted;

/**
 * 获取post详情
 */
- (void)fetchPostDetail:(int64_t)postId
               postType:(TXPBPostType)postType
            onCompleted:(void (^)(NSError *error, NSString *htmlContent))onCompleted;


- (TXPost *)queryLastPost:(TXPBPostType)postType
                 gardenId:(int64_t)gardenId
                    error:(NSError **)outError;

- (NSArray *)queryPosts:(TXPBPostType)postType
              maxPostId:(int64_t)maxPostId
               gardenId:(int64_t)gardenId
                  count:(int64_t)count
                  error:(NSError **)outError;

- (TXPost *)getLastPost:(TXPBPostType)postType error:(NSError **)outError;

- (NSArray *)getPosts:(TXPBPostType)postType
            maxPostId:(int64_t)maxPostId
                count:(int64_t)count error:(NSError **)outError;

- (void)markPostAsReadWithPostId:(int64_t)postId;

@end