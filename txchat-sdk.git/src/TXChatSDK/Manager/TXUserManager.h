//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXPBChat.pb.h"
#import "TXUser.h"

@class TXApplicationManager;

@interface TXUserManager : NSObject

/**
* 用户登录
*/
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
              onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted;

/**
* 用户注销
*/
- (void)logout:(void (^)(NSError *error))onCompleted;

/**
* 修改密码
*/
- (void)changePassword:(NSString *)oldPassword
           newPassword:(NSString *)newPassword
           onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 获取已被绑定的家长
*/
- (void)fetchBoundParents:(void (^)(NSError *error, NSArray/*<BindingParentInfo>*/ *bindingParentInfos))onCompleted;

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


/**
* 从服务端同步一次部门信息，在同步完成后，会将部门信息插入数据库，然后回调onCompleted，客户端在收到回掉后，假如没有出错，
* 需要重新从数据库中读取一遍部门信息，出错则根据错误信息，做相应的错误提示。
*/
- (void)fetchDepartments:(void (^)(NSError *error, NSArray *txDepartments))onCompleted;

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
- (NSArray/*<TXUser>*/ *)queryDepartmentMembers:(int64_t)departmentId
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
- (TXUser *)queryUserByUserId:(int64_t)userId
                        error:(NSError **)outError;

/**
* 根据宝宝ID找到家长
*/
- (NSArray *)queryParentUsersByChildUserId:(int64_t)childUserId
                                     error:(NSError **)outError;

/**
* 从数据中根据用户名获取用户信息
*/
- (TXUser *)queryUserByUsername:(NSString *)username
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

- (void)setUserProfileValue:(int64_t)value forKey:(NSString *)key;

- (void)userCheckInWithCompleted:(void (^)(NSError *error, int64_t points))onCompleted;

- (void)inviteUser:(int64_t)userId
       onCompleted:(void (^)(NSError *error))onCompleted;

- (NSString *)querySettingValueWithKey:(NSString *)key error:(NSError *)outError;

- (BOOL)querySettingBoolValueWithKey:(NSString *)key error:(NSError *)outError;

- (void)saveSettingValue:(NSString *)value forKey:(NSString *)key error:(NSError **)outError;
@end