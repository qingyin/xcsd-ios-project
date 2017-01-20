//
// Created by lingqingwan on 9/21/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatClient.h"

@interface TXChatClient (Deprecated)
/**
* 向服务端发一个ping消息，用来检测当前的登录状态是否合法，一般用来在app被切换到前台时候调用
*/
- (void)pingWithCompleted:(void (^)(NSError *error))onCompleted;

/**
* 登录
*/
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
              onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted;

/**
* 注销登录
*/
- (void)logout:(void (^)(NSError *error))onCompleted;

- (void)cleanCurrentContext;

/**
* 获取当前登录用户
*/
- (TXUser *)getCurrentUser:(NSError **)outError;

/**
* 获取当前用户的个性化配置
*/
- (NSDictionary *)getCurrentUserProfiles:(NSError **)outError;


-(NSString*)getCurrentUserToken;

/**
* 绑定小孩
*/
- (void)bindChild:(int64_t)childUserId
       parentType:(TXPBParentType)txpbParentType
         birthday:(int64_t)birthday
          guarder:(NSString *)guarder
      onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 更新小孩的绑定关系
*/
- (void)updateBindInfo:(int64_t)parentId
            parentType:(TXPBParentType)txpbParentType
           onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 向手机发验证码
*/
- (void)sendVerifyCodeBySMS:(NSString *)mobilePhoneNumber
                       type:(TXPBSendSmsCodeType)type
                    isVoice:(BOOL)isVoice
                onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 根据手机号激活用户
*/
- (void)activeUser:(NSString *)mobilePhoneNumber
        verifyCode:(NSString *)verifyCode
          password:(NSString *)password
       onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted;

/**
* 更换手机号
*/
- (void)changeMobilePhoneNumber:(NSString *)newMobilePhoneNumber
                     verifyCode:(NSString *)verifyCode
                    onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 修改密码
*/
- (void)changePassword:(NSString *)newPassword
     mobilePhoneNumber:(NSString *)mobilePhoneNumber
            verifyCode:(NSString *)verifyCode
           onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 更新个人信息（性别，签名，姓名，等。）
*/
- (void)updateUserInfo:(TXUser *)txUser
           onCompleted:(void (^)(NSError *error))onCompleted;

#pragma mark 联系人

/**
* 从服务端同步一次部门信息，在同步完成后，会将部门信息插入数据库，然后回调onCompleted，客户端在收到回掉后，假如没有出错，
* 需要重新从数据库中读取一遍部门信息，出错则根据错误信息，做相应的错误提示。
*/
- (void)fetchDepartments:(void (^)(NSError *error))onCompleted;

/**
*
*/
- (void)fetchDepartmentsIfNone:(void (^)(NSError *error))onCompleted;

/**
* 从数据库中获取所有部门
*/
- (NSArray/*<Department>*/ *)getAllDepartments:(NSError **)outError;

/**
* 从服务端同步一次部门成员列表
*/
- (void)fetchDepartmentMembers:(int64_t)departmentId
                clearLocalData:(BOOL)clearLocalData
                   onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 从数据库中获取指定部门的所有成员
*/
- (NSArray/*<TXUser>*/ *)getDepartmentMembers:(int64_t)departmentId
                                     userType:(TXPBUserType)userType
                                        error:(NSError **)outError;

/**
*从服务端同步用户信息
*/
- (void)fetchUserByUserId:(int64_t)userId
              onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted;

/**
* 从数据中根据用户ID获取用户信息
*/
- (TXUser *)getUserByUserId:(int64_t)userId
                      error:(NSError **)outError;

/**
* 根据宝宝ID找到家长
*/
- (NSArray *)getParentUsersByChildUserId:(int64_t)childUserId
                                   error:(NSError **)outError;

/**
* 从数据中根据用户名获取用户信息
*/
- (TXUser *)getUserByUsername:(NSString *)username
                        error:(NSError **)outError;

/**
* 从服务端同步部门信息
*/
- (void)fetchDepartmentByDepartmentId:(int64_t)departmentId
                          onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 从数据库中根据部门id获取部门信息
*/
- (TXDepartment *)getDepartmentByDepartmentId:(int64_t)departmentId
                                        error:(NSError **)outError;

/**
*
*/
- (void)fetchDepartmentByGroupId:(NSString *)groupId
                     onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 根据群聊id获取部门
*/
- (TXDepartment *)getDepartmentByGroupId:(NSString *)groupId
                                   error:(NSError **)outError;

/**
* 获取当前用户的小孩
* 首选绑定,没有绑定查预留手机号
*/
- (void)fetchChild:(void (^)(NSError *error, TXUser *childUser))onCompleted;


#pragma mark 通知

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
- (NSArray *)getNotices:(int64_t)maxNoticeId
                  count:(int64_t)count
                  error:(NSError **)outError;

/**
* 从数据库获取通知列表
*/
- (NSArray *)getNotices:(int64_t)maxNoticeId
                  count:(int64_t)count
                isInbox:(BOOL)isInbox
                  error:(NSError **)outError;

/**
* 根据id获取通知
*/
- (TXNotice *)getNoticeById:(int64_t)id
                      error:(NSError **)outError;

/**
* 根据notice_id获取通知
*/
- (TXNotice *)getNoticeByNoticeId:(int64_t)noticeId
                            error:(NSError **)outError;

/**
* 获取最后一条通知
*/
- (TXNotice *)getLastNotice:(NSError **)outError;

/**
* 将通知标记为已读
*/
- (void)markNoticeHasRead:(int64_t)noticeId
              onCompleted:(void (^)(NSError *error))onCompleted;


#pragma mark 刷卡

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
- (NSArray *)getCheckIns:(int64_t)maxCheckInId
                   count:(int64_t)count
                   error:(NSError **)outError;

/**
* 获取最后一条刷卡
*/
- (TXCheckIn *)getLastCheckIn:(NSError **)outError;

/**
* 获取绑定的卡
*/
- (void)fetchBindCards:(void (^)(NSError *error, NSArray/*<TXPBBindCardInfo>*/ *txpbBindCardInfos))onCompleted;

/**
* 删除本地缓存
*/
- (void)deleteLocalCache;

#pragma mark 喂药

/**
* 发送喂药任务
*/
- (void)sendFeedMedicineTask:(NSString *)content
                    attaches:(NSArray/*<TXPBAttach>*/ *)attaches
                   beginDate:(int64_t)beginDate
                 onCompleted:(void (^)(NSError *error, int64_t feedMedicineTaskId))onCompleted;

/**
* 获取喂药任务列表
*/
- (void)fetchFeedMedicineTasks:(int64_t)maxId
                   onCompleted:(void (^)(NSError *error, NSArray *txFeedMedicineTasks, BOOL hasMore))onCompleted;

/**
* 获取文件上传token
*/
- (void)fetchFileUploadTokenWithCompleted:(void (^)(NSError *error, NSString *token))onCompleted;

/**
* 上传文件
*/
- (void)uploadData:(NSData *)data
           uuidKey:(NSUUID *)uuidKey
     fileExtension:(NSString *)fileExtension
cancellationSignal:(BOOL (^)())cancellationSignal
   progressHandler:(void (^)(NSString *key, float percent))progressHandler
       onCompleted:(void (^)(NSError *error, NSString *serverFileKey, NSString *serverFileUrl))onCompleted;

/**
* 获取已被绑定的家长
*/
- (void)fetchBoundParents:(void (^)(NSError *error, NSArray/*<BindingParentInfo>*/ *bindingParentInfos))onCompleted;

/**
* 园长信箱发信
*/
- (void)sendGardenMail:(NSString *)content
           isAnonymous:(BOOL)isAnonymous
           onCompleted:(void (^)(NSError *error, int64_t gardenMailId))onCompleted;

/**
* 获取园长信箱邮件
*/
- (void)fetchGardenMails:(int64_t)maxId
             onCompleted:(void (^)(NSError *error, NSArray *txGardenMails, BOOL hasMore))onCompleted;


/**
* 保存用户个人配置信息，如禁言
*/
- (void)saveUserProfiles:(NSDictionary *)userProfiles
             onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 获取用户个人配置信息
*/
- (void)fetchUserProfiles:(void (^)(NSError *error, NSDictionary *userProfiles))onCompleted;

/**
*激活邀请的用户
*/
- (void)activeInviteUser:(NSString *)mobilePhoneNumber
              verifyCode:(NSString *)verifyCode
              parentType:(TXPBParentType)parentType
                password:(NSString *)password
             onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted;

/**
*解除绑定的家长
*/
- (void)UnbindParent:(int64_t)parentId
         onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 添加评论
*/
- (void)sendComment:(NSString *)content
        commentType:(TXPBCommentType)commentType
           toUserId:(int64_t)toUserId
           targetId:(int64_t)targetId
         targetType:(TXPBTargetType)targetType
        onCompleted:(void (^)(NSError *error, int64_t commentId))onCompleted;

/**
* 删除评论
*/
- (void)deleteComment:(int64_t)commentId
          onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 发给我的评论
*/
- (void)fetchCommentsToMe:(int64_t)maxId
              onCompleted:(void (^)(NSError *error, NSArray *comments, NSArray *txFeeds, BOOL hasMore))onCompleted;

/**
* 获取目标的评论列表
*/
- (void)fetchCommentsByTargetId:(int64_t)targetId
                     targetType:(TXPBTargetType)targetType
                   maxCommentId:(int64_t)maxCommentId
                    onCompleted:(void (^)(NSError *error, NSArray *comments, BOOL hasMore))onCompleted;

/**
* 公告 活动 微学院
*/
- (void)fetchPosts:(int64_t)maxId
          gardenId:(int64_t)gardenId
          postType:(TXPBPostType)postType
       onCompleted:(void (^)(NSError *error, NSArray *posts, BOOL hasMore))onCompleted;


/**
* 获取亲子圈
*/
- (void)fetchFeeds:(int64_t)maxId
           isInbox:(BOOL)isInbox
       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted;

/**
* 从数据库中获取feed list
*/
- (NSArray *)getFeeds:(int64_t)maxFeedId
                count:(int64_t)count
              isInbox:(BOOL)isInbox
                error:(NSError **)outError;

/**
* 从数据库中获取feed list
*/
- (NSArray *)getFeeds:(int64_t)maxFeedId
                count:(int64_t)count
               userId:(int64_t)userId
                error:(NSError **)outError;

/**
* 从数据库中获取comment list
*/
- (NSArray *)getComments:(int64_t)targetId
              targetType:(TXPBTargetType)targetType
             commentType:(TXPBCommentType)commentType
            maxCommentId:(int64_t)maxCommentId
                   count:(int64_t)count
                   error:(NSError **)outError;

/**
* 获取指定用户的亲子圈
*/
- (void)fetchFeeds:(int64_t)maxId
            userId:(int64_t)userId
       onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted;

/**
* 删除自己的亲子圈
*/
- (void)deleteFeed:(int64_t)feedId
       onCompleted:(void (^)(NSError *error))onCompleted;


/**
* 修改密码
*/
- (void)changePassword:(NSString *)oldPassword
           newPassword:(NSString *)newPassword
           onCompleted:(void (^)(NSError *error))onCompleted;

/**
*从服务端获取计数器
*/
- (void)fetchCounters:(void (^)(NSError *error, NSMutableDictionary *countersDictionary))onCompleted;

/**
* 获取计数器字典
*/
- (NSDictionary *)getCountersDictionary;

/**
* 设置计数器字典key-value
*/
- (void)setCountersDictionaryValue:(int)value forKey:(NSString *)key;

- (TXPost *)getLastPost:(TXPBPostType)postType error:(NSError **)outError;

- (NSArray *)getPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError;

- (void)setUserProfileValue:(int64_t)value forKey:(NSString *)key;

- (NSArray *)getGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;

- (NSArray *)getFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;

- (void)mute:(int64_t)departmentId
childUserIds:(NSArray *)childUserIds
        muteType:(TXPBMuteType)muteType
 onCompleted:(void (^)(NSError *error))onCompleted;

- (void)unMute:(int64_t)departmentId
   childUserId:(int64_t)childUserId
        muteType:(TXPBMuteType)muteType
   onCompleted:(void (^)(NSError *error))onCompleted;

- (void)fetchMutedUserIds:(int64_t)departmentId
        muteType:(TXPBMuteType)muteType
        onCompleted:(void (^)(NSError *error, NSArray *childUserIds, TXPBMuteType txpbMuteType))onCompleted;

- (void)markGardenMailAsRead:(int64_t)gardenMailId
                 onCompleted:(void (^)(NSError *error))onCompleted;

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId
                       onCompleted:(void (^)(NSError *error))onCompleted;

- (void)log:(NSString *)content onCompleted:(void (^)(NSError *error))onCompleted;

- (void)updateDeviceToken:(NSString *)deviceToken
             platformType:(TXPBPlatformType)platformType
                osVersion:(NSString *)osVersion
            mobileVersion:(NSString *)mobileVersion
                 deviceId:(NSString *)deviceId
              onCompleted:(void (^)(NSError *error))onCompleted;

- (void)upgrade:(TXPBPlatformType)txpbPlatformType
    onCompleted:(void (^)(NSError *error, TXPBUpgradeResponse *txpbUpgradeResponse))onCompleted;


- (void)clearCheckIn:(int64_t)maxId onCompleted:(void (^)(NSError *error))onCompleted;

- (void)clearNotice:(int64_t)maxId isInbox:(BOOL)isInbox onCompleted:(void (^)(NSError *error))onCompleted;

/**
 *  获取本地数据库的课程
 */
- (NSArray *)getCourses:(NSInteger) courseId count:(NSInteger)count;

/**
 *  从服务端获取课程列表
 */
- (void)fetchCourseList:(NSInteger)aPage onCompleted:(void (^)(NSError *error, NSArray *lessons,BOOL hasMore))onCompleted;

/**
 * 从服务端获取homework列表
 */
- (void)fetchHomeWorks:(BOOL)isInbox
         maxHomeWorkId:(int64_t)maxHomeWorkId
         onCompleted:(void (^)(NSError *error, NSArray/*<XCSDHomeWork>*/ *xcsdHomeWork, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;

- (NSArray *)getHomeWork:(int64_t)maxhomeWorkId count:(int64_t)count error:(NSError **)outError;
- (XCSDHomeWork *)getLastHomework:(NSError **)outError;

/**
 *  删除作业k
 */
- (void)DeletehomeworId:(int64_t)homeworkId
            onCompleted:(void (^)(NSError *error))onCompleted;
/**
 *  读作业
 *
 */
- (void)ReadhomeworkId:(int64_t)homeworkId
                 onCompleted:(void (^)(NSError *error))onCompleted;
/**
 *   作业排名
 *
 */
- (void)RankHomeWorksChildUserId:(int64_t)ChildUserId
                     onCompleted:(void (^)(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged))onCompleted;
/**
 *  学能考勤
 */
- (void)fetchChildAttendance:(int64_t)ChildUserId
                 onCompleted:(void (^)(NSError *error, NSArray *finishedDates, NSArray *unfinishedDates))onCompleted;

/**
 *  成绩
 *
 */
- (void)HomeworkResult:(NSInteger) childId onCompleted:(void(^)(NSError *error, XCSDPBAbilityStatResponse *abilityDetails)) onCompleted;
/**
 *  获取游戏状态
 *
 */
- (void)GameStatus:(NSInteger) userId ability:(XCSDPBAbility) ability onCompleted:(void(^)(NSError *error, NSInteger totalScore, NSArray *gameList)) onCompleted;



@end