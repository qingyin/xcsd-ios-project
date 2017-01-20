//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXFeedManager.h"
#import "TXApplicationManager.h"

@implementation TXFeedManager {
}

- (void)     sendFeed:(NSString *)content
             attaches:(NSArray *)attaches
        departmentIds:(NSArray *)departmentIds
syncToDepartmentPhoto:(BOOL)syncToDepartmentPhoto
          onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s content=%@ attaches=%@ departmentIds=%@ syncToDepartmentPhoto=%d", __FUNCTION__, content, attaches, departmentIds, syncToDepartmentPhoto);

    TXPBSendFeedRequestBuilder *requestBuilder = [TXPBSendFeedRequest builder];
    requestBuilder.content = content;
    [requestBuilder setDepartmentIdsArray:departmentIds];
    [requestBuilder setAttachesArray:attaches];
    requestBuilder.syncDepartmentPhoto = syncToDepartmentPhoto;

    [[TXHttpClient sharedInstance] sendRequest:@"/send_feed"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBSendFeedResponse *txpbSendFeedResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBSendFeedResponse, txpbSendFeedResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);

                                               if (!innerError && txpbSendFeedResponse.bonus > 0) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_WEI_DOU_AWARDED
                                                                                                       object:@(txpbSendFeedResponse.bonus)];
                                               }
                                           });
                                       }
                                   }];
}

- (void)fetchFeedsWithDepartmentId:(int64_t)departmentId
                             maxId:(int64_t)maxId
                           isInbox:(BOOL)isInbox
                       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s departmentId=%lld maxId=%lld isInbox=%d", __FUNCTION__, departmentId, maxId, isInbox);

    TXPBFetchFeedRequestBuilder *requestBuilder = [TXPBFetchFeedRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;
    requestBuilder.isInbox = isInbox;
    requestBuilder.departmentId = departmentId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_feed"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchFeedResponse *txpbFetchFeedResponse;
                                       NSMutableArray *txFeeds;
                                       NSMutableDictionary *txLikesDictionary;
                                       NSMutableDictionary *txCommentsDictionary;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchFeedResponse, txpbFetchFeedResponse);

                                       txFeeds = [NSMutableArray array];
                                       txLikesDictionary = [NSMutableDictionary dictionary];
                                       txCommentsDictionary = [NSMutableDictionary dictionary];

                                       for (TXPBFeed *txpbFeed in txpbFetchFeedResponse.feeds) {
                                           TXFeed *txFeed = [[[TXFeed alloc] init] loadValueFromPbObject:txpbFeed];
                                           txFeed.isInbox = isInbox;
                                           [txFeeds addObject:txFeed];

                                           NSMutableArray *txComments = [NSMutableArray array];
                                           for (TXPBComment *txpbComment in txpbFeed.comments) {
                                               TXComment *txComment = [[[TXComment alloc] init] loadValueFromPbObject:txpbComment];
                                               [txComments addObject:txComment];
                                           }
                                           txCommentsDictionary[@(txpbFeed.id)] = txComments;

                                           NSMutableArray *txLikes = [NSMutableArray array];
                                           for (TXPBLike *txpbLike in txpbFeed.likes) {
                                               TXComment *txComment = [[TXComment alloc] init];
                                               txComment.commentId = txpbLike.commentId;
                                               txComment.userId = txpbLike.userId;
                                               txComment.userNickname = txpbLike.nickName;
                                               txComment.targetId = txpbLike.targetId;
                                               txComment.userAvatarUrl = txpbLike.userAvatarUrl;
                                               txComment.targetType = TXPBTargetTypeFeed;
                                               txComment.commentType = TXPBCommentTypeLike;
                                               [txLikes addObject:txComment];
                                           }
                                           txLikesDictionary[@(txpbFeed.id)] = txLikes;
                                       }

                                       if (LLONG_MAX == maxId && txpbFetchFeedResponse.hasActivity) {
                                           NSString *settingKey = [NSString stringWithFormat:@"blocked-activity-id-%lld", txpbFetchFeedResponse.activity.id];
                                           if (![[TXApplicationManager sharedInstance].currentUserDbManager.settingDao querySettingValueByKey:settingKey]) {
                                               TXFeed *activityFeed = [[TXFeed alloc] init];
                                               activityFeed.id = LLONG_MAX;
                                               activityFeed.feedId = txpbFetchFeedResponse.activity.id;
                                               activityFeed.content = txpbFetchFeedResponse.activity.title;
                                               activityFeed.attaches = [NSMutableArray array];
                                               for (NSString *picUrl in txpbFetchFeedResponse.activity.picUrl) {
                                                   TXPBAttachBuilder *txpbAttachBuilder = [[[TXPBAttach builder] setAttachType:TXPBAttachTypePic] setFileurl:picUrl];
                                                   [activityFeed.attaches addObject:[txpbAttachBuilder build]];
                                               }
                                               activityFeed.userId = 0;
                                               activityFeed.userNickName = txpbFetchFeedResponse.activity.nickname;
                                               activityFeed.userAvatarUrl = txpbFetchFeedResponse.activity.avatarUrl;
                                               activityFeed.createdOn = (int64_t) (TIMESTAMP_OF_NOW);
                                               activityFeed.feedType = TXFeedTypeActivity;
                                               activityFeed.activityUrl = txpbFetchFeedResponse.activity.url;
                                               [txFeeds addObject:activityFeed];
                                           }
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txFeeds, txLikesDictionary, txCommentsDictionary, txpbFetchFeedResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchFeeds:(int64_t)maxId
           isInbox:(BOOL)isInbox
       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld isInbox=%d", __FUNCTION__, maxId, isInbox);

    TXPBFetchFeedRequestBuilder *requestBuilder = [TXPBFetchFeedRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;
    requestBuilder.isInbox = isInbox;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_feed"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchFeedResponse *txpbFetchFeedResponse;
                                       NSMutableArray *txFeeds;
                                       NSMutableDictionary *txLikesDictionary;
                                       NSMutableDictionary *txCommentsDictionary;
                                       BOOL writeToDb = LLONG_MAX == maxId;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchFeedResponse, txpbFetchFeedResponse);

                                       txFeeds = [NSMutableArray array];
                                       txLikesDictionary = [NSMutableDictionary dictionary];
                                       txCommentsDictionary = [NSMutableDictionary dictionary];

                                       if (writeToDb) {
                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                               [[TXApplicationManager sharedInstance].currentUserDbManager.feedDao deleteAllFeed];
                                           });
                                       }

                                       for (TXPBFeed *txpbFeed in txpbFetchFeedResponse.feeds) {
                                           TXFeed *txFeed = [[[TXFeed alloc] init] loadValueFromPbObject:txpbFeed];
                                           txFeed.isInbox = isInbox;
                                           [txFeeds addObject:txFeed];

                                           if (writeToDb) {
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.feedDao addFeed:txFeed error:nil];
                                               });
                                           }

                                           NSMutableArray *txComments = [NSMutableArray array];
                                           for (TXPBComment *txpbComment in txpbFeed.comments) {
                                               TXComment *txComment = [[[TXComment alloc] init] loadValueFromPbObject:txpbComment];
                                               [txComments addObject:txComment];

                                               if (writeToDb) {
                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                       [[TXApplicationManager sharedInstance].currentUserDbManager.commentDao addComment:txComment error:nil];
                                                   });
                                               }
                                           }
                                           txCommentsDictionary[@(txpbFeed.id)] = txComments;

                                           NSMutableArray *txLikes = [NSMutableArray array];
                                           for (TXPBLike *txpbLike in txpbFeed.likes) {
                                               TXComment *txComment = [[TXComment alloc] init];
                                               txComment.commentId = txpbLike.commentId;
                                               txComment.userId = txpbLike.userId;
                                               txComment.userNickname = txpbLike.nickName;
                                               txComment.targetId = txpbLike.targetId;
                                               txComment.userAvatarUrl = txpbLike.userAvatarUrl;
                                               txComment.targetType = TXPBTargetTypeFeed;
                                               txComment.commentType = TXPBCommentTypeLike;
                                               [txLikes addObject:txComment];

                                               if (writeToDb) {
                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                       [[TXApplicationManager sharedInstance].currentUserDbManager.commentDao addComment:txComment error:nil];
                                                   });
                                               }
                                           }
                                           txLikesDictionary[@(txpbFeed.id)] = txLikes;
                                       }

                                       if (LLONG_MAX == maxId && txpbFetchFeedResponse.hasActivity) {
                                           NSString *settingKey = [NSString stringWithFormat:@"blocked-activity-id-%lld", txpbFetchFeedResponse.activity.id];
                                           if (![[TXApplicationManager sharedInstance].currentUserDbManager.settingDao querySettingValueByKey:settingKey]) {
                                               TXFeed *activityFeed = [[TXFeed alloc] init];
                                               activityFeed.id = LLONG_MAX;
                                               activityFeed.feedId = txpbFetchFeedResponse.activity.id;
                                               activityFeed.content = txpbFetchFeedResponse.activity.title;
                                               activityFeed.attaches = [NSMutableArray array];
                                               for (NSString *picUrl in txpbFetchFeedResponse.activity.picUrl) {
                                                   TXPBAttachBuilder *txpbAttachBuilder = [[[TXPBAttach builder] setAttachType:TXPBAttachTypePic] setFileurl:picUrl];
                                                   [activityFeed.attaches addObject:[txpbAttachBuilder build]];
                                               }
                                               activityFeed.userId = 0;
                                               activityFeed.userNickName = txpbFetchFeedResponse.activity.nickname;
                                               activityFeed.userAvatarUrl = txpbFetchFeedResponse.activity.avatarUrl;
                                               activityFeed.createdOn = (int64_t) (TIMESTAMP_OF_NOW);
                                               activityFeed.feedType = TXFeedTypeActivity;
                                               activityFeed.activityUrl = txpbFetchFeedResponse.activity.url;
                                               [txFeeds addObject:activityFeed];
                                           }
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, txFeeds, txLikesDictionary, txCommentsDictionary, txpbFetchFeedResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    DDLogInfo(@"%s maxFeedId=%lld count=%lld isInbox=%d", __FUNCTION__, maxFeedId, count, isInbox);

    return [[TXApplicationManager sharedInstance].currentUserDbManager.feedDao
            queryFeeds:maxFeedId
                 count:count
               isInbox:isInbox
                 error:outError];
}

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count userId:(int64_t)userId error:(NSError **)outError {
    DDLogInfo(@"%s maxFeedId=%lld count=%lld userId=%lld", __FUNCTION__, maxFeedId, count, userId);

    return [[TXApplicationManager sharedInstance].currentUserDbManager.feedDao
            queryFeeds:maxFeedId
                 count:count
                userId:userId
                 error:outError];
}

- (void)fetchFeeds:(int64_t)maxId
            userId:(int64_t)userId
       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld userId=%lld", __FUNCTION__, maxId, userId);

    TXPBFetchUserFeedRequestBuilder *requestBuilder = [TXPBFetchUserFeedRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;
    requestBuilder.userId = userId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_user_feed"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchUserFeedResponse *txpbFetchUserFeedResponse;
                                       NSMutableArray *txFeeds;
                                       NSMutableDictionary *txLikesDictionary;
                                       NSMutableDictionary *txCommentsDictionary;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchUserFeedResponse, txpbFetchUserFeedResponse);

                                       txFeeds = [NSMutableArray array];
                                       txLikesDictionary = [NSMutableDictionary dictionary];
                                       txCommentsDictionary = [NSMutableDictionary dictionary];

                                       for (TXPBFeed *txpbFeed in txpbFetchUserFeedResponse.feeds) {
                                           TXFeed *txFeed = [[[TXFeed alloc] init] loadValueFromPbObject:txpbFeed];
                                           [txFeeds addObject:txFeed];

                                           NSMutableArray *txComments = [NSMutableArray array];
                                           for (TXPBComment *txpbComment in txpbFeed.comments) {
                                               TXComment *txComment = [[[TXComment alloc] init] loadValueFromPbObject:txpbComment];
                                               [txComments addObject:txComment];
                                           }
                                           txCommentsDictionary[@(txpbFeed.id)] = txComments;

                                           NSMutableArray *txLikes = [NSMutableArray array];
                                           for (TXPBLike *txpbLike in txpbFeed.likes) {
                                               TXComment *txComment = [[TXComment alloc] init];
                                               txComment.commentId = txpbLike.commentId;
                                               txComment.userId = txpbLike.userId;
                                               txComment.userNickname = txpbLike.nickName;
                                               txComment.targetId = txpbLike.targetId;
                                               txComment.userAvatarUrl = txpbLike.userAvatarUrl;
                                               txComment.targetType = TXPBTargetTypeFeed;
                                               txComment.commentType = TXPBCommentTypeLike;
                                               [txLikes addObject:txComment];
                                           }
                                           txLikesDictionary[@(txpbFeed.id)] = txLikes;
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txFeeds, txLikesDictionary, txCommentsDictionary, txpbFetchUserFeedResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)deleteFeed:(int64_t)feedId onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s feedId=%lld", __FUNCTION__, feedId);

    TXPBDeleteFeedRequestBuilder *requestBuilder = [TXPBDeleteFeedRequest builder];
    requestBuilder.feedId = feedId;

    [[TXHttpClient sharedInstance] sendRequest:@"/delete_feed"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       [[TXApplicationManager sharedInstance].currentUserDbManager.feedDao deleteFeedByFeedId:feedId error:nil];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)blockActivityFeedWithFeedId:(int64_t)feedId {
    DDLogInfo(@"%s feedId=%lld", __FUNCTION__, feedId);

    NSError *error;
    NSString *settingKey = [NSString stringWithFormat:@"blocked-activity-id-%lld", feedId];

    if (![[[[TXApplicationManager sharedInstance] currentUserDbManager] settingDao] querySettingValueByKey:settingKey]) {
        [[[[TXApplicationManager sharedInstance] currentUserDbManager] settingDao] saveSettingValue:@""
                                                                                             forKey:settingKey
                                                                                              error:&error];
    }
}

@end