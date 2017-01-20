//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXCheckIn.h"
#import "TXQrCheckInItem.h"
#import "TXChatManagerBase.h"

@class TXApplicationManager;

@interface TXCheckInManager : TXChatManagerBase

- (void)fetchAttendance:(int64_t)maxCheckInId
            onCompleted:(void (^)(NSError *error, NSArray *txCheckIns, BOOL hasMore))onCompleted;

/**
* 绑定卡
*
* @userId   如果是小孩，就是小孩的用户ID，如果是老师，就是老师的ID
*/
- (void)bindCard:(NSString *)cardCode
          userId:(int64_t)userId
     onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 挂失卡
*/
- (void)reportLossCard:(NSString *)cardCode
                userId:(int64_t)userId
           onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 从服务端获取历史刷卡信息
*/
- (void)fetchCheckIns:(int64_t)maxCheckInId
          onCompleted:(void (^)(NSError *error, NSArray *txCheckIns, BOOL hasMore))onCompleted;

/**
* 从数据库获取刷卡信息列表
*/
- (NSArray *)queryCheckIns:(int64_t)maxCheckInId
                     count:(int64_t)count
                     error:(NSError **)outError;

/**
* 获取最后一条刷卡
*/
- (TXCheckIn *)queryLastCheckIn:(NSError **)outError;

/**
* 获取绑定的卡
*/
- (void)fetchBindCards:(void (^)(NSError *error, NSArray/*<TXPBBindCardInfo>*/ *txpbBindCardInfos))onCompleted;

- (void)checkInWithUserId:(int64_t)userId
               cardNumber:(NSString *)cardNumber
              checkInTime:(int64_t)checkInTime
              onCompleted:(void (^)(NSError *error))onCompleted;

- (void)clearCheckIn:(int64_t)maxId onCompleted:(void (^)(NSError *error))onCompleted;

- (void)addQrCheckInItem:(int64_t)targetUserId
          targetUserName:(NSString *)targetUserName
          targetUserType:(NSString *)targetUserType
        targetCardNumber:(NSString *)targetCardNumber;

- (NSArray *)queryQrCheckInItems:(int64_t)maxId count:(int64_t)count;

- (int)queryQrCheckInItemCount;

- (void)clearAllSucceedQrCheckInItems;

- (void)uploadAllQrCheckInItems;

- (void)fetchDepartmentAttendance:(int64_t)departmentId
                             date:(int64_t)date
                      onCompleted:(void (^)(NSError *error, NSArray *presentUsers, NSArray *absenceUsers, NSArray *leaveUsers,BOOL isRestDay))onCompleted;

- (void)fetchChildAttendance:(int64_t)date
                 onCompleted:(void (^)(NSError *error, NSArray *presentDates, NSArray *absenceDates, NSArray *leaveDates, NSArray *restDates))onCompleted;

- (void)updateAttendance:(NSArray *)presentUserIds
          absenceUserIds:(NSArray *)absenceUserIds
            leaveUserIds:(NSArray *)leaveUserIds
                    date:(int64_t)date
             onCompleted:(void (^)(NSError *error))onCompleted;

- (void)fetchLeaves:(int64_t)maxId
             userId:(int64_t)userId
        onCompleted:(void (^)(NSError *error, NSArray *leaves, BOOL hasMore))onCompleted;

- (void)applyLeave:(NSString *)reason
         beginDate:(int64_t)beginDate
           endDate:(int64_t)endDate
         leaveType:(TXPBLeaveType)leaveType
            userId:(int64_t)userId
       onCompleted:(void (^)(NSError *error))onCompleted;

- (void)approveLeave:(int64_t)leaveId
               reply:(NSString *)reply
         onCompleted:(void (^)(NSError *error))onCompleted;

- (void)fetchRestDaysWithYear:(int64_t)year
                  onCompleted:(void (^)(NSError *error, NSArray *restDays))onCompleted;


@end