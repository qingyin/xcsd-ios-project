//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXPostManager.h"
#import "TXApplicationManager.h"
#import "TXChatClient.h"


@implementation TXPostManager {
}

- (void)fetchPosts:(int64_t)maxId
          gardenId:(int64_t)gardenId
          postType:(TXPBPostType)postType
       onCompleted:(void (^)(NSError *error, NSArray *posts, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld gardenId=%lld postType=%d", __FUNCTION__, maxId, gardenId, (int) postType);

    TXPBFetchPostRequestBuilder *requestBuilder = [TXPBFetchPostRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;
    requestBuilder.gardenId = gardenId;
    requestBuilder.postType = postType;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_post"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchPostResponse *txpbFetchPostResponse;
                                       NSMutableArray *txPosts;
                                       BOOL writeToDb = LLONG_MAX == maxId;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchPostResponse, txpbFetchPostResponse);

                                       if (writeToDb) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.postDao deleteAllPostByType:postType];
                                       }

                                       txPosts = [NSMutableArray array];
                                       for (TXPBPost *txpbPost in  txpbFetchPostResponse.post) {
                                           TXPost *txPost = [[[TXPost alloc] init] loadValueFromPbObject:txpbPost groupId:-1];
                                           txPost.gardenId = gardenId;
                                           txPost.isRead = [[TXChatClient sharedInstance].userManager querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                                                                                                             error:nil];

                                           if (writeToDb) {
                                               [[TXApplicationManager sharedInstance].currentUserDbManager.postDao addPost:txPost error:nil];
                                           }

                                           [txPosts addObject:txPost];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, txPosts, txpbFetchPostResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchPostGroups:(int64_t)maxId
               gardenId:(int64_t)gardenId
            onCompleted:(void (^)(NSError *error, NSArray *postGroups, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld gardenId=%lld", __FUNCTION__, maxId, gardenId);

    TXPBFetchPostGroupRequestBuilder *requestBuilder = [TXPBFetchPostGroupRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;
    requestBuilder.gardenId = gardenId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_postgroup"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchPostGroupResponse *txpbFetchPostGroupResponse;
                                       NSMutableArray *txPosts;
                                       BOOL writeToDb = LLONG_MAX == maxId;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchPostGroupResponse, txpbFetchPostGroupResponse);

                                       if (writeToDb) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.postDao deletePostByType:TXPBPostTypeLerngarden
                                                                                                                       gardenId:gardenId];
                                       }

                                       txPosts = [NSMutableArray array];
                                       for (TXPBPostGroup *txpbPostGroup in  txpbFetchPostGroupResponse.postGroup) {
                                           for (TXPBPost *txpbPost in txpbPostGroup.post) {
                                               TXPost *txPost = [[[TXPost alloc] init] loadValueFromPbObject:txpbPost groupId:txpbPostGroup.id];
                                               txPost.gardenId = gardenId;
                                               txPost.isRead = [[TXChatClient sharedInstance].userManager querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                                                                                                                 error:nil];

                                               if (writeToDb) {
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.postDao addPost:txPost error:nil];
                                               }

                                               [txPosts addObject:txPost];
                                           }
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, txPosts, txpbFetchPostGroupResponse.hasMore);
                                           );
                                       }
                                   }];
}

- (void)fetchPostDetail:(int64_t)postId postType:(TXPBPostType)postType onCompleted:(void (^)(NSError *error, NSString *htmlContent))onCompleted {
    TXPBFetchPostDetailRequestBuilder *requestBuilder = [TXPBFetchPostDetailRequest builder];
    requestBuilder.postId = postId;
    requestBuilder.postType = postType;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_post_detail"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchPostDetailResponse *txpbFetchPostDetailResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchPostDetailResponse, txpbFetchPostDetailResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, txpbFetchPostDetailResponse.postHtml);
                                           );
                                       }
                                   }];
}

- (TXPost *)queryLastPost:(TXPBPostType)postType
                 gardenId:(int64_t)gardenId
                    error:(NSError **)outError {
    DDLogInfo(@"%s postType=%d gardenId=%lld", __FUNCTION__, (int) postType, gardenId);

    if (postType == TXPBPostTypeLerngarden) {
        int64_t lastGroupId = [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryLastGroupId:postType
                                                                                                          gardenId:gardenId
                                                                                                             error:outError];
        return lastGroupId > 0
                ? [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryLastPostOfGroup:postType
                                                                                                   groupId:lastGroupId
                                                                                                  gardenId:gardenId
                                                                                                     error:outError]
                : nil;
    } else {
        return [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryLastPost:postType
                                                                                        gardenId:gardenId
                                                                                           error:outError];
    }
}

- (NSArray *)queryPosts:(TXPBPostType)postType
              maxPostId:(int64_t)maxPostId
               gardenId:(int64_t)gardenId
                  count:(int64_t)count
                  error:(NSError **)outError {
    if (postType == TXPBPostTypeLerngarden) {
        NSArray *txPosts = [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryPosts:postType
                                                                                                maxPostId:maxPostId
                                                                                                    count:count + 10
                                                                                                 gardenId:gardenId
                                                                                                    error:outError];
        if (txPosts.count <= count) {
            for (TXPost *txPost in txPosts) {
                txPost.isRead = [[TXChatClient sharedInstance].userManager
                        querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                               error:nil];
            }
            return txPosts;
        }

        int64_t lastGroupId = ((TXPost *) txPosts.lastObject).groupId;
        NSMutableArray *txPostsWithoutLastGroup = [NSMutableArray array];
        for (TXPost *txPost in txPosts) {
            txPost.isRead = [[TXChatClient sharedInstance].userManager
                    querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                           error:nil];
            if (txPost.groupId != lastGroupId) {
                [txPostsWithoutLastGroup addObject:txPost];
            }
        }
        return txPostsWithoutLastGroup;
    } else {
        NSArray *txPosts = [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryPosts:postType
                                                                                                maxPostId:maxPostId
                                                                                                    count:count
                                                                                                 gardenId:gardenId
                                                                                                    error:outError];
        for (TXPost *txPost in txPosts) {
            txPost.isRead = [[TXChatClient sharedInstance].userManager
                    querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                           error:nil];
        }
        return txPosts;
    }
}


- (TXPost *)getLastPost:(TXPBPostType)postType error:(NSError **)outError {
    if (postType == TXPBPostTypeLerngarden) {
        int64_t lastGroupId = [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryLastGroupId:postType error:outError];
        return lastGroupId > 0
                ? [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryLastPostOfGroup:postType groupId:lastGroupId error:outError]
                : nil;
    } else {
        return [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryLastPost:postType error:outError];
    }
}

- (NSArray *)getPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError {
    if (postType == TXPBPostTypeLerngarden) {
        NSArray *txPosts = [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryPosts:postType
                                                                                                maxPostId:maxPostId
                                                                                                    count:count + 10
                                                                                                    error:outError];
        if (txPosts.count <= count) {
            for (TXPost *txPost in txPosts) {
                txPost.isRead = [[TXChatClient sharedInstance].userManager
                        querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                               error:nil];
            }
            return txPosts;
        }

        int64_t lastGroupId = ((TXPost *) txPosts.lastObject).groupId;
        NSMutableArray *txPostsWithoutLastGroup = [NSMutableArray array];
        for (TXPost *txPost in txPosts) {
            for (TXPost *txPost in txPosts) {
                txPost.isRead = [[TXChatClient sharedInstance].userManager
                        querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                               error:nil];
            }
            if (txPost.groupId != lastGroupId) {
                [txPostsWithoutLastGroup addObject:txPost];
            }
        }
        return txPostsWithoutLastGroup;
    } else {
        NSArray *txPosts = [[TXApplicationManager sharedInstance].currentUserDbManager.postDao queryPosts:postType
                                                                                                maxPostId:maxPostId count:count
                                                                                                    error:outError];
        for (TXPost *txPost in txPosts) {
            txPost.isRead = [[TXChatClient sharedInstance].userManager
                    querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, txPost.postId]
                                           error:nil];
        }
        return txPosts;
    }
}

- (void)markPostAsReadWithPostId:(int64_t)postId {
    [[TXChatClient sharedInstance].userManager saveSettingValue:@"1"
                                                         forKey:[NSString stringWithFormat:@"%@-%lld", TX_SETTING_POST_IS_READ, postId]
                                                          error:nil];
}

@end