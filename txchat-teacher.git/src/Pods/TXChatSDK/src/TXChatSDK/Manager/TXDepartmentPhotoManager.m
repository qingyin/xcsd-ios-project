//
// Created by lingqingwan on 9/22/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDepartmentPhotoManager.h"
#import "TXApplicationManager.h"

@implementation TXDepartmentPhotoManager {

}

- (void)fetchDepartmentPhotos:(int64_t)departmentId
         maxDepartmentPhotoId:(int64_t)maxDepartmentPhotoId
                  onCompleted:(void (^)(NSError *error, NSArray *txDepartmentPhotos, int64_t totalCount, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s departmentId=%lld maxDepartmentPhotoId=%lld", __FUNCTION__, departmentId, maxDepartmentPhotoId);

    TXPBFetchDepartmentPhotoRequestBuilder *requestBuilder = [TXPBFetchDepartmentPhotoRequest builder];
    requestBuilder.maxId = maxDepartmentPhotoId;
    requestBuilder.departmentId = departmentId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_department_photo"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       NSMutableArray *txDepartmentPhotos;
                                       TXPBFetchDepartmentPhotoResponse *fetchDepartmentPhotoResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchDepartmentPhotoResponse, fetchDepartmentPhotoResponse);

                                       txDepartmentPhotos = [[NSMutableArray alloc] init];

                                       for (TXPBDepartmentPhoto *txpbDepartmentPhoto  in fetchDepartmentPhotoResponse.photos) {
                                           TXDepartmentPhoto *txDepartmentPhoto = [[[TXDepartmentPhoto alloc] init] loadValueFromPbObject:txpbDepartmentPhoto
                                                                                                                             departmentId:departmentId];
                                           [txDepartmentPhotos addObject:txDepartmentPhoto];

                                           [[TXApplicationManager sharedInstance]
                                                   .currentUserDbManager
                                                   .departmentPhotoDao addDepartmentPhoto:txDepartmentPhoto
                                                                                    error:nil];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txDepartmentPhotos, fetchDepartmentPhotoResponse.totalCnt, fetchDepartmentPhotoResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (NSArray *)queryDepartmentPhotos:(int64_t)departmentId
              maxDepartmentPhotoId:(int64_t)maxDepartmentPhotoId
                             count:(int64_t)count
                             error:(NSError **)outError {
    DDLogInfo(@"%s departmentId=%lld maxDepartmentPhotoId=%lld count=%lld", __FUNCTION__, departmentId, maxDepartmentPhotoId, count);

    return [[TXApplicationManager sharedInstance]
            .currentUserDbManager
            .departmentPhotoDao queryDepartmentPhotos:departmentId
                                 maxDepartmentPhotoId:maxDepartmentPhotoId
                                                count:count
                                                error:outError];
}

@end