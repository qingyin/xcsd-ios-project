//
//  TXChatUserDbManager.h
//  TXChatSDK
//
//  Created by lingiqngwan on 6/7/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXEntities.h"
#import "TXChatCheckInDao.h"

@interface TXChatUserDbManager : NSObject
@property(nonatomic, readonly) TXChatCheckInDao *txChatCheckInDao;

- (instancetype)initWithUsername:(NSString *)username error:(NSError **)outError;

- (void)saveSettingValue:(NSString *)value forKey:(NSString *)key error:(NSError **)outError;

- (NSString *)getSettingValueByKey:(NSString *)key;

- (TXUser *)getUserByUserId:(int64_t)userId error:(NSError **)outError;

- (TXUser *)getUserByUsername:(NSString *)username error:(NSError **)outError;

- (void)addUser:(TXUser *)txUser error:(NSError **)outError;

- (void)deleteUserByUserId:(int64_t)userId error:(NSError **)outError;

- (TXDepartment *)getDepartmentByGroupId:(NSString *)groupId error:(NSError **)outError;

- (TXDepartment *)getDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError;

- (NSArray *)getAllDepartment:(NSError **)outError;

- (void)addDepartment:(TXDepartment *)department error:(NSError **)outError;

- (void)deleteDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError;

- (void)deleteDepartmentMembersByDepartmentId:(int64_t)departmentId error:(NSError **)outError;

- (NSArray *)getUsersByDepartmentId:(int64_t)departmentId userType:(TXPBUserType)userType error:(NSError **)outError;

- (void)putUsers:(NSArray *)userIds toDepartment:(int64_t)departmentId error:(NSError **)outError;

- (NSArray *)getParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError;

- (void)markNoticeAsRead:(int64_t)noticeId error:(NSError **)outError;

- (void)markGardenMailAsRead:(int64_t)gardenMailId error:(NSError **)outError;

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId error:(NSError **)outError;

- (TXNotice *)getLastInboxNotice;

#pragma mark 通知

- (void)addNotice:(TXNotice *)txNotice error:(NSError **)outError;

- (NSArray *)getNotices:(int64_t)maxNoticeId count:(int64_t)count error:(NSError **)outError;

- (NSArray *)getNotices:(int64_t)maxNoticeId
                  count:(int64_t)count
                isInbox:(BOOL)isInbox
                  error:(NSError **)outError;

- (TXNotice *)getNoticeById:(int64_t)id error:(NSError **)outError;

- (TXNotice *)getNoticeByNoticeId:(int64_t)noticeId error:(NSError **)outError;

- (TXNotice *)getLastNotice;

#pragma mark 刷卡

- (NSArray *)getCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError;

- (TXCheckIn *)getLastCheckIn;

- (void)addCheckIn:(TXCheckIn *)txCheckIn error:(NSError **)outError;

#pragma mark Feed

/**
* 从数据库中获取feed list
*/
- (NSArray *)getFeeds:(int64_t)maxFeedId
                count:(int64_t)count
              isInbox:(BOOL)isInbox
                error:(NSError **)outError;

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count userId:(int64_t)userId error:(NSError **)outError;

/**
* 从数据库中获取comment list
*/
- (NSArray *)getComments:(int64_t)targetId
              targetType:(TXPBTargetType)targetType
             commentType:(TXPBCommentType)commentType
            maxCommentId:(int64_t)maxCommentId
                   count:(int64_t)count
                   error:(NSError **)outError;

- (void)addFeed:(TXFeed *)txFeed error:(NSError **)outError;

- (void)deleteFeedByFeedId:(int64_t)feedId error:(NSError **)outError;

- (void)deleteCommentByCommentId:(int64_t)commentId error:(NSError **)outError;

- (void)addComment:(TXComment *)txComment error:(NSError **)outError;

- (void)addPost:(TXPost *)txPost error:(NSError **)outError;

- (TXPost *)getLastPost:(TXPBPostType)postType error:(NSError **)outError;

- (NSArray *)getPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError;

- (int64_t)getLastGroupId:(TXPBPostType)postType error:(NSError **)outError;

- (TXPost *)getLastPostOfGroup:(TXPBPostType)postType groupId:(int64_t)groupId error:(NSError **)outError;

- (void)addGardenMail:(TXGardenMail *)txGardenMail error:(NSError **)outError;

- (void)addFeedMedicineTask:(TXFeedMedicineTask *)txFeedMedicineTask error:(NSError **)outError;

- (NSArray *)getGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;

- (NSArray *)getFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;

- (void)deleteAllNotice;

- (void)deleteAllNotice:(BOOL)isInbox;

- (void)deleteAllCheckIn;

- (void)deleteAllFeed;

- (void)deleteAllFeedByUserId:(int64_t)userId;

- (void)deleteAllPostByType:(TXPBPostType)txpbPostType;

- (void)deleteAllGardenMail;

- (void)deleteAllFeedMedicineTask;

- (NSArray *)getAllDeletedMessage;

- (void)addDeletedMessage:(TXDeletedMessage *)txDeletedMessage error:(NSError **)outError;

- (void)deleteDeletedMessageByMsgId:(NSString *)msgId;
@end
