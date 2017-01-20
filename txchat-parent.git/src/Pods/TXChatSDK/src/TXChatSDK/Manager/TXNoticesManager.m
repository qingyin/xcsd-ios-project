//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXNoticesManager.h"
#import "TXApplicationManager.h"
#import "TXJsbManager.h"


@implementation TXNoticesManager {
}

- (void)sendNotice:(NSString *)content
          attaches:(NSArray/*<TXPBAttach>*/ *)attaches
     toDepartments:(NSArray/*<TXPBNoticeDepartment>*/ *)toDepartments
       onCompleted:(void (^)(NSError *error, int64_t noticeId))onCompleted {
    DDLogInfo(@"%s content=%@ attaches=%@ toDepartments=%@", __FUNCTION__, content, attaches,toDepartments);
    
    TXPBSendNoticeRequestBuilder *requestBuilder = [TXPBSendNoticeRequest builder];
    [requestBuilder setAttchesArray:attaches];
    requestBuilder.content = content;
    [requestBuilder setNoticeDepartmentsArray:toDepartments];

    [[TXHttpClient sharedInstance] sendRequest:@"/send_notice"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBSendNoticeResponse *sendNoticeResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBSendNoticeResponse, sendNoticeResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (!innerError && sendNoticeResponse.bonus > 0) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_WEI_DOU_AWARDED
                                                                                                       object:@(sendNoticeResponse.bonus)];
                                               }

                                               onCompleted(innerError, sendNoticeResponse.noticeId);
                                           });
                                       }
                                   }];
}

- (void)fetchNotices:(BOOL)isInbox
         maxNoticeId:(int64_t)maxNoticeId
         onCompleted:(void (^)(NSError *error, NSArray/*<TXNotice>*/ *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged))onCompleted {
    DDLogInfo(@"%s isInbox=%d maxNoticeId=%lld", __FUNCTION__,isInbox,maxNoticeId);
    
    TXPBFetchNoticeRequestBuilder *requestBuilder = [TXPBFetchNoticeRequest builder];
    requestBuilder.maxId = maxNoticeId;
    requestBuilder.sinceId = 0;
    requestBuilder.isInbox = isInbox;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_notice"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchNoticeResponse *fetchHistoryNoticeResponse = nil;
                                       NSMutableArray *txNotices;
                                       BOOL writeToDb = LLONG_MAX == maxNoticeId;
                                       int64_t localLastNoticeId = 0;
                                       int64_t serverLastNoticeId = 0;
                                       TXNotice *localLastNotice;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchNoticeResponse, fetchHistoryNoticeResponse);

                                       localLastNotice = [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao queryLastInboxNotice];
                                       localLastNoticeId = localLastNotice ? localLastNotice.noticeId : 0;

                                       txNotices = [NSMutableArray array];

                                       for (TXPBNotice *txpbNotice in fetchHistoryNoticeResponse.notices) {
                                           TXNotice *txNotice = [[[TXNotice alloc] init] loadValueFromPbObject:txpbNotice];
                                           txNotice.isInbox = isInbox;

                                           [txNotices addObject:txNotice];

                                           if (writeToDb) {
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao addNotice:txNotice error:nil];
                                               });
                                           }

                                           serverLastNoticeId = serverLastNoticeId > txNotice.noticeId ? serverLastNoticeId : txNotice.noticeId;
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txNotices,
                                                       isInbox,
                                                       fetchHistoryNoticeResponse.hasMore,
                                                       localLastNoticeId != serverLastNoticeId);
                                           });
                                       }
                                   }];
}

- (void)fetchNoticeDepartments:(int64_t)noticeId
                   onCompleted:(void (^)(NSError *error, NSArray *txpbNoticesDepartments))onCompleted {
    TXPBFetchNoticeDepartmentsRequestBuilder *requestBuilder = [TXPBFetchNoticeDepartmentsRequest builder];
    requestBuilder.noticeId = noticeId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_notice_departments"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchNoticeDepartmentsResponse *txpbFetchNoticeDepartmentsResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchNoticeDepartmentsResponse, txpbFetchNoticeDepartmentsResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txpbFetchNoticeDepartmentsResponse.noticeDepartments);
                                           });
                                       }
                                   }];
}

- (void)fetchNoticeMembers:(int64_t)noticeId
              departmentId:(int64_t)departmentId
               onCompleted:(void (^)(NSError *error, NSArray *txpbNoticeMembers))onCompleted {
    TXPBFetchNoticeMembersRequestBuilder *requestBuilder = [TXPBFetchNoticeMembersRequest builder];
    requestBuilder.noticeId = noticeId;
    requestBuilder.departmentId = departmentId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_notice_members"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBFetchNoticeMembersResponse *fetchNoticeMembersResponse = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchNoticeMembersResponse, fetchNoticeMembersResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, fetchNoticeMembersResponse.noticeMembers);
                                           });
                                       }
                                   }];

}

- (void)markNoticeHasRead:(int64_t)noticeId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBReadNoticeRequestBuilder *requestBuilder = [TXPBReadNoticeRequest builder];
    requestBuilder.noticeId = noticeId;

    [[TXHttpClient sharedInstance] sendRequest:@"/read_notice"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao markNoticeAsRead:noticeId error:nil];
                                       }
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (NSArray *)queryNotices:(int64_t)maxNoticeId count:(int64_t)count error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao queryNotices:maxNoticeId count:count error:outError];
}

- (NSArray *)queryNotices:(int64_t)maxNoticeId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao queryNotices:maxNoticeId count:count isInbox:isInbox error:outError];
}

- (TXNotice *)queryNoticeById:(int64_t)id error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao queryNoticeById:id error:outError];
}

- (TXNotice *)queryNoticeByNoticeId:(int64_t)noticeId error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao queryNoticeByNoticeId:noticeId error:outError];
}

- (TXNotice *)queryLastNotice:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao queryLastNotice];
}

- (void)clearNotice:(int64_t)maxId isInbox:(BOOL)isInbox onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBClearNoticeRequestBuilder *requestBuilder = [TXPBClearNoticeRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.isInbox = isInbox;

    [[TXHttpClient sharedInstance] sendRequest:@"/clear_notice"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.noticeDao deleteAllNotice:isInbox];
                                       }

                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

@end