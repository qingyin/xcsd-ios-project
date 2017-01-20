//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXFeedMedicineTaskDao.h"
#import "TXApplicationManager.h"
#import "TXFeedMedicineTaskManager.h"


@implementation TXFeedMedicineTaskManager {
}

- (void)sendFeedMedicineTask:(NSString *)content attaches:(NSArray/*<TXPBAttach>*/ *)attaches beginDate:(int64_t)beginDate
                 onCompleted:(void (^)(NSError *error, int64_t feedMedicineTaskId))onCompleted {
    TXPBSendFeedMedicineTaskRequestBuilder *requestBuilder = [TXPBSendFeedMedicineTaskRequest builder];
    [requestBuilder setAttachesArray:attaches];
    requestBuilder.desc = content;
    requestBuilder.beginDate = beginDate;

    [[TXHttpClient sharedInstance] sendRequest:@"/send_feed_medicine_task"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBSendFeedMedicineTaskResponse *sendFeedMedicineTaskResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBSendFeedMedicineTaskResponse, sendFeedMedicineTaskResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, sendFeedMedicineTaskResponse.feedMedicineTaskId);
                                           });
                                       }
                                   }];
}

- (void)fetchFeedMedicineTasks:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *txFeedMedicineTasks, BOOL hasMore))onCompleted {
    TXPBFetchFeedMedicineTaskRequestBuilder *requestBuilder = [TXPBFetchFeedMedicineTaskRequest builder];
    requestBuilder.maxId = maxId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_feed_medicine_task"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchFeedMedicineTaskResponse *feedMedicineTaskResponse;
                                       NSMutableArray *txFeedMedicineTasks;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchFeedMedicineTaskResponse, feedMedicineTaskResponse);

                                       if (maxId == LLONG_MAX) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.feedMedicineTaskDao deleteAllFeedMedicineTask];
                                       }

                                       txFeedMedicineTasks = [NSMutableArray array];

                                       for (TXPBFeedMedicineTask *txpbFeedMedicineTask in feedMedicineTaskResponse.feedMedicineTask) {
                                           TXFeedMedicineTask *txFeedMedicineTask = [[[TXFeedMedicineTask alloc] init] loadValueFromPbObject:txpbFeedMedicineTask];

                                           if (maxId == LLONG_MAX) {
                                               [[TXApplicationManager sharedInstance].currentUserDbManager.feedMedicineTaskDao addFeedMedicineTask:txFeedMedicineTask error:&innerError];
                                               if (innerError) {
                                                   goto completed;
                                               }
                                           }

                                           [txFeedMedicineTasks addObject:txFeedMedicineTask];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txFeedMedicineTasks, feedMedicineTaskResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (NSArray *)getFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.feedMedicineTaskDao queryFeedMedicineTasks:maxId count:count error:outError];
}

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBReadFeedMedicineRequestBuilder *requestBuilder = [TXPBReadFeedMedicineRequest builder];
    requestBuilder.id = feedMedicineTaskId;

    [[TXHttpClient sharedInstance] sendRequest:@"/read_feed_medicine"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.feedMedicineTaskDao markFeedMedicineTaskAsRead:feedMedicineTaskId error:nil];
                                       }
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}
@end