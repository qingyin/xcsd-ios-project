//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXPost.h"
#import "TXChatDaoBase.h"


@interface TXPostDao : TXChatDaoBase
- (void)addPost:(TXPost *)txPost error:(NSError **)outError;

- (TXPost *)queryLastPost:(TXPBPostType)postType gardenId:(int64_t)gardenId error:(NSError **)outError;

- (TXPost *)queryLastPost:(TXPBPostType)postType error:(NSError **)outError;

- (NSArray *)queryPosts:(TXPBPostType)postType
              maxPostId:(int64_t)maxPostId
                  count:(int64_t)count
               gardenId:(int64_t)gardenId
                  error:(NSError **)outError;

- (NSArray *)queryPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError;

- (int64_t)queryLastGroupId:(TXPBPostType)postType gardenId:(int64_t)gardenId error:(NSError **)outError;

- (int64_t)queryLastGroupId:(TXPBPostType)postType error:(NSError **)outError;

- (TXPost *)queryLastPostOfGroup:(TXPBPostType)postType groupId:(int64_t)groupId gardenId:(int64_t)gardenId error:(NSError **)outError;

- (TXPost *)queryLastPostOfGroup:(TXPBPostType)postType groupId:(int64_t)groupId error:(NSError **)outError;

- (void)deleteAllPostByType:(TXPBPostType)txpbPostType;

- (void)deletePostByType:(TXPBPostType)txpbPostType gardenId:(int64_t)gardenId;

@end