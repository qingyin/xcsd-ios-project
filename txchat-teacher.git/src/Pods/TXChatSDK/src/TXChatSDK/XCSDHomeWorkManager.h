//
//  XCSDHomeWorkManager.h
//  Pods
//
//  Created by gaoju on 16/4/5.
//
//

//#import <TXChatSDK/TXChatSDK.h>
#import <Foundation/Foundation.h>
#import "TXPBBase.pb.h"
#import "TXChatManagerBase.h"
#import "XCSDClassHomework.h"
#import "XCSDHomeworkMember.h"
#import "XCSDHomeWorkGenerate.h"
#import "XCSDSendHomework.h"
#import "XCSDHomeworkRemainCount.h"
#import "XCSDHomeWorkRank.h"
#import "XCSDHomeWorkAbility.h"
@interface XCSDHomeWorkManager : TXChatManagerBase


@property (nonatomic,readonly)  XCSDHomeworkMember *homeworkMember;
@property (nonatomic,readonly)  XCSDClassHomework *classHomework;
@property (nonatomic,readonly)  XCSDHomeWorkGenerate *homeWorkGenerate;
@property (nonatomic,readonly)  XCSDSendHomework *sendHomework;
@property (nonatomic,readonly) XCSDHomeworkRemainCount *homeworkRemainCount;
@property (nonatomic,readonly) XCSDHomeWorkRank *xcsdHomeWorkRankItem;
@property (nonatomic,readonly) XCSDHomeWorkAbility *homeWorkAbility;
/**
 *  获取发送的作业列表
 */
- (void)HomeworkSentList:(BOOL)isInbox sentHomeWorksHasMaxId:(int64_t)maxId  onCompleted:(void (^)(NSError *error, NSArray *Homeworks,BOOL hasMore, BOOL lastOneHasChanged))onCompleted;

/**
 *  获取发送的作业成员列表
 */
- (void)HomeworkMemberList:(BOOL)isInbox HomeworkId:(int64_t)homeworkId onCompleted:(void (^)(NSError *error, NSArray *members,BOOL hasMore, BOOL lastOneHasChanged))onCompleted;

/**
 * 生成定制作业
 */
- (void)GenerateHomeworkListClassId:(int64_t)classId onCompleted:(void (^)(NSError *error, NSArray *homeWork, BOOL lastOneHasChanged))onCompleted;

- (void)sendUnifiedHomework:(NSInteger) ClassId gameLevels:(NSArray *)gameLevels onCompleted:(void (^)(NSError *error)) onCompleted;
/**
 *  发送定制作业
 */
- (void)SendHomework:(BOOL)isInbox ClassId:(int64_t)classId StudentScope:(int32_t)scope  onCompleted:(void (^)(NSError *error))onCompleted;
/**
 * 获取可发送的作业数量
 */
- (void)HomeworkRemainingCountClassId:(int64_t)classId onCompleted:(void (^)(NSError *error, BOOL customizedStatus, int32_t unifiedCount))onCompleted;

/**
 *  获取作业详情
 */
- (void)fetchHomeworkDetail:(NSInteger)memberId onCompleted:(void (^)(NSError *error, XCSDPBHomeworkDetailResponse *response))onCompleted;

//生成作业详情    URL:/homework/generate_detail
- (void)fetchHomeGenerateDetailWithClass_ID: (int64_t) class_Id childUserId:(int64_t) childId onCompleted:(void (^)(NSError *error, NSArray *gameLevels))onCompleted;

/**
 *  分数排名
 *
 */
- (void)RankHomeWorksClassId:(int64_t)classId onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;
/**
 *  商数排名
 *
 */
- (void)AbilityHomeWorksClassId:(int64_t)classId
                     onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;

//- (voi)fetchHomeworkDetail:(NSInteger)memerId onCompleted:(void(^)(NSError *,XCSDPBHomeworkDetailResponse *))onCom
@end
