//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXCheckInManager.h"
#import "TXApplicationManager.h"
#import "TXBlockingQueue.h"

@implementation TXCheckInManager {
    NSOperationQueue *_qrCheckInItemUploadOperationQueue;
    TXBlockingQueue *_qrCheckInItemsBlockingQueue;
}

- (instancetype)init {
    if (self = [super init]) {
        _qrCheckInItemUploadOperationQueue = [[NSOperationQueue alloc] init];
        _qrCheckInItemsBlockingQueue = [[TXBlockingQueue alloc] init];


        [self startUploadThread];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCurrentUserChanged)
                                                     name:TX_NOTIFICATION_CURRENT_USER_CHANGED
                                                   object:nil];

    }
    return self;
}

- (void)dealloc {
    [_qrCheckInItemsBlockingQueue removeAll];
    [_qrCheckInItemUploadOperationQueue cancelAllOperations];


    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TX_NOTIFICATION_CURRENT_USER_CHANGED
                                                  object:nil];
}

- (void)onCurrentUserChanged {
    if ([[TXApplicationManager sharedInstance] currentUser]) {
        [self reloadQrCheckInItemsFromDb];
    } else {
        [_qrCheckInItemsBlockingQueue removeAll];
    }
}

/**
 * 将数据库中已经保存的扫码刷卡数据全部载入到内存blocking queue中
 */
- (void)reloadQrCheckInItemsFromDb {
    [_qrCheckInItemsBlockingQueue removeAll];

    NSArray *allQrCheckInItems = [[TXApplicationManager sharedInstance]
            .currentUserDbManager
            .qrCheckInItemDao queryUploadRequiredQrCheckInItems];
    for (TXQrCheckInItem *qrCheckInItem in allQrCheckInItems) {
        [[TXApplicationManager sharedInstance]
                .currentUserDbManager
                .qrCheckInItemDao updateStatus:qrCheckInItem.id
                                     newStatus:TXQrCheckInItemStatusUploading];
        [_qrCheckInItemsBlockingQueue put:qrCheckInItem];
    }
}

/**
 * 启动线程，处理blocking queue中的数据，在blocking queue中没有数据时，该线程将休眠
 */
- (void)startUploadThread {
    [_qrCheckInItemUploadOperationQueue addOperationWithBlock:^{
        TXQrCheckInItem *qrCheckInItem;

        while ((qrCheckInItem = (TXQrCheckInItem *) [_qrCheckInItemsBlockingQueue take])) {
            DDLogInfo(@"Processing qrCheckInItem(%@)", qrCheckInItem);
            [self checkInWithUserId:qrCheckInItem.targetUserId
                         cardNumber:qrCheckInItem.targetCardNumber
                        checkInTime:qrCheckInItem.createdOn
                        onCompleted:^(NSError *error) {
                            if (!error) {
                                DDLogInfo(@"Processing qrCheckInItem(%@) OK", qrCheckInItem);
                                [[TXApplicationManager sharedInstance]
                                        .currentUserDbManager
                                        .qrCheckInItemDao updateStatus:qrCheckInItem.id newStatus:TXQrCheckInItemStatusUploadSucceed];
                                [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_QR_CHECK_IN_COUNT_CHANGED
                                                                                    object:nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_SUCCEED
                                                                                    object:@(qrCheckInItem.id)];
                            } else {
                                DDLogInfo(@"Processing qrCheckInItem(%@) FAILED %@", qrCheckInItem, error);
                                [[TXApplicationManager sharedInstance]
                                        .currentUserDbManager
                                        .qrCheckInItemDao updateStatus:qrCheckInItem.id newStatus:TXQrCheckInItemStatusUploadFailed];
                                [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_FAILED
                                                                                    object:@(qrCheckInItem.id)];
                            }
                        }];
        }
    }];
    DDLogInfo(@"QrCheckInItem upload thread started OK");
}

- (void)addQrCheckInItem:(int64_t)targetUserId
          targetUserName:(NSString *)targetUserName
          targetUserType:(NSString *)targetUserType
        targetCardNumber:(NSString *)targetCardNumber {
    NSError *error;
    TXQrCheckInItem *txQrCheckInItem = [[TXQrCheckInItem alloc] init];
    txQrCheckInItem.targetUserId = targetUserId;
    txQrCheckInItem.targetUsername = targetUserName;
    txQrCheckInItem.targetUserType = targetUserType;
    txQrCheckInItem.targetCardNumber = targetCardNumber;
    txQrCheckInItem.status = TXQrCheckInItemStatusUploading;
    txQrCheckInItem.createdOn = (int64_t) (TIMESTAMP_OF_NOW);
    txQrCheckInItem.updatedOn = (int64_t) (TIMESTAMP_OF_NOW);

    txQrCheckInItem = [[TXApplicationManager sharedInstance].currentUserDbManager
            .qrCheckInItemDao addQrCheckInItem:txQrCheckInItem
                                         error:&error];

    //同时放入内存队列
    [_qrCheckInItemsBlockingQueue put:txQrCheckInItem];
}

- (NSArray *)queryQrCheckInItems:(int64_t)maxId count:(int64_t)count {
    return [[TXApplicationManager sharedInstance].currentUserDbManager
            .qrCheckInItemDao queryQrCheckInItems:maxId count:count];
}

- (int)queryQrCheckInItemCount {
    return [[TXApplicationManager sharedInstance].currentUserDbManager
            .qrCheckInItemDao queryQrCheckInItemCount];
}

- (void)clearAllSucceedQrCheckInItems {
    [[TXApplicationManager sharedInstance].currentUserDbManager
            .qrCheckInItemDao deleteAllSucceedItems];
}

- (void)uploadAllQrCheckInItems {
    if ([[TXApplicationManager sharedInstance] currentUser]) {
        [self reloadQrCheckInItemsFromDb];
    }
}

- (void)fetchDepartmentAttendance:(int64_t)departmentId
                             date:(int64_t)date
                      onCompleted:(void (^)(NSError *error, NSArray *presentUsers, NSArray *absenceUsers, NSArray *leaveUsers, BOOL isRestDay))onCompleted {
    DDLogInfo(@"%s departmentId=%lld date=%lld", __FUNCTION__, departmentId, date);

    TXPBClassAttendanceRequestBuilder *requestBuilder = [TXPBClassAttendanceRequest builder];
    requestBuilder.classId = departmentId;
    requestBuilder.date = date;

    [[TXHttpClient sharedInstance] sendRequest:@"/class_attendance"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBClassAttendanceResponse *txpbClassAttendanceResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBClassAttendanceResponse, txpbClassAttendanceResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError,
                                                       txpbClassAttendanceResponse.present,
                                                       txpbClassAttendanceResponse.absence,
                                                       txpbClassAttendanceResponse.leave,
                                                       txpbClassAttendanceResponse.isRestDay);
                                           });
                                       }

                                   }];
}

- (void)fetchChildAttendance:(int64_t)month
                 onCompleted:(void (^)(NSError *error, NSArray *presentDates, NSArray *absenceDates, NSArray *leaveDates, NSArray *restDates))onCompleted {
    DDLogInfo(@"%s month=%lld", __FUNCTION__, month);

    TXPBChildAttendanceRequestBuilder *requestBuilder = [TXPBChildAttendanceRequest builder];
    requestBuilder.month = month;

    [[TXHttpClient sharedInstance] sendRequest:@"/child_attendance"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBChildAttendanceResponse *txpbChildAttendanceResponse;
                                       NSMutableArray *presentDates = [NSMutableArray array];
                                       NSMutableArray *absenceDates = [NSMutableArray array];
                                       NSMutableArray *leaveDates = [NSMutableArray array];
                                       NSMutableArray *restDates = [NSMutableArray array];

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBChildAttendanceResponse, txpbChildAttendanceResponse);

                                       for (int i = 0; i < txpbChildAttendanceResponse.present.count; i++) {
                                           [presentDates addObject:txpbChildAttendanceResponse.present[i]];
                                       }
                                       for (int i = 0; i < txpbChildAttendanceResponse.absence.count; i++) {
                                           [absenceDates addObject:txpbChildAttendanceResponse.absence[i]];
                                       }
                                       for (int i = 0; i < txpbChildAttendanceResponse.leave.count; i++) {
                                           [leaveDates addObject:txpbChildAttendanceResponse.leave[i]];
                                       }
                                       for (int i = 0; i < txpbChildAttendanceResponse.rest.count; i++) {
                                           [restDates addObject:txpbChildAttendanceResponse.rest[i]];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, presentDates, absenceDates, leaveDates, restDates);
                                           });
                                       }

                                   }];
}

- (void)updateAttendance:(NSArray *)presentUserIds
          absenceUserIds:(NSArray *)absenceUserIds
            leaveUserIds:(NSArray *)leaveUserIds
                    date:(int64_t)date
             onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s presentUserIds=%@ absenceUserIds=%@ leaveUserIds=%@ date=%lld", __FUNCTION__, presentUserIds, absenceUserIds, leaveUserIds, date);

    TXPBUpdateAttendanceRequestBuilder *requestBuilder = [TXPBUpdateAttendanceRequest builder];
    [requestBuilder setPresentArray:presentUserIds];
    [requestBuilder setAbsenceArray:absenceUserIds];
    [requestBuilder setLeaveArray:leaveUserIds];
    requestBuilder.date = date;

    [[TXHttpClient sharedInstance] sendRequest:@"/update_attendance"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)fetchLeaves:(int64_t)maxId
             userId:(int64_t)userId
        onCompleted:(void (^)(NSError *error, NSArray *leaves, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxId=%lld userId=%lld", __FUNCTION__, maxId, userId);

    TXPBFetchLeaveRequestBuilder *requestBuilder = [TXPBFetchLeaveRequest builder];
    requestBuilder.sinceId = 0;
    requestBuilder.maxId = maxId;
    if (userId != 0) {
        requestBuilder.userId = userId;
    }


    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_leave"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchLeaveResponse *txpbFetchLeaveResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchLeaveResponse, txpbFetchLeaveResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txpbFetchLeaveResponse.leaves, txpbFetchLeaveResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)applyLeave:(NSString *)reason
         beginDate:(int64_t)beginDate
           endDate:(int64_t)endDate
         leaveType:(TXPBLeaveType)leaveType
            userId:(int64_t)userId
       onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s reason=%@ beginDate=%lld endDate=%lld leaveType=%d userId=%lld",
            __FUNCTION__, reason, beginDate, endDate, (int) leaveType, userId);

    TXPBApplyLeaveRequestBuilder *requestBuilder = [TXPBApplyLeaveRequest builder];
    requestBuilder.userId = userId;
    requestBuilder.reason = reason;
    requestBuilder.beginDate = beginDate;
    requestBuilder.endDate = endDate;
    requestBuilder.leaveType = leaveType;

    [[TXHttpClient sharedInstance] sendRequest:@"/apply_leave"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }

                                   }];
}

- (void)approveLeave:(int64_t)leaveId
               reply:(NSString *)reply
         onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s reply=%@ leaveId=%lld", __FUNCTION__, reply, leaveId);

    TXPBApproveLeaveRequestBuilder *requestBuilder = [TXPBApproveLeaveRequest builder];
    requestBuilder.leaveId = leaveId;
    requestBuilder.reply = reply;

    [[TXHttpClient sharedInstance] sendRequest:@"/approve_leave"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }

                                   }];
}

- (void)fetchRestDaysWithYear:(int64_t)year
                  onCompleted:(void (^)(NSError *error, NSArray *restDays))onCompleted {
    DDLogInfo(@"%s year=%lld", __FUNCTION__, year);

    TXPBFetchRestDayRequestBuilder *requestBuilder = [TXPBFetchRestDayRequest builder];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    requestBuilder.date = (SInt64) ([[dateFormatter dateFromString:[NSString stringWithFormat:@"%lli-01-01", year]] timeIntervalSince1970] * 1000);

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_rest_day"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchRestDayResponse *txpbFetchRestDayResponse;
                                       NSMutableArray *restDays = [NSMutableArray array];

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchRestDayResponse, txpbFetchRestDayResponse);

                                       for (int i = 0; i < txpbFetchRestDayResponse.restDay.count; i++) {
                                           [restDays addObject:txpbFetchRestDayResponse.restDay[i]];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, restDays);
                                           });
                                       }

                                   }];
}


- (void)reportLossCard:(NSString *)cardCode
                userId:(int64_t)userId
           onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBReportLossCardRequestBuilder *requestBuilder = [TXPBReportLossCardRequest builder];
    requestBuilder.cardCode = cardCode;

    [[TXHttpClient sharedInstance] sendRequest:@"/report_loss_card"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)fetchAttendance:(int64_t)maxCheckInId
            onCompleted:(void (^)(NSError *error, NSArray *txCheckIns, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxCheckInId=%lld", __FUNCTION__, maxCheckInId);

    TXPBFetchAttendanceRequestBuilder *requestBuilder = [TXPBFetchAttendanceRequest builder];
    requestBuilder.maxId = maxCheckInId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_attendance"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       NSMutableArray *txCheckIns;
                                       TXPBFetchAttendanceResponse *fetchAttendanceResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchAttendanceResponse, fetchAttendanceResponse);

                                       txCheckIns = [[NSMutableArray alloc] init];

                                       for (TXPBCheckin *txpbCheckIn  in fetchAttendanceResponse.checkins) {
                                           TXCheckIn *txCheckIn = [[[TXCheckIn alloc] init] loadValueFromPbObject:txpbCheckIn];
                                           [txCheckIns addObject:txCheckIn];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txCheckIns, fetchAttendanceResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchCheckIns:(int64_t)maxCheckInId
          onCompleted:(void (^)(NSError *error, NSArray *txCheckIns, BOOL hasMore))onCompleted {
    DDLogInfo(@"%s maxCheckInId=%lld", __FUNCTION__, maxCheckInId);

    TXPBFetchCheckinRequestBuilder *requestBuilder = [TXPBFetchCheckinRequest builder];
    requestBuilder.maxId = maxCheckInId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_checkin"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       NSMutableArray *txCheckIns;
                                       TXPBFetchCheckinResponse *fetchCheckInResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchCheckinResponse, fetchCheckInResponse);

                                       txCheckIns = [[NSMutableArray alloc] init];

                                       for (TXPBCheckin *txpbCheckIn  in fetchCheckInResponse.checkins) {
                                           TXCheckIn *txCheckIn = [[[TXCheckIn alloc] init] loadValueFromPbObject:txpbCheckIn];
                                           [txCheckIns addObject:txCheckIn];

                                           [[TXApplicationManager sharedInstance].currentUserDbManager.checkInDao addCheckIn:txCheckIn
                                                                                                                       error:nil];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txCheckIns, fetchCheckInResponse.hasMore);
                                           });
                                       }
                                   }];
}

- (void)fetchBindCards:(void (^)(NSError *error, NSArray/*<TXPBBindCardInfo>*/ *txpbBindCardInfos))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_user_card"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:nil
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchUserCardResponse *txpbFetchUserCardResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchUserCardResponse, txpbFetchUserCardResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txpbFetchUserCardResponse.biandCardInfo);
                                           });
                                       }
                                   }];
}

- (NSArray *)queryCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError {
    DDLogInfo(@"%s maxCheckInId=%lld count=%lld", __FUNCTION__, maxCheckInId, count);

    if (![TXApplicationManager sharedInstance].currentUser) {
        NSError *error = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        TX_POST_NOTIFICATION_IF_ERROR(error);
        if (outError) {
            *outError = error;
        }
        return nil;
    }

    return [[TXApplicationManager sharedInstance].currentUserDbManager.checkInDao queryCheckIns:maxCheckInId
                                                                                          count:count
                                                                                          error:outError];
}

- (TXCheckIn *)queryLastCheckIn:(NSError **)outError {
    DDLogInfo(@"%s", __FUNCTION__);
    return [[TXApplicationManager sharedInstance].currentUserDbManager.checkInDao queryLastCheckIn];
}

- (void)bindCard:(NSString *)cardCode userId:(int64_t)userId onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s cardCode=%@ userId=%lld", __FUNCTION__, cardCode, userId);

    TXPBBindCardRequestBuilder *requestBuilder = [TXPBBindCardRequest builder];
    requestBuilder.cardCode = cardCode;
    requestBuilder.userId = userId;

    [[TXHttpClient sharedInstance] sendRequest:@"/bind_card"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)checkInWithUserId:(int64_t)userId
               cardNumber:(NSString *)cardNumber
              checkInTime:(int64_t)checkInTime
              onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s cardNumber=%@ checkInTime=%lld", __FUNCTION__, cardNumber, checkInTime);

    TXPBScanCodeCheckinRequestBuilder *requestBuilder = [TXPBScanCodeCheckinRequest builder];
    requestBuilder.userId = userId;
    requestBuilder.cardCode = cardNumber;
    requestBuilder.checkinTime = checkInTime;

    [[TXHttpClient sharedInstance] sendRequest:@"/scan_code_checkin"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)clearCheckIn:(int64_t)maxId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBClearCheckInRequestBuilder *requestBuilder = [TXPBClearCheckInRequest builder];
    requestBuilder.maxId = maxId;

    [[TXHttpClient sharedInstance] sendRequest:@"/clear_check_in"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.checkInDao deleteAllCheckIn];
                                       }

                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}


@end