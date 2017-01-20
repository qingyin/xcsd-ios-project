//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXComment.h"
#import "TXChatDaoBase.h"

@interface TXCommentDao : TXChatDaoBase

- (NSArray *)queryComments:(int64_t)targetId targetType:(TXPBTargetType)targetType commentType:(TXPBCommentType)commentType maxCommentId:(int64_t)maxCommentId count:(int64_t)count error:(NSError **)outError;

- (void)deleteCommentByCommentId:(int64_t)commentId error:(NSError **)outError;

- (void)addComment:(TXComment *)txComment error:(NSError **)outError;
@end