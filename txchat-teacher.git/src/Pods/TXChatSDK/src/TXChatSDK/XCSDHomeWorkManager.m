//
//  XCSDHomeWorkManager.m
//  Pods
//
//  Created by gaoju on 16/4/5.
//
//

#import "TXApplicationManager.h"
#import "XCSDHomeWorkManager.h"

@implementation XCSDHomeWorkManager

- (void)HomeworkSentList:(BOOL)isInbox sentHomeWorksHasMaxId:(int64_t)maxId  onCompleted:(void (^)(NSError *error, NSArray *Homeworks,BOOL hasMore, BOOL lastOneHasChanged))onCompleted{
    DDLogInfo(@"%s maxId=%lld isInbox=%d", __FUNCTION__,maxId,isInbox);
    
    XCSDPBHomeworkSentListRequestBuilder *requestBuilder=[XCSDPBHomeworkSentListRequest builder];
    requestBuilder.maxId=maxId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/sent_list" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        NSMutableArray *homeWorks;
        homeWorks = [NSMutableArray array];
        XCSDPBHomeworkSentListResponse *fetchHistoryhomeWorkResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        TX_PARSE_PB_OBJECT(XCSDPBHomeworkSentListResponse, fetchHistoryhomeWorkResponse);
        for (XCSDPBClassHomework *pbHomeWork  in fetchHistoryhomeWorkResponse.homeworks) {
            XCSDClassHomework *homeWork=[[[XCSDClassHomework alloc]init] loadValueFromPbObject:pbHomeWork];
            [homeWorks addObject:homeWork];
    
        }
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, homeWorks,isInbox,fetchHistoryhomeWorkResponse);
            });
        }

    }];

}
- (void)HomeworkMemberList:(BOOL)isInbox HomeworkId:(int64_t)homeworkId onCompleted:(void (^)(NSError *error, NSArray *members,BOOL hasMore, BOOL lastOneHasChanged))onCompleted{
    
    DDLogInfo(@"%s  isInbox=%d", __FUNCTION__,isInbox);
    
    XCSDPBHomeworkMemberListRequestBuilder *requestBuilder=[XCSDPBHomeworkMemberListRequest builder];

    requestBuilder.homeworkId=homeworkId;
    
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/members" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        NSMutableArray *members;
        members = [NSMutableArray array];
        XCSDPBHomeworkMemberListResponse *fetchHistoryhomeWorkResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        TX_PARSE_PB_OBJECT(XCSDPBHomeworkMemberListResponse, fetchHistoryhomeWorkResponse);
        for (XCSDPBHomeworkMember *pbHomeWork  in fetchHistoryhomeWorkResponse.members) {
            XCSDHomeworkMember *member=[[[XCSDHomeworkMember alloc]init] loadValueFromPbObject:pbHomeWork];
            [members addObject:member];
            
        }
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, members,
                            isInbox,fetchHistoryhomeWorkResponse);
            });
        }
        
    }];
}

- (void)GenerateHomeworkListClassId:(int64_t)classId onCompleted:(void (^)(NSError *error, NSArray *homeWork, BOOL lastOneHasChanged))onCompleted;{
    
    DDLogInfo(@"%s classId=%lld ", __FUNCTION__,classId);
    
    XCSDPBGenerateHomeworkRequestBuilder *requestBuilder=[XCSDPBGenerateHomeworkRequest builder];
    requestBuilder.classId=classId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/generate" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        NSMutableArray *userHomeworks;
        userHomeworks = [NSMutableArray array];
        XCSDPBGenerateHomeworkResponse *fetchHistoryhomeWorkResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        TX_PARSE_PB_OBJECT(XCSDPBGenerateHomeworkResponse, fetchHistoryhomeWorkResponse);
        for (XCSDPBGenerateHomeworkResponseUserHomework *pbHomeWork  in fetchHistoryhomeWorkResponse.userHomeworks) {
            XCSDHomeWorkGenerate *userHomework=[[[XCSDHomeWorkGenerate alloc]init] loadValueFromPbObject:pbHomeWork];
            [userHomeworks addObject:userHomework];
            
        }
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, userHomeworks,fetchHistoryhomeWorkResponse);
            });
        }
    }];
}

- (void)SendHomework:(BOOL)isInbox ClassId:(int64_t)classId StudentScope:(int32_t)scope  onCompleted:(void (^)(NSError *error))onCompleted{
    
    DDLogInfo(@"%s ClassId=%lld sinceId=%d", __FUNCTION__,classId,isInbox);
    
    XCSDPBSendHomeworkRequestBuilder *requestBuilder=[XCSDPBSendHomeworkRequest builder];
    requestBuilder.classId=classId;
    requestBuilder.scope=scope;
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/send" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        NSMutableArray *sendHomeworks;
        sendHomeworks = [NSMutableArray array];
        XCSDPBSendHomeworkResponse *fetchHistoryhomeWorkResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        TX_PARSE_PB_OBJECT(XCSDPBSendHomeworkResponse, fetchHistoryhomeWorkResponse);
          completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError);
            });
        }
    }];
}

- (void)sendUnifiedHomework:(NSInteger)ClassId gameLevels:(NSArray *)gameLevels onCompleted:(void (^)(NSError *))onCompleted{
    
    XCSDPBSendUnifiedHomeworkRequestBuilder *requestBuilder = [XCSDPBSendUnifiedHomeworkRequest builder];
    requestBuilder.classId = ClassId;
    [requestBuilder setGameLevelsArray:gameLevels];
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/send_unified" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        XCSDPBSendUnifiedHomeworkResponse *homeworkResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        
        TX_PARSE_PB_OBJECT(XCSDPBSendUnifiedHomeworkResponse, homeworkResponse);
        
    completed:
        {
            
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError);
            });
        }
    }];
}

- (void)HomeworkRemainingCountClassId:(int64_t)classId onCompleted:(void (^)(NSError *error, BOOL customizedStatus, int32_t unifiedCount))onCompleted{
    
    DDLogInfo(@"%s classId=%lld ", __FUNCTION__,classId);
    
    XCSDPBHomeworkRemainingCountRequestBuilder *requestBuilder=[XCSDPBHomeworkRemainingCountRequest builder];
    requestBuilder.classId=classId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/remaining_count" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
      
        XCSDPBHomeworkRemainingCountResponse *fetchHistoryhomeWorkResponse = nil;
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        TX_PARSE_PB_OBJECT(XCSDPBHomeworkRemainingCountResponse, fetchHistoryhomeWorkResponse);
        
        BOOL Status=fetchHistoryhomeWorkResponse.customizedStatus;
        int32_t Count=fetchHistoryhomeWorkResponse.unifiedCount;
        completed:
        {

            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, Status,Count);
            });
        }
    }];
}

- (void)RankHomeWorksClassId:(int64_t)classId onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted{
    DDLogInfo(@" WorksClassId=%lld", classId);
    
    XCSDPBHomeworkRankingRequestBuilder  *requestBuilder =[XCSDPBHomeworkRankingRequest builder];
    requestBuilder.classId=classId;
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

- (void)fetchHomeGenerateDetailWithClass_ID: (int64_t) class_Id childUserId:(int64_t) childId onCompleted:(void (^)(NSError *error, NSArray *gameLevels))onCompleted{
    
    XCSDPBHomeworkGenerateDetailRequestBuilder *requestBuilder = [XCSDPBHomeworkGenerateDetailRequest builder];
    requestBuilder.classId = class_Id;
    requestBuilder.childUserId = childId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/homework/generate_detail" token:[TXApplicationManager sharedInstance].currentToken bodyData:[requestBuilder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
       
        NSError *innerError = nil;
        XCSDPBHomeworkGenerateDetailResponse *detailResponse = nil;
        
        TX_GO_TO_COMPLETED_IF_ERROR(innerError);
        
        TX_PARSE_PB_OBJECT(XCSDPBHomeworkGenerateDetailResponse, detailResponse);
        
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(innerError, detailResponse.gameLevels);
            });
        }
    }];
}
- (void)AbilityHomeWorksClassId:(int64_t)classId
                    onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted{
    DDLogInfo(@" ClassId=%lld", classId);
    
    XCSDPBClassAbilityRankingRequestBuilder  *requestBuilder =[XCSDPBClassAbilityRankingRequest builder];
    requestBuilder.classId = classId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/learning_ability/ranking"
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
@end
