//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXCommentManager.h"
#import "TXApplicationManager.h"


@implementation TXCommentManager {
}

- (void)sendComment:(NSString *)content
        commentType:(TXPBCommentType)commentType
           toUserId:(int64_t)toUserId
           targetId:(int64_t)targetId
         targetType:(TXPBTargetType)targetType
        onCompleted:(void (^)(NSError *error, int64_t commentId))onCompleted {
    DDLogInfo(@"%s content=%@ commentType=%d toUserId=%lld targetId=%lld targetType=%d",
            __FUNCTION__, content, (int) commentType, toUserId, targetId, (int) targetType);

    TXPBSendCommentRequestBuilder *requestBuilder = [TXPBSendCommentRequest builder];
    requestBuilder.commentType = commentType;
    requestBuilder.toUserId = toUserId;
    requestBuilder.targetId = targetId;
    requestBuilder.targetType = targetType;
    requestBuilder.content = content;

    [[TXHttpClient sharedInstance] sendRequest:@"/send_comment"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBSendCommentResponse *txpbSendCommentResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBSendCommentResponse, txpbSendCommentResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txpbSendCommentResponse.commentId);

                                               if (!innerError && txpbSendCommentResponse.bonus > 0) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_WEI_DOU_AWARDED
                                                                                                       object:@(txpbSendCommentResponse.bonus)];
                                               }
                                           });
                                       }
                                   }];
}

- (void)deleteComment:(int64_t)commentId onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s commentId=%lld", __FUNCTION__, commentId);

    TXPBDeleteCommnetsRequestBuilder *requestBuilder = [TXPBDeleteCommnetsRequest builder];
    requestBuilder.commentId = commentId;

    [[TXHttpClient sharedInstance] sendRequest:@"/delete_comment"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.commentDao deleteCommentByCommentId:commentId error:nil];
                                       }

                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)fetchCommentsToMe:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *txComments, NSArray *txFeeds, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld", __FUNCTION__, maxId);

    TXPBFetchConcernedCommentRequestBuilder *requestBuilder = [TXPBFetchConcernedCommentRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_concerned_comment"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchConcernedCommentResponse *txpbFetchConcernedCommentResponse;
                                       NSMutableArray *txComments;
                                       NSMutableArray *txFeeds;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchConcernedCommentResponse, txpbFetchConcernedCommentResponse);

                                       txComments = [NSMutableArray array];
                                       txFeeds = [NSMutableArray array];
                                       for (TXPBFeedComment *txpbFeedComment in txpbFetchConcernedCommentResponse.feedComment) {
                                           TXComment *txComment = [[[TXComment alloc] init] loadValueFromPbObject:txpbFeedComment.comment];
                                           [txComments addObject:txComment];

                                           TXFeed *txFeed = [[[TXFeed alloc] init] loadValueFromPbObject:txpbFeedComment.feed];
                                           [txFeeds addObject:txFeed];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txComments, txFeeds, txpbFetchConcernedCommentResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchCommentsByTargetId:(int64_t)targetId
                     targetType:(TXPBTargetType)targetType
                   maxCommentId:(int64_t)maxCommentId
                    onCompleted:(void (^)(NSError *error, NSArray *comments, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s targetId=%lld targetType=%d maxCommentId=%lld", __FUNCTION__, targetId, (int) targetType, maxCommentId);

    TXPBShowCommentRequestBuilder *requestBuilder = [TXPBShowCommentRequest builder];
    requestBuilder.maxId = maxCommentId;
    requestBuilder.targetType = targetType;
    requestBuilder.targetId = targetId;

    [[TXHttpClient sharedInstance] sendRequest:@"/show_comments"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBShowCommentResponse *txpbShowCommentResponse;
                                       NSMutableArray *txComments;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBShowCommentResponse, txpbShowCommentResponse);

                                       txComments = [NSMutableArray array];
                                       for (TXPBComment *txpbComment in txpbShowCommentResponse.comment) {
                                           TXComment *txComment = [[[TXComment alloc] init] loadValueFromPbObject:txpbComment];
                                           [txComments addObject:txComment];

                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                               [[TXApplicationManager sharedInstance].currentUserDbManager.commentDao addComment:txComment error:nil];
                                           });
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txComments, txpbShowCommentResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchCommentsByTargetId:(int64_t)targetId
                     targetType:(TXPBTargetType)targetType
                   maxCommentId:(int64_t)maxCommentId
                   includeLikes:(BOOL)includeLikes
                    onCompleted:(void (^)(NSError *error, NSArray *comments, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s targetId=%lld targetType=%d maxCommentId=%lld includeLikes=%d", __FUNCTION__, targetId, (int) targetType, maxCommentId, includeLikes);

    TXPBShowCommentRequestBuilder *requestBuilder = [TXPBShowCommentRequest builder];
    requestBuilder.maxId = maxCommentId;
    requestBuilder.targetType = targetType;
    requestBuilder.targetId = targetId;

    [[TXHttpClient sharedInstance] sendRequest:@"/show_comments"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBShowCommentResponse *txpbShowCommentResponse;
                                       NSMutableArray *txComments;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBShowCommentResponse, txpbShowCommentResponse);

                                       txComments = [NSMutableArray array];
                                       for (TXPBComment *txpbComment in txpbShowCommentResponse.comment) {
                                           if (!includeLikes && txpbComment.commentType == TXPBCommentTypeLike) {
                                               continue;
                                           }
                                           TXComment *txComment = [[[TXComment alloc] init] loadValueFromPbObject:txpbComment];
                                           [txComments addObject:txComment];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txComments, txpbShowCommentResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (NSArray *)getComments:(int64_t)targetId
              targetType:(TXPBTargetType)targetType
             commentType:(TXPBCommentType)commentType
            maxCommentId:(int64_t)maxCommentId
                   count:(int64_t)count error:(NSError **)outError {
    DDLogInfo(@"%s targetId=%lld targetType=%d commentType=%d maxCommentId=%lld",
            __FUNCTION__, targetId, (int) targetType, (int) commentType, maxCommentId);

    return [[TXApplicationManager sharedInstance].currentUserDbManager.commentDao queryComments:targetId
                                                                                     targetType:targetType
                                                                                    commentType:commentType
                                                                                   maxCommentId:maxCommentId
                                                                                          count:count
                                                                                          error:outError];
}
@end