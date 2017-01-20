//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXNotice.h"
#import "TXChatManagerBase.h"


@interface TXNoticesManager : TXChatManagerBase
- (void)clearNotice:(int64_t)maxId isInbox:(BOOL)isInbox onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 发通知
*/
- (void)sendNotice:(NSString *)content
          attaches:(NSArray/*<TXPBAttach>*/ *)attaches
     toDepartments:(NSArray/*<NoticeDepartment>*/ *)toDepartments
       onCompleted:(void (^)(NSError *error, int64_t noticeId))onCompleted;

/**
* 从服务端获取历史通知
*/
- (void)fetchNotices:(BOOL)isInbox
         maxNoticeId:(int64_t)maxNoticeId
         onCompleted:(void (^)(NSError *error, NSArray/*<TXNotice>*/ *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;

/**
* 从服务端获取通知的部门
*/
- (void)fetchNoticeDepartments:(int64_t)noticeId
                   onCompleted:(void (^)(NSError *error, NSArray *txpbNoticesDepartments))onCompleted;

/**
* 从服务端获取通知的部门下面的成员
*/
- (void)fetchNoticeMembers:(int64_t)noticeId
              departmentId:(int64_t)departmentId
               onCompleted:(void (^)(NSError *error, NSArray *txpbNoticeMembers))onCompleted;

/**
* 从数据库获取通知列表
*/
- (NSArray *)queryNotices:(int64_t)maxNoticeId
                    count:(int64_t)count
                    error:(NSError **)outError;

/**
* 从数据库获取通知列表
*/
- (NSArray *)queryNotices:(int64_t)maxNoticeId
                    count:(int64_t)count
                  isInbox:(BOOL)isInbox
                    error:(NSError **)outError;

/**
* 根据id获取通知
*/
- (TXNotice *)queryNoticeById:(int64_t)id
                        error:(NSError **)outError;

/**
* 根据notice_id获取通知
*/
- (TXNotice *)queryNoticeByNoticeId:(int64_t)noticeId
                              error:(NSError **)outError;

/**
* 获取最后一条通知
*/
- (TXNotice *)queryLastNotice:(NSError **)outError;

/**
* 将通知标记为已读
*/
- (void)markNoticeHasRead:(int64_t)noticeId
              onCompleted:(void (^)(NSError *error))onCompleted;

@end