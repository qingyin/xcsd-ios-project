//
//  XCSDHomeWorkManager.h
//  Pods
//
//  Created by gaoju on 16/3/15.
//
//
#import <Foundation/Foundation.h>
#import "TXPBChat.pb.h"
#import "TXChatManagerBase.h"
#import "XCSDHomeWork.h"
#import "XCSDHomeWorkRank.h"
#import "XCSDHomeWorkCalendar.h"
#import "XCSDHomeWorkDao.h"

@interface XCSDHomeWorkManager : TXChatManagerBase

@property(nonatomic, readonly) XCSDHomeWork *xcsdHomeWorkItem;
@property (nonatomic,readonly) XCSDHomeWorkRank *xcsdHomeWorkRankItem;
@property (nonatomic,readonly) XCSDHomeWorkCalendar *xcsdHomeWorkCalendar;

/**
 * 从服务端获取作业列表
 */
- (void)fetchHomeWorks:(BOOL)isInbox
         maxHomeWorkId:(int64_t)maxHomeWorkId
           onCompleted:(void (^)(NSError *error, NSArray/*<XCSDHomeWork>*/ *xcsdHomeWorks, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;

- (NSArray *)queryHomeWork:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError;
- (XCSDHomeWork *)queryLastHomework:(NSError **)outError;

/**
 *  获取作业详情
 */
- (void)fetchHomeworkDetail:(NSInteger)memberId onCompleted:(void (^)(NSError *error, XCSDPBHomeworkDetailResponse *response))onCompleted;

/**
 *  删除作业
 *
 */
- (void)DeletehomeworId:(int64_t)homeworkId
                   onCompleted:(void (^)(NSError *error))onCompleted;
/**
 *  读作业
 */
- (void)ReadhomeworkId:(int64_t)homeworkId
           onCompleted:(void (^)(NSError *error))onCompleted;
/**
 *  分数排名
 *
 */
- (void)RankHomeWorksChildUserId:(int64_t)ChildUserId
           onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;
//学能考勤
- (void)fetchChildAttendance:(int64_t)ChildUserId
                 onCompleted:(void (^)(NSError *error, NSArray *finishedDates, NSArray *unfinishedDates))onCompleted;
@end
