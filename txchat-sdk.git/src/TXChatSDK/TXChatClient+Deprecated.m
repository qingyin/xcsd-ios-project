//
// Created by lingqingwan on 9/21/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXChatClient+Deprecated.h"


@implementation TXChatClient (Deprecated)
- (void)pingWithCompleted:(void (^)(NSError *error))onCompleted {
    
    [[self userManager] fetchDepartments:^(NSError *error, NSArray *txDepartments) {
        onCompleted(error);
    }];
    [self.counterManager fetchCounters:nil];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    [self.userManager loginWithUsername:username password:password onCompleted:onCompleted];
}

- (void)logout:(void (^)(NSError *error))onCompleted {
    [self.userManager logout:onCompleted];
}

- (void)cleanCurrentContext {
    [[self applicationManager] cleanCurrentContext];
}

- (TXUser *)getCurrentUser:(NSError **)outError {
    return self.applicationManager.currentUser;
}

- (NSDictionary *)getCurrentUserProfiles:(NSError **)outError {
    return self.applicationManager.currentUserProfiles;
}

- (void)bindChild:(int64_t)childUserId parentType:(TXPBParentType)txpbParentType birthday:(int64_t)birthday guarder:(NSString *)guarder onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager bindChild:childUserId parentType:txpbParentType birthday:birthday guarder:guarder onCompleted:onCompleted];
}

- (void)updateBindInfo:(int64_t)parentId parentType:(TXPBParentType)txpbParentType onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager updateBindInfo:parentId parentType:txpbParentType onCompleted:onCompleted];
}

- (void)sendVerifyCodeBySMS:(NSString *)mobilePhoneNumber type:(TXPBSendSmsCodeType)type isVoice:(BOOL)isVoice onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager sendVerifyCodeBySMS:mobilePhoneNumber type:type isVoice:isVoice onCompleted:onCompleted];
}

- (void)activeUser:(NSString *)mobilePhoneNumber verifyCode:(NSString *)verifyCode password:(NSString *)password onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    [self.userManager activeUser:mobilePhoneNumber verifyCode:verifyCode password:password onCompleted:onCompleted];
}

- (void)changeMobilePhoneNumber:(NSString *)newMobilePhoneNumber verifyCode:(NSString *)verifyCode onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager changeMobilePhoneNumber:newMobilePhoneNumber verifyCode:verifyCode onCompleted:onCompleted];
}

- (void)changePassword:(NSString *)newPassword mobilePhoneNumber:(NSString *)mobilePhoneNumber verifyCode:(NSString *)verifyCode onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager changePassword:newPassword mobilePhoneNumber:mobilePhoneNumber verifyCode:verifyCode onCompleted:onCompleted];
}

- (void)updateUserInfo:(TXUser *)txUser onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager updateUserInfo:txUser onCompleted:onCompleted];
}

- (void)fetchDepartments:(void (^)(NSError *error))onCompleted {
    [self.userManager fetchDepartments:^(NSError *error, NSArray *txDepartments) {
        onCompleted(error);
    }];
}

- (void)fetchDepartmentsIfNone:(void (^)(NSError *error))onCompleted {
    [self.userManager fetchDepartmentsIfNone:onCompleted];
}

- (NSArray/*<Department>*/ *)getAllDepartments:(NSError **)outError {
    return [self.userManager getAllDepartments:outError];
}

- (void)fetchDepartmentMembers:(int64_t)departmentId clearLocalData:(BOOL)clearLocalData onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager fetchDepartmentMembers:departmentId clearLocalData:clearLocalData onCompleted:onCompleted];
}

- (NSArray/*<TXUser>*/ *)getDepartmentMembers:(int64_t)departmentId userType:(TXPBUserType)userType error:(NSError **)outError {
    return [self.userManager queryDepartmentMembers:departmentId userType:userType error:outError];
}

- (void)fetchUserByUserId:(int64_t)userId onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    [self.userManager fetchUserByUserId:userId onCompleted:onCompleted];
}

- (TXUser *)getUserByUserId:(int64_t)userId error:(NSError **)outError {
    return [self.userManager queryUserByUserId:userId error:outError];
}

- (NSArray *)getParentUsersByChildUserId:(int64_t)childUserId error:(NSError **)outError {
    return [self.userManager queryParentUsersByChildUserId:childUserId error:outError];
}

- (TXUser *)getUserByUsername:(NSString *)username error:(NSError **)outError {
    return [self.userManager queryUserByUsername:username error:outError];
}

- (void)fetchDepartmentByDepartmentId:(int64_t)departmentId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager fetchDepartmentByDepartmentId:departmentId onCompleted:onCompleted];
}

- (TXDepartment *)getDepartmentByDepartmentId:(int64_t)departmentId error:(NSError **)outError {
    return [self.userManager getDepartmentByDepartmentId:departmentId error:outError];
}

- (void)fetchDepartmentByGroupId:(NSString *)groupId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager fetchDepartmentByGroupId:groupId onCompleted:onCompleted];
}

- (TXDepartment *)getDepartmentByGroupId:(NSString *)groupId error:(NSError **)outError {
    return [self.userManager getDepartmentByGroupId:groupId error:outError];
}

- (void)fetchChild:(void (^)(NSError *error, TXUser *childUser))onCompleted {
    [self.userManager fetchChild:onCompleted];
}

- (void)sendNotice:(NSString *)content attaches:(NSArray/*<TXPBAttach>*/ *)attaches toDepartments:(NSArray/*<NoticeDepartment>*/ *)toDepartments onCompleted:(void (^)(NSError *error, int64_t noticeId))onCompleted {
    [self.noticeManager sendNotice:content attaches:attaches toDepartments:toDepartments onCompleted:onCompleted];
}

- (void)fetchNotices:(BOOL)isInbox maxNoticeId:(int64_t)maxNoticeId onCompleted:(void (^)(NSError *error, NSArray/*<TXNotice>*/ *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged))onCompleted {
    [self.noticeManager fetchNotices:isInbox maxNoticeId:maxNoticeId onCompleted:onCompleted];
}

- (void)fetchNoticeDepartments:(int64_t)noticeId onCompleted:(void (^)(NSError *error, NSArray *txpbNoticesDepartments))onCompleted {
    [self.noticeManager fetchNoticeDepartments:noticeId onCompleted:onCompleted];
}

- (void)fetchNoticeMembers:(int64_t)noticeId departmentId:(int64_t)departmentId onCompleted:(void (^)(NSError *error, NSArray *txpbNoticeMembers))onCompleted {
    [self.noticeManager fetchNoticeMembers:noticeId departmentId:departmentId onCompleted:onCompleted];
}

- (NSArray *)getNotices:(int64_t)maxNoticeId count:(int64_t)count error:(NSError **)outError {
    return [self.noticeManager queryNotices:maxNoticeId count:count error:outError];
}

- (NSArray *)getNotices:(int64_t)maxNoticeId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    return [self.noticeManager queryNotices:maxNoticeId count:count isInbox:isInbox error:outError];
}

- (TXNotice *)getNoticeById:(int64_t)id1 error:(NSError **)outError {
    return [self.noticeManager queryNoticeById:id1 error:outError];
}

- (TXNotice *)getNoticeByNoticeId:(int64_t)noticeId error:(NSError **)outError {
    return [self.noticeManager queryNoticeByNoticeId:noticeId error:outError];
}

- (TXNotice *)getLastNotice:(NSError **)outError {
    return [self.noticeManager queryLastNotice:outError];
}

- (void)markNoticeHasRead:(int64_t)noticeId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.noticeManager markNoticeHasRead:noticeId onCompleted:onCompleted];
}

- (void)bindCard:(NSString *)cardCode userId:(int64_t)userId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.checkInManager bindCard:cardCode userId:userId onCompleted:onCompleted];
}

- (void)reportLossCard:(NSString *)cardCode userId:(int64_t)userId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.checkInManager reportLossCard:cardCode userId:userId onCompleted:onCompleted];
}

- (void)fetchCheckIns:(int64_t)maxCheckInId onCompleted:(void (^)(NSError *error, NSArray *txCheckIns, BOOL hasMore))onCompleted {
    [self.checkInManager fetchCheckIns:maxCheckInId onCompleted:onCompleted];
}

- (NSArray *)getCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError {
    return [self.checkInManager queryCheckIns:maxCheckInId count:count error:outError];
}

- (TXCheckIn *)getLastCheckIn:(NSError **)outError {
    return [self.checkInManager queryLastCheckIn:outError];
}

- (void)fetchBindCards:(void (^)(NSError *error, NSArray/*<TXPBBindCardInfo>*/ *txpbBindCardInfos))onCompleted {
    [self.checkInManager fetchBindCards:onCompleted];
}

- (void)deleteLocalCache {
    [self.applicationManager deleteLocalCache];
}

- (void)sendFeedMedicineTask:(NSString *)content attaches:(NSArray/*<TXPBAttach>*/ *)attaches beginDate:(int64_t)beginDate onCompleted:(void (^)(NSError *error, int64_t feedMedicineTaskId))onCompleted {
    [self.feedMedicineTaskManager sendFeedMedicineTask:content attaches:attaches beginDate:beginDate onCompleted:onCompleted];
}

- (void)fetchFeedMedicineTasks:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *txFeedMedicineTasks, BOOL hasMore))onCompleted {
    [self.feedMedicineTaskManager fetchFeedMedicineTasks:maxId onCompleted:onCompleted];
}

- (void)fetchFileUploadTokenWithCompleted:(void (^)(NSError *error, NSString *token))onCompleted {
    [self.fileManager fetchFileUploadTokenWithCompleted:onCompleted];
}

- (void)uploadData:(NSData *)data uuidKey:(NSUUID *)uuidKey fileExtension:(NSString *)fileExtension cancellationSignal:(BOOL (^)())cancellationSignal progressHandler:(void (^)(NSString *key, float percent))progressHandler onCompleted:(void (^)(NSError *error, NSString *serverFileKey, NSString *serverFileUrl))onCompleted {
    [self.fileManager uploadData:data uuidKey:uuidKey fileExtension:fileExtension cancellationSignal:cancellationSignal progressHandler:progressHandler onCompleted:onCompleted];
}

- (void)fetchBoundParents:(void (^)(NSError *error, NSArray/*<BindingParentInfo>*/ *bindingParentInfos))onCompleted {
    [self.userManager fetchBoundParents:onCompleted];
}

- (void)sendGardenMail:(NSString *)content isAnonymous:(BOOL)isAnonymous onCompleted:(void (^)(NSError *error, int64_t gardenMailId))onCompleted {
    [self.gardenMailManager sendGardenMail:content isAnonymous:isAnonymous onCompleted:onCompleted];
}

- (void)fetchGardenMails:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *txGardenMails, BOOL hasMore))onCompleted {
    [self.gardenMailManager fetchGardenMails:maxId onCompleted:onCompleted];
}

- (void)saveUserProfiles:(NSDictionary *)userProfiles onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager saveUserProfiles:userProfiles onCompleted:onCompleted];
}

- (void)fetchUserProfiles:(void (^)(NSError *error, NSDictionary *userProfiles))onCompleted {
    [self.userManager fetchUserProfiles:onCompleted];
}

- (void)activeInviteUser:(NSString *)mobilePhoneNumber verifyCode:(NSString *)verifyCode parentType:(TXPBParentType)parentType password:(NSString *)password onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    [self.userManager activeInviteUser:mobilePhoneNumber verifyCode:verifyCode parentType:parentType password:password onCompleted:onCompleted];
}

- (void)UnbindParent:(int64_t)parentId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager UnbindParent:parentId onCompleted:onCompleted];
}

- (void)sendComment:(NSString *)content commentType:(TXPBCommentType)commentType toUserId:(int64_t)toUserId targetId:(int64_t)targetId targetType:(TXPBTargetType)targetType onCompleted:(void (^)(NSError *error, int64_t commentId))onCompleted {
    [self.commentManager sendComment:content commentType:commentType toUserId:toUserId targetId:targetId targetType:targetType onCompleted:onCompleted];
}

- (void)deleteComment:(int64_t)commentId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.commentManager deleteComment:commentId onCompleted:onCompleted];
}

- (void)fetchCommentsToMe:(int64_t)maxId onCompleted:(void (^)(NSError *error, NSArray *comments, NSArray *txFeeds, BOOL hasMore))onCompleted {
    [self.commentManager fetchCommentsToMe:maxId onCompleted:onCompleted];
}

- (void)fetchCommentsByTargetId:(int64_t)targetId targetType:(TXPBTargetType)targetType maxCommentId:(int64_t)maxCommentId onCompleted:(void (^)(NSError *error, NSArray *comments, BOOL hasMore))onCompleted {
    [self.commentManager fetchCommentsByTargetId:targetId targetType:targetType maxCommentId:maxCommentId onCompleted:onCompleted];
}

- (void)fetchPosts:(int64_t)maxId gardenId:(int64_t)gardenId postType:(TXPBPostType)postType onCompleted:(void (^)(NSError *error, NSArray *posts, BOOL hasMore))onCompleted {
    [self.postManager fetchPosts:maxId gardenId:gardenId postType:postType onCompleted:onCompleted];
}



- (void)fetchFeeds:(int64_t)maxId isInbox:(BOOL)isInbox onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted {
    [self.feedManager fetchFeeds:maxId isInbox:isInbox onCompleted:onCompleted];
}

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count isInbox:(BOOL)isInbox error:(NSError **)outError {
    return [self.feedManager getFeeds:maxFeedId count:count isInbox:isInbox error:outError];
}

- (NSArray *)getFeeds:(int64_t)maxFeedId count:(int64_t)count userId:(int64_t)userId error:(NSError **)outError {
    return [self.feedManager getFeeds:maxFeedId count:count userId:userId error:outError];
}

- (NSArray *)getComments:(int64_t)targetId targetType:(TXPBTargetType)targetType commentType:(TXPBCommentType)commentType maxCommentId:(int64_t)maxCommentId count:(int64_t)count error:(NSError **)outError {
    return [self.commentManager getComments:targetId targetType:targetType commentType:commentType maxCommentId:maxCommentId count:count error:outError];
}

- (void)fetchFeeds:(int64_t)maxId userId:(int64_t)userId onCompleted:(void (^)(NSError *error, NSArray/*<TXFeed>*/ *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore))onCompleted {
    [self.feedManager fetchFeeds:maxId userId:userId onCompleted:onCompleted];
}

- (void)deleteFeed:(int64_t)feedId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.feedManager deleteFeed:feedId onCompleted:onCompleted];
}

- (void)changePassword:(NSString *)oldPassword newPassword:(NSString *)newPassword onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager changePassword:oldPassword newPassword:newPassword onCompleted:onCompleted];
}

- (void)fetchCounters:(void (^)(NSError *error, NSMutableDictionary *countersDictionary))onCompleted {
    [self.counterManager fetchCounters:onCompleted];
}

- (NSDictionary *)getCountersDictionary {
    return self.counterManager.countersDictionary;
}

- (void)setCountersDictionaryValue:(int)value forKey:(NSString *)key {
    [self.counterManager setCountersDictionaryValue:value forKey:key];
}

- (TXPost *)getLastPost:(TXPBPostType)postType error:(NSError **)outError {
    return [self.postManager getLastPost:postType error:outError];
}

- (NSArray *)getPosts:(TXPBPostType)postType maxPostId:(int64_t)maxPostId count:(int64_t)count error:(NSError **)outError {
    return [self.postManager getPosts:postType maxPostId:maxPostId count:count error:outError];
}

- (void)setUserProfileValue:(int64_t)value forKey:(NSString *)key {
    [self.userManager setUserProfileValue:value forKey:key];
}

- (NSArray *)getGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    return [self.gardenMailManager getGardenMails:maxId count:count error:outError];
}

- (NSArray *)getFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError {
    return [self.feedMedicineTaskManager getFeedMedicineTasks:maxId count:count error:outError];
}

- (void)mute:(int64_t)departmentId childUserIds:(NSArray *)childUserIds
    muteType:(TXPBMuteType)muteType
 onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager mute:departmentId childUserIds:childUserIds muteType:muteType onCompleted:onCompleted];
}

- (void)unMute:(int64_t)departmentId childUserId:(int64_t)childUserId
      muteType:(TXPBMuteType)muteType
   onCompleted:(void (^)(NSError *error))onCompleted {
    [self.userManager unMute:departmentId childUserId:childUserId muteType:muteType onCompleted:onCompleted];
}

- (void)fetchMutedUserIds:(int64_t)departmentId
                 muteType:(TXPBMuteType)muteType
        onCompleted:(void (^)(NSError *error, NSArray *childUserIds, TXPBMuteType txpbMuteType))onCompleted {
    [self.userManager fetchMutedUserIds:departmentId muteType:muteType onCompleted:onCompleted];
}

- (void)markGardenMailAsRead:(int64_t)gardenMailId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.gardenMailManager markGardenMailAsRead:gardenMailId onCompleted:onCompleted];
}

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.feedMedicineTaskManager markFeedMedicineTaskAsRead:feedMedicineTaskId onCompleted:onCompleted];
}

- (void)log:(NSString *)content onCompleted:(void (^)(NSError *error))onCompleted {
    [self.applicationManager log:content onCompleted:onCompleted];
}

- (void)updateDeviceToken:(NSString *)deviceToken
             platformType:(TXPBPlatformType)platformType
                osVersion:(NSString *)osVersion mobileVersion:(NSString *)mobileVersion
                 deviceId:(NSString *)deviceId
              onCompleted:(void (^)(NSError *error))onCompleted {
    [self.applicationManager updateDeviceToken:deviceToken platformType:platformType
                                     osVersion:osVersion mobileVersion:mobileVersion deviceId:deviceId onCompleted:onCompleted];
}

- (void)upgrade:(TXPBPlatformType)txpbPlatformType onCompleted:(void (^)(NSError *error, TXPBUpgradeResponse *txpbUpgradeResponse))onCompleted {
    [self.applicationManager upgrade:txpbPlatformType onCompleted:onCompleted];
}

- (void)clearCheckIn:(int64_t)maxId onCompleted:(void (^)(NSError *error))onCompleted {
    [self.checkInManager clearCheckIn:maxId onCompleted:onCompleted];
}

- (void)clearNotice:(int64_t)maxId isInbox:(BOOL)isInbox onCompleted:(void (^)(NSError *error))onCompleted {
    [self.noticeManager clearNotice:maxId isInbox:isInbox onCompleted:onCompleted];
}

@end