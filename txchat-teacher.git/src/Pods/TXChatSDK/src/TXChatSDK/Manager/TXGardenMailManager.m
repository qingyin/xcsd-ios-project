//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXGardenMailManager.h"
#import "TXApplicationManager.h"


@implementation TXGardenMailManager {
}

- (void)sendGardenMail:(NSString *)content isAnonymous:(BOOL)isAnonymous onCompleted:(void (^)(NSError *error, int64_t gardenMailId))onCompleted {
    TXPBSendGardenMailRequestBuilder *requestBuilder = [TXPBSendGardenMailRequest builder];
    requestBuilder.content = content;
    requestBuilder.anonymous = isAnonymous;

    [[TXHttpClient sharedInstance] sendRequest:@"/send_garden_mail"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBSendGardenMailResponse *sendGardenMailResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBSendGardenMailResponse, sendGardenMailResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, sendGardenMailResponse.id);
                                           });
                                       }
                                   }];
}

- (void)fetchGardenMails:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *txGardenMails, BOOL hasMore))onCompleted {
    TXPBFetchGardenMailRequestBuilder *requestBuilder = [TXPBFetchGardenMailRequest builder];
    requestBuilder.maxId = maxId;
    requestBuilder.sinceId = 0;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_garden_mail"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchGardenMailResponse *fetchGardenMailResponse;
                                       NSMutableArray *txGardenMails;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchGardenMailResponse, fetchGardenMailResponse);

                                       if (maxId == LLONG_MAX) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.gardenMailDao deleteAllGardenMail];
                                       }

                                       txGardenMails = [NSMutableArray array];
                                       for (TXPBGardenMail *txpbGardenMail in fetchGardenMailResponse.gardenMail) {
                                           TXGardenMail *txGardenMail = [[[TXGardenMail alloc] init] loadValueFromPbObject:txpbGardenMail];

                                           if (maxId == LLONG_MAX) {
                                               [[TXApplicationManager sharedInstance].currentUserDbManager.gardenMailDao addGardenMail:txGardenMail error:nil];
                                           }
                                           [txGardenMails addObject:txGardenMail];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txGardenMails, fetchGardenMailResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (NSArray *)getGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.gardenMailDao queryGardenMails:maxId count:count error:outError];
}

- (void)markGardenMailAsRead:(int64_t)gardenMailId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBReadGardenMailRequestBuilder *requestBuilder = [TXPBReadGardenMailRequest builder];
    requestBuilder.id = gardenMailId;

    [[TXHttpClient sharedInstance] sendRequest:@"/read_garden_mail"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.gardenMailDao markGardenMailAsRead:gardenMailId error:nil];
                                       }
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}
@end