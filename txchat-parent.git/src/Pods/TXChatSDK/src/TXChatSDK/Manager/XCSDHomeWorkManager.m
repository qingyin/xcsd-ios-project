//
//  XCSDHomeWorkManager.m
//  Pods
//
//  Created by gaoju on 16/3/15.
//
//

#import "XCSDHomeWorkManager.h"
#import "TXApplicationManager.h"
#import "XCSDHomeWork.h"
#import "XCSDHomeWorkDao.h"

@implementation XCSDHomeWorkManager
{
//    NSArray *rankList;
}
- (void)fetchHomeWorks:(BOOL)isInbox
           maxHomeWorkId:(int64_t)maxHomeWorkId
           onCompleted:(void (^)(NSError *error, NSArray/*<XCSDHomeWork>*/ *xcsdHomeWorks, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged))onCompleted {
    
    DDLogInfo(@"%s isInbox=%d maxHomeWorkId=%lld", __FUNCTION__,isInbox,maxHomeWorkId);
    
    XCSDPBHomeworkListRequestBuilder  *requestBuilder =[XCSDPBHomeworkListRequest builder];
    requestBuilder.maxId = maxHomeWorkId;
   // requestBuilder.sinceId = 2;
   
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/list"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       
                                       NSError *innerError = nil;
                                       NSMutableArray *homeWorks;
                                       BOOL writeToDb = LLONG_MAX == maxHomeWorkId;
                                       int64_t localLasthomeWorksId = 0;
                                       int64_t serverLasthomeWorksId = 0;
                                      XCSDHomeWork *localLasthomeWork;

                                       XCSDPBHomeworkListResponse *fetchHistoryhomeWorkResponse = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(XCSDPBHomeworkListResponse, fetchHistoryhomeWorkResponse);
                                       
                                    homeWorks = [NSMutableArray array];
                                       
                                       
//                                    for (XCSDPBHomework *txpbNotice in fetchHistoryhomeWorkResponse.homeworks) {
//                                           XCSDHomeWork *txNotice = [[[XCSDHomeWork alloc] init] loadValueFromPbObject:txpbNotice];
//                                         //  txNotice.isInbox = isInbox;
//                                           
//                                           [txNotices addObject:txNotice];
//                                    }
                                    
                                       localLasthomeWork = [[TXApplicationManager sharedInstance].currentUserDbManager.homeWorkDao queryLastHomework:nil];
                                       localLasthomeWorksId = localLasthomeWork ? localLasthomeWork.HomeWorkId : 0;
                                       
                    
                                       
                                       for (XCSDPBHomework *pbHomeWork in fetchHistoryhomeWorkResponse.homeworks) {
                                           XCSDHomeWork *homeWork = [[[XCSDHomeWork alloc] init] loadValueFromPbObject:pbHomeWork];
                                         //  txNotice.isInbox = isInbox;
                                           
                                           [homeWorks addObject:homeWork];
                                           
                                           if (writeToDb) {
                                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.homeWorkDao addHomeWork:homeWork error:nil];
                                               });
                                           }
                                           
                                           serverLasthomeWorksId = serverLasthomeWorksId > homeWork.HomeWorkId ? serverLasthomeWorksId : homeWork.HomeWorkId;
                                       }
                                       
  
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, homeWorks,
                                                           isInbox,
                                                           fetchHistoryhomeWorkResponse.hasMore,
                                                           localLasthomeWorksId != serverLasthomeWorksId);
                                           });
                                       }
                                       
                                }];
}
- (NSArray *)queryHomeWork:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.homeWorkDao queryHomeWork:maxCheckInId count:count error:outError];
}
- (XCSDHomeWork *)queryLastHomework:(NSError **)outError{
    return [[TXApplicationManager sharedInstance].currentUserDbManager.homeWorkDao queryLastHomework:outError];}


- (void)fetchDetailHomework:(NSInteger)memberId onCompleted:(void (^)(NSError *, NSArray *, NSInteger))onCompleted{
    
    XCSDPBHomeworkDetailRequestBuilder *requestBuilder = [XCSDPBHomeworkDetailRequest builder];
    requestBuilder.memberId = memberId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/detail" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError;
        XCSDPBHomeworkDetailResponse *detailResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(innerError);
        
        TX_PARSE_PB_OBJECT(XCSDPBHomeworkDetailResponse, detailResponse);
        
        
        
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, detailResponse.gameLevels, (NSInteger)detailResponse.memberId);
            });
        }
    }];
}

- (void)fetchHomeworkDetail:(NSInteger)memberId onCompleted:(void (^)(NSError *, XCSDPBHomeworkDetailResponse *))onCompleted{
    
    XCSDPBHomeworkDetailRequestBuilder *requestBuilder = [XCSDPBHomeworkDetailRequest builder];
    requestBuilder.memberId = memberId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/detail" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError;
        XCSDPBHomeworkDetailResponse *detailResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(innerError);
        
        TX_PARSE_PB_OBJECT(XCSDPBHomeworkDetailResponse, detailResponse);
        
        
        
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, detailResponse);
            });
        }
    }];

}

- (void)DeletehomeworId:(int64_t)homeworkId
            onCompleted:(void (^)(NSError *error))onCompleted{
    DDLogInfo(@" homeworkId=%lld", homeworkId);
    
    XCSDPBDeleteHomeworkNoticeRequestBuilder  *requestBuilder =[XCSDPBDeleteHomeworkNoticeRequest builder];
    requestBuilder.homeworkNoticeId = homeworkId;
  
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/delete_notice"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
//                                       
//                                       NSError *innerError = nil;
//                                       XCSDPBDeleteHomeworkNoticeResponse *deleteHomeworkNoticeResponse = nil;
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.homeWorkDao deleteHomework:homeworkId];
                                       }
//                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
//                                       TX_PARSE_PB_OBJECT(XCSDPBDeleteHomeworkNoticeResponse, deleteHomeworkNoticeResponse);
//                                            completed:
//                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(error);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(error);
                                           });
//                                       }
                                       
                                   }];
    
}
- (void)ReadhomeworkId:(int64_t)homeworkId
                 onCompleted:(void (^)(NSError *error))onCompleted{
    DDLogInfo(@" homeworkId=%lld", homeworkId);
    
    XCSDPBReadHomeworkNoticeRequestBuilder *requestBuilder =[XCSDPBReadHomeworkNoticeRequest builder];
    requestBuilder.homeworkNoticeId = homeworkId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/read_notice"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.homeWorkDao markHomeworkAsRead:homeworkId error:nil];
                                       }

                                    TX_POST_NOTIFICATION_IF_ERROR(error);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(error);
                                           });
                                     
                                       
                                   }];
}
- (void)RankHomeWorksChildUserId:(int64_t)ChildUserId
                     onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted{
    DDLogInfo(@" ChildUserId=%lld", ChildUserId);
    
    XCSDPBHomeworkRankingRequestBuilder  *requestBuilder =[XCSDPBHomeworkRankingRequest builder];
    requestBuilder.childUserId = ChildUserId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/ranking"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       
                                       NSError *innerError = nil;
                                       int64_t localLastNoticeId = 0;
                                       int64_t serverLastNoticeId = 0;
                                       NSMutableArray * rankList=[NSMutableArray array];
                                       
                                       XCSDPBHomeworkRankingResponse *fetchHistoryhomeWorkResponse = nil;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(XCSDPBHomeworkRankingResponse, fetchHistoryhomeWorkResponse);
                                     
       for ( XCSDPBUserRank *xcsdpbHomeworkRank in fetchHistoryhomeWorkResponse.rankList) {

          XCSDHomeWorkRank *txRankItem =  [[XCSDHomeWorkRank alloc] init];
//         XCSDHomeWorkRank *txRankItem = [[[XCSDHomeWorkRank alloc] init]   loadValueFromPbObject:xcsdpbHomeworkRank];
      [txRankItem loadValueFromPbObject:xcsdpbHomeworkRank];
        
        [rankList addObject:txRankItem];
    }
    completed:
        {
          TX_POST_NOTIFICATION_IF_ERROR(innerError);
          dispatch_async(dispatch_get_main_queue(), ^{
              onCompleted(innerError,
                        rankList,
                        false,
                        localLastNoticeId != serverLastNoticeId);
          });
    }
    
}];

}

- (void)fetchChildAttendance:(int64_t)ChildUserId
                 onCompleted:(void (^)(NSError *error, NSArray *finishedDates, NSArray *unfinishedDates))onCompleted {
    DDLogInfo(@"%s ChildUserId=%lld", __FUNCTION__, ChildUserId);
    
    XCSDPBHomeworkCalendarRequestBuilder *requestBuilder = [XCSDPBHomeworkCalendarRequest builder];
    requestBuilder.ChildUserId = ChildUserId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/calendar"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       XCSDPBHomeworkCalendarResponse *txpbChildAttendanceResponse;
                                       NSMutableArray *finishedDates = [NSMutableArray array];
                                       NSMutableArray *unfinishedDates = [NSMutableArray array];
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       
                                       TX_PARSE_PB_OBJECT(XCSDPBHomeworkCalendarResponse, txpbChildAttendanceResponse);
                                       
                                       for (int i = 0; i < txpbChildAttendanceResponse.finished.count; i++) {
                                           [finishedDates addObject:txpbChildAttendanceResponse.finished[i] ];
                                       }
                                       for (int i = 0; i < txpbChildAttendanceResponse.unfinished.count; i++) {
                                           [unfinishedDates addObject:txpbChildAttendanceResponse.unfinished[i]];
                                       }

                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, finishedDates, unfinishedDates);
                                           });
                                       }
                    }];
}

@end
