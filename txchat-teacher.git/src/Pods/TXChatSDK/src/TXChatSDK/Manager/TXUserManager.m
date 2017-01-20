//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXUserManager.h"
#import "TXChatDef.h"
#import "TXApplicationManager.h"

@interface TXUserManager ()

@property (nonatomic,copy) NSString *userToken;

@end


@implementation TXUserManager {
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onCurrentUserChanged)
                                                     name:TX_NOTIFICATION_CURRENT_USER_CHANGED
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToken) name:KUpdateToken object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TX_NOTIFICATION_CURRENT_USER_CHANGED
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KUpdateToken object:nil];
}

- (void)onCurrentUserChanged {
    if ([[TXApplicationManager sharedInstance] currentUser]) {
        [self userCheckInWithCompleted:^(NSError *error, int64_t points) {

        }];
    }
}

- (NSArray/*<TXUser>*/ *)queryDepartmentMembers:(int64_t)departmentId
                                       userType:(TXPBUserType)userType
                                          error:(NSError **)outError {
    DDLogInfo(@"%s departmentId=%lld userType=%d", __FUNCTION__, departmentId, (int) userType);

    if (![TXApplicationManager sharedInstance].currentUser) {
        NSError *error = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        if (outError) {
            *outError = error;
        }
        TX_POST_NOTIFICATION_IF_ERROR(error);
        return nil;
    }
    return [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryUsersByDepartmentId:departmentId userType:userType error:outError];
}

- (NSArray/*<Department>*/ *)getAllDepartments:(NSError **)outError {
    DDLogInfo(@"%s", __FUNCTION__);

    if (![TXApplicationManager sharedInstance].currentUser) {
        NSError *error = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        if (outError) {
            *outError = error;
        }
        TX_POST_NOTIFICATION_IF_ERROR(error);
        return nil;
    }

    return [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao queryAllDepartment:outError];
}

- (void)bindChild:(int64_t)childUserId parentType:(TXPBParentType)txpbParentType birthday:(int64_t)birthday guarder:(NSString *)guarder
      onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBBindChildRequestBuilder *requestBuilder = [TXPBBindChildRequest builder];
    requestBuilder.childUserId = childUserId;
    requestBuilder.parentType = txpbParentType;
    requestBuilder.birthday = birthday;
    requestBuilder.guarder = guarder;

    [[TXHttpClient sharedInstance] sendRequest:@"/bind_child"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBBindChildResponse *txpbBindChildResponse;
                                       TXUser *parent;
                                       TXUser *child;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBBindChildResponse, txpbBindChildResponse);

                                       parent = [[[TXUser alloc] init] loadValueFromPbObject:txpbBindChildResponse.parent];
                                       [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:parent error:&innerError];

                                       child = [[[TXUser alloc] init] loadValueFromPbObject:txpbBindChildResponse.child];
                                       [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:child error:&innerError];

                                       if (parent.userId == [TXApplicationManager sharedInstance].currentUser.userId ||
                                               child.userId == [TXApplicationManager sharedInstance].currentUser.userId) {
                                           [[TXApplicationManager sharedInstance] tryReloadAppContextFromFile];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)updateBindInfo:(int64_t)parentId parentType:(TXPBParentType)txpbParentType onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBUpdateBindRequestBuilder *requestBuilder = [TXPBUpdateBindRequest builder];
    requestBuilder.parentId = parentId;
    requestBuilder.parentType = txpbParentType;

    [[TXHttpClient sharedInstance] sendRequest:@"/update_bind"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBUpdateBindResponse *updateBindResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBUpdateBindResponse, updateBindResponse);

                                       [TXApplicationManager sharedInstance].currentUser.parentType = txpbParentType;
                                       [TXApplicationManager sharedInstance].currentUser.nickname = updateBindResponse.user.nickname;

                                       [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:[TXApplicationManager sharedInstance].currentUser
                                                                                                             error:&innerError];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (void)sendVerifyCodeBySMS:(NSString *)mobilePhoneNumber type:(TXPBSendSmsCodeType)type
                    isVoice:(BOOL)isVoice
                onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBSendSmsCodeRequestBuilder *requestBuilder = [TXPBSendSmsCodeRequest builder];
    requestBuilder.mobile = mobilePhoneNumber;
    requestBuilder.sendSmsCodeType = type;
    requestBuilder.isVoice = isVoice;

    self.userToken = [[TXApplicationManager sharedInstance].currentUserProfiles valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN]
            ? [TXApplicationManager sharedInstance].currentUserProfiles[TX_PROFILE_KEY_CURRENT_TOKEN]
            : @"";

    [[TXHttpClient sharedInstance] sendRequest:@"/send_sms_code"
                                         token:self.userToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
              onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    DDLogInfo(@"%s username=%@ password=%@", __FUNCTION__, username, password);

    TXPBLoginRequestBuilder *requestBuilder = [TXPBLoginRequest builder];
    requestBuilder.username = username;
    requestBuilder.password = password;

    [[TXHttpClient sharedInstance] sendRequest:@"/login"
                                         token:@""
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXUser *txUser;
                                       TXPBLoginResponse *txpbLoginResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBLoginResponse, txpbLoginResponse)

                                       txUser = [[[TXUser alloc] init] loadValueFromPbObject:txpbLoginResponse.user];
                                       txUser.isInit = txpbLoginResponse.isInit;

                                       [[TXApplicationManager sharedInstance] replaceCurrentUserWithNewUser:txUser
                                                                                                      token:txpbLoginResponse.token
                                                                                               userProfiles:txpbLoginResponse.userProfiles
                                                                                                   outError:&innerError];
                                       if (innerError) {
                                           goto completed;
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(onCompleted(innerError, txUser))
                                       }
                                   }];
}

- (void)logout:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    [[TXHttpClient sharedInstance] sendRequest:@"/logout"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:nil
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)fetchUserProfiles:(void (^)(NSError *error, NSDictionary *userProfiles))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBFetchUserProfileRequestBuilder *requestBuilder = [TXPBFetchUserProfileRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_user_profile"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchUserProfileResponse *fetchUserProfileResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchUserProfileResponse, fetchUserProfileResponse);

                                       for (TXPBUserProfile *txpbUserProfile in fetchUserProfileResponse.userProfiles) {
                                           [[TXApplicationManager sharedInstance].currentUserProfiles setValue:txpbUserProfile.value
                                                                                                        forKey:txpbUserProfile.option];
                                       }

                                       [[TXApplicationManager sharedInstance] flushAppContextToFile];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, [TXApplicationManager sharedInstance].currentUserProfiles);
                                           );
                                       }
                                   }];
}

- (void)activeUser:(NSString *)mobilePhoneNumber
        verifyCode:(NSString *)verifyCode
          password:(NSString *)password
       onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    TXPBActiveUserRequestBuilder *requestBuilder = [TXPBActiveUserRequest builder];
    requestBuilder.mobile = mobilePhoneNumber;
    requestBuilder.code = verifyCode;
    requestBuilder.password = password;

    [[TXHttpClient sharedInstance] sendRequest:@"/active_user"
                                         token:@""
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBActiveUserResponse *activeUserResponse;
                                       TXUser *txUser;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBActiveUserResponse, activeUserResponse)

                                       txUser = [[[TXUser alloc] init] loadValueFromPbObject:activeUserResponse.user];

                                       [[TXApplicationManager sharedInstance] replaceCurrentUserWithNewUser:txUser
                                                                                                      token:activeUserResponse.token
                                                                                               userProfiles:activeUserResponse.userProfiles
                                                                                                   outError:&innerError];
                                       if (innerError) {
                                           goto completed;
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, txUser);
                                           );
                                       };
                                   }];
}

- (void)changeMobilePhoneNumber:(NSString *)newMobilePhoneNumber
                     verifyCode:(NSString *)verifyCode
                    onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBUpdateMobileRequestBuilder *requestBuilder = [TXPBUpdateMobileRequest builder];
    requestBuilder.mobile = newMobilePhoneNumber;
    requestBuilder.code = verifyCode;

    [[TXHttpClient sharedInstance] sendRequest:@"/update_mobile"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       //对服务端更新手机号的同时,需要将本地内存,数据库中的当前用户的手机号码也同时进行更新
                                       if (!error) {
                                           [TXApplicationManager sharedInstance].currentUser.mobilePhoneNumber = newMobilePhoneNumber;
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:[TXApplicationManager sharedInstance].currentUser error:nil];
                                       }

                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)changePassword:(NSString *)newPassword
     mobilePhoneNumber:(NSString *)mobilePhoneNumber
            verifyCode:(NSString *)verifyCode
           onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBSetPasswordRequestBuilder *requestBuilder = [TXPBSetPasswordRequest builder];
    requestBuilder.password = newPassword;
    requestBuilder.code = verifyCode;
    requestBuilder.mobile = mobilePhoneNumber;

    [[TXHttpClient sharedInstance] sendRequest:@"/set_password"
                                         token:@""
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)updateUserInfo:(TXUser *)txUser
           onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBUpdateUserInfoRequestBuilder *requestBuilder = [TXPBUpdateUserInfoRequest builder];
    TXPBUserBuilder *txpbUserBuilder = [TXPBUser builder];
    txpbUserBuilder.userId = txUser.userId;
    txpbUserBuilder.realname = txUser.realName;
    txpbUserBuilder.sexType = txUser.sex;
    txpbUserBuilder.birthday = txUser.birthday;
    txpbUserBuilder.userType = txUser.userType;
    txpbUserBuilder.sign = txUser.sign;
    txpbUserBuilder.avatar = txUser.avatarUrl;
    txpbUserBuilder.guarder = txUser.guarder;
    txpbUserBuilder.nickname = txUser.nickname;
    requestBuilder.user = [txpbUserBuilder build];

    [[TXHttpClient sharedInstance] sendRequest:@"/update_user_info"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           //更新本地数据库中当前用户信息
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:txUser error:nil];

                                           //reload一次context,将导致内存中的currentUser信息全部刷新成最新状态
                                           if ([TXApplicationManager sharedInstance].currentUser.userId == txUser.userId) {
                                               [[TXApplicationManager sharedInstance] tryReloadAppContextFromFile];
                                           }
                                       }

                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)fetchDepartments:(void (^)(NSError *error, NSArray *txDepartments))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBFetchContactsRequestBuilder *requestBuilder = [TXPBFetchContactsRequest builder];
    requestBuilder.lastModifiedSince = [[[TXApplicationManager sharedInstance].currentUserProfiles valueForKey:TX_LAST_FETCHED_ON_DEPARTMENT] longLongValue];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_contacts"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchContactsResponse *innerResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchContactsResponse, innerResponse);

                                       for (TXPBDepartment *txpbDepartment in innerResponse.departments) {
                                           switch (txpbDepartment.actionType) {
                                               case TXPBActionTypeDelete: {
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao deleteDepartmentByDepartmentId:txpbDepartment.id error:&innerError];
                                                   break;
                                               }
                                               default: {
                                                   TXDepartment *txDepartment = [[[TXDepartment alloc] init] loadValueFromPbObject:txpbDepartment];

                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao addDepartment:txDepartment error:&innerError];
                                                   if (innerError) {
                                                       goto completed;
                                                   }

                                                   break;
                                               }
                                           }
                                       }

                                       [TXApplicationManager sharedInstance].currentUserProfiles[TX_LAST_FETCHED_ON_DEPARTMENT] = @(innerResponse.fetchTime);
                                       [[TXApplicationManager sharedInstance] flushAppContextToFile];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError, innerResponse.departments);
                                           );
                                       }
                                   }];
}

- (void)fetchDepartmentsIfNone:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    NSArray *txDepartments = [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao queryAllDepartment:nil];
    if (!txDepartments || txDepartments.count == 0) {
        [self fetchDepartments:^(NSError *error, NSArray *txDepartments) {
            onCompleted(error);
        }];
    }
    TX_RUN_ON_MAIN(
            onCompleted(nil);
    );
}


- (void)fetchDepartmentMembers:(int64_t)departmentId
                clearLocalData:(BOOL)clearLocalData
                   onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s departmentId=%lld clearLocalData=%d", __FUNCTION__, departmentId, clearLocalData);

    TXPBFetchDepartmentMembersRequestBuilder *requestBuilder = [TXPBFetchDepartmentMembersRequest builder];
    requestBuilder.departmentId = departmentId;

    NSString *lastFetchedOnKey = [NSString stringWithFormat:@"%@.%lld", TX_LAST_FETCHED_ON_DEPARTMENT_MEMBER, departmentId];

    if (clearLocalData) {
        requestBuilder.lastFetchTime = 0;
    }
    else {
        id lastFetchedOnValue = [[TXApplicationManager sharedInstance].currentUserProfiles valueForKey:lastFetchedOnKey];
        requestBuilder.lastFetchTime = [lastFetchedOnValue longLongValue];
    }

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_department_members"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchDepartmentMembersResponse *innerResponse;
                                       NSMutableArray *userIds = [[NSMutableArray alloc] init];

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchDepartmentMembersResponse, innerResponse);

                                       if (clearLocalData) {
                                           [TXApplicationManager sharedInstance].currentUserProfiles[lastFetchedOnKey] = @(0);
                                           [[TXApplicationManager sharedInstance] flushAppContextToFile];
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao deleteDepartmentMembersByDepartmentId:departmentId error:nil];
                                       }

                                       for (TXPBUser *txpbUser in innerResponse.members) {
                                           switch (txpbUser.actionType) {
                                               case TXPBActionTypeAddOrUpdate:
                                               case TXPBActionTypeUpdate:
                                               case TXPBActionTypeAdd: {
                                                   TXUser *txUser = [[[TXUser alloc] init] loadValueFromPbObject:txpbUser];
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:txUser error:nil];
                                                   [userIds addObject:@(txUser.userId)];
                                                   break;
                                               }
                                               case TXPBActionTypeDelete: {
                                                   [[TXApplicationManager sharedInstance].currentUserDbManager.userDao
                                                           deleteDepartmentUserWithUserId:txpbUser.userId departmentId:departmentId];
                                               };
                                           }
                                       }

                                       [[TXApplicationManager sharedInstance].currentUserDbManager.userDao putUsers:userIds
                                                                                                       toDepartment:departmentId
                                                                                                              error:&innerError];
                                       if (innerError) {
                                           goto completed;
                                       }

                                       [TXApplicationManager sharedInstance].currentUserProfiles[lastFetchedOnKey] = @(innerResponse.lastFetchTime);
                                       [[TXApplicationManager sharedInstance] flushAppContextToFile];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(innerError);
                                           );
                                       }
                                   }];
}

- (void)fetchChild:(void (^)(NSError *error, TXUser *childUser))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBFetchChildRequestBuilder *requestBuilder = [TXPBFetchChildRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_child"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchChildResponse *innerResponse;
                                       TXUser *txUser;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchChildResponse, innerResponse);

                                       txUser = [[[TXUser alloc] init] loadValueFromPbObject:innerResponse.children];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txUser);
                                           });
                                       }
                                   }];
}

- (void)fetchUserByUserId:(int64_t)userId
              onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    DDLogInfo(@"%s userId=%lld", __FUNCTION__, userId);

    TXPBFetchUserinfoRequestBuilder *requestBuilder = [TXPBFetchUserinfoRequest builder];
    requestBuilder.uid = userId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_userinfo"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchUserinfoResponse *fetchUserInfoResponse;
                                       TXUser *txUser;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchUserinfoResponse, fetchUserInfoResponse);

                                       txUser = [[[TXUser alloc] init] loadValueFromPbObject:fetchUserInfoResponse.user];

                                       [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:txUser error:&innerError];
                                       if (innerError) {
                                           goto completed;
                                       }

                                       if ([TXApplicationManager sharedInstance].currentUser.userId == txUser.userId) {
                                           [[TXApplicationManager sharedInstance] tryReloadAppContextFromFile];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txUser);
                                           });
                                       }
                                   }];
}

- (TXUser *)queryUserByUserId:(int64_t)userId
                        error:(NSError **)outError {
    DDLogInfo(@"%s userId=%lld", __FUNCTION__, userId);

    if (![TXApplicationManager sharedInstance].currentUser) {
        if (outError) {
            *outError = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        }
        return nil;
    }
    return [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryUserByUserId:userId error:outError];
}

- (NSArray *)queryParentUsersByChildUserId:(int64_t)childUserId
                                     error:(NSError **)outError {
    DDLogInfo(@"%s childUserId=%lld", __FUNCTION__, childUserId);

    return [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryParentUsersByChildUserId:childUserId error:outError];
}

- (TXUser *)queryUserByUsername:(NSString *)username
                          error:(NSError **)outError {
    DDLogInfo(@"%s username=%@", __FUNCTION__, username);

    if (![TXApplicationManager sharedInstance].currentUser) {
        if (outError) {
            *outError = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        }
        return nil;
    }
    return [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryUserByUsername:username error:outError];
}

- (void)fetchDepartmentByDepartmentId:(int64_t)departmentId
                          onCompleted:(void (^)(NSError *error))onCompleted {
    //TODO:FIX ME
}

- (TXDepartment *)getDepartmentByDepartmentId:(int64_t)departmentId
                                        error:(NSError **)outError {
    if (![TXApplicationManager sharedInstance].currentUser) {
        if (outError) {
            *outError = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        }
        return nil;
    }
    return [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao queryDepartmentByDepartmentId:departmentId error:outError];
}

- (void)fetchDepartmentByGroupId:(NSString *)groupId
                     onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s groupId=%@", __FUNCTION__, groupId);

    TXPBFetchDepartmentByGroupIdRequestBuilder *requestBuilder = [TXPBFetchDepartmentByGroupIdRequest builder];
    requestBuilder.groupId = groupId;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_department_by_groupId"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchDepartmentByGroupIdResponse *fetchDepartmentByGroupIdResponse;
                                       TXDepartment *txDepartment;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchDepartmentByGroupIdResponse, fetchDepartmentByGroupIdResponse);

                                       txDepartment = [[[TXDepartment alloc] init] loadValueFromPbObject:fetchDepartmentByGroupIdResponse.department];

                                       [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao addDepartment:txDepartment error:&innerError];
                                       if (innerError) {
                                           goto completed;
                                       }

                                       completed:
                                       {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError);
                                           });
                                       }
                                   }];
}

- (TXDepartment *)getDepartmentByGroupId:(NSString *)groupId
                                   error:(NSError **)outError {
    DDLogInfo(@"%s groupId=%@", __FUNCTION__, groupId);

    if (![TXApplicationManager sharedInstance].currentUser) {
        if (outError) {
            *outError = TX_ERROR_MAKE(TX_STATUS_LOCAL_USER_EXPIRED, TX_STATUS_LOCAL_USER_EXPIRED_DESC);
        }
        return nil;
    }

    return [[TXApplicationManager sharedInstance].currentUserDbManager.departmentDao queryDepartmentByGroupId:groupId error:outError];
}

- (void)activeInviteUser:(NSString *)mobilePhoneNumber
              verifyCode:(NSString *)verifyCode
              parentType:(TXPBParentType)parentType
                password:(NSString *)password
             onCompleted:(void (^)(NSError *error, TXUser *txUser))onCompleted {
    TXPBActiveInviteUserRequestBuilder *requestBuilder = [TXPBActiveInviteUserRequest builder];
    requestBuilder.mobile = mobilePhoneNumber;
    requestBuilder.code = verifyCode;
    requestBuilder.parentType = parentType;
    requestBuilder.password = password;

    [[TXHttpClient sharedInstance] sendRequest:@"/active_invite_user"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBActiveInviteUserResponse *activeInviteUserResponse;
                                       TXUser *txUser;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBActiveInviteUserResponse, activeInviteUserResponse);

                                       txUser = [[[TXUser alloc] init] loadValueFromPbObject:activeInviteUserResponse.user];

                                       [[TXApplicationManager sharedInstance].currentUserDbManager.userDao addUser:txUser error:nil];

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, txUser);
                                           });
                                       }
                                   }];
}

- (void)UnbindParent:(int64_t)parentId
         onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBRelieveBindRequestBuilder *requestBuilder = [TXPBRelieveBindRequest builder];
    requestBuilder.parentId = parentId;

    [[TXHttpClient sharedInstance] sendRequest:@"/relieve_bind"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)changePassword:(NSString *)oldPassword
           newPassword:(NSString *)newPassword
           onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBUpdatePasswordRequestBuilder *requestBuilder = [TXPBUpdatePasswordRequest builder];
    requestBuilder.oldPassword = oldPassword;
    requestBuilder.newPassword = newPassword;

    [[TXHttpClient sharedInstance] sendRequest:@"/update_password"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)fetchBoundParents:(void (^)(NSError *error, NSArray/*<BindingParentInfo>*/ *bindingParentInfos))onCompleted {
    TXPBGetBindingParentListRequestBuilder *requestBuilder = [TXPBGetBindingParentListRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/get_binding_parent_list"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBGetBindingParentListResponse *getBindingParentListResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBGetBindingParentListResponse, getBindingParentListResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, getBindingParentListResponse.bindParents);
                                           });
                                       }
                                   }];
}


- (void)setUserProfileValue:(int64_t)value forKey:(NSString *)key {
    DDLogInfo(@"%s value=%lld key=%@", __FUNCTION__, value, key);

    dispatch_async(dispatch_get_main_queue(), ^{
        [TXApplicationManager sharedInstance].currentUserProfiles[key] = @(value);
        [[TXApplicationManager sharedInstance] flushAppContextToFile];
    });
}


- (void)mute:(int64_t)departmentId
childUserIds:(NSArray *)childUserIds
    muteType:(TXPBMuteType)muteType
 onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s departmentId=%lld childUserIds=%@ muteType=%d", __FUNCTION__, departmentId, childUserIds, (int) muteType);

    TXPBMuteRequestBuilder *requestBuilder = [TXPBMuteRequest builder];
    [requestBuilder setDepartmentId:departmentId];
    [requestBuilder setChildUserIdsArray:childUserIds];
    requestBuilder.type = muteType;
    requestBuilder.cover = TRUE;

    [[TXHttpClient sharedInstance] sendRequest:@"/mute"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       onCompleted(error);
                                   }];
}

- (void)unMute:(int64_t)departmentId childUserId:(int64_t)childUserId
      muteType:(TXPBMuteType)muteType
   onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBUnMuteRequestBuilder *requestBuilder = [TXPBUnMuteRequest builder];
    requestBuilder.departmentId = departmentId;
    requestBuilder.childUserIds = childUserId;
    requestBuilder.type = muteType;

    [[TXHttpClient sharedInstance] sendRequest:@"/unmute"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       onCompleted(error);
                                   }];
}

- (void)fetchMutedUserIds:(int64_t)departmentId
                 muteType:(TXPBMuteType)muteType
              onCompleted:(void (^)(NSError *error, NSArray *childUserIds, TXPBMuteType txpbMuteType))onCompleted {
    TXPBFetchMuteRequestBuilder *requestBuilder = [TXPBFetchMuteRequest builder];
    requestBuilder.departmentId = departmentId;
    requestBuilder.type = muteType;

    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_mute"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBFetchMuteResponse *txpbFetchMuteResponse;
                                       NSMutableArray *childUserIds;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBFetchMuteResponse, txpbFetchMuteResponse);

                                       childUserIds = [NSMutableArray array];
                                       for (uint i = 0; i < txpbFetchMuteResponse.childUserIds.count; i++) {
                                           [childUserIds addObject:@([txpbFetchMuteResponse.childUserIds int64AtIndex:i])];
                                       }

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, childUserIds, muteType);
                                           });
                                       };
                                   }];
}

- (id)getValueFromProfileForKey:(NSString *)key defaultValue:(id)defaultValue {
    id value = [[TXApplicationManager sharedInstance].currentUserProfiles valueForKey:key];
    return value ? value : defaultValue;
}

- (void)saveUserProfiles:(NSDictionary *)userProfiles
             onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s userProfiles=%@", __FUNCTION__, userProfiles);

    TXPBSaveUserProfileRequestBuilder *requestBuilder = [TXPBSaveUserProfileRequest builder];
    for (uint i = 0; i < userProfiles.allKeys.count; ++i) {
        NSString *key = userProfiles.allKeys[i];
        NSString *value = userProfiles[key];

        TXPBUserProfileBuilder *userProfileBuilder = [TXPBUserProfile builder];
        userProfileBuilder.option = key;
        userProfileBuilder.value = value;

        [requestBuilder addUserProfiles:[userProfileBuilder build]];

        [TXApplicationManager sharedInstance].currentUserProfiles[key] = value;
    }

    [[TXHttpClient sharedInstance] sendRequest:@"/save_user_profile"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       if (!error) {
                                           [[TXApplicationManager sharedInstance] flushAppContextToFile];
                                       }

                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (void)userCheckInWithCompleted:(void (^)(NSError *error, int64_t points))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);

    TXPBUserCheckInRequestBuilder *requestBuilder = [TXPBUserCheckInRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/user_check_in"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBUserCheckInResponse *txpbUserCheckInResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBUserCheckInResponse, txpbUserCheckInResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (txpbUserCheckInResponse.bonus > 0) {
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_WEI_DOU_AWARDED_BY_CHECK_IN
                                                                                                       object:@(txpbUserCheckInResponse.bonus)];
                                               }

                                               onCompleted(innerError, txpbUserCheckInResponse.bonus);
                                           });
                                       };
                                   }];
}

- (void)inviteUser:(int64_t)userId onCompleted:(void (^)(NSError *error))onCompleted {
    TXPBTeacherInvitationParentRequestBuilder *requestBuilder = [TXPBTeacherInvitationParentRequest builder];
    requestBuilder.parentId = userId;

    [[TXHttpClient sharedInstance] sendRequest:@"/teacher_invitation_parent"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           onCompleted(error);
                                       });
                                   }];
}

- (NSString *)querySettingValueWithKey:(NSString *)key error:(NSError *)outError {
    return [[TXApplicationManager sharedInstance].currentUserDbManager.settingDao querySettingValueByKey:key];
}

- (BOOL)querySettingBoolValueWithKey:(NSString *)key error:(NSError *)outError {
    NSString *value = [self querySettingValueWithKey:key error:outError];
    if (!value) {
        return FALSE;
    }
    return (BOOL) value.intValue;
}

- (void)saveSettingValue:(NSString *)value forKey:(NSString *)key error:(NSError **)outError {
    [[TXApplicationManager sharedInstance].currentUserDbManager.settingDao saveSettingValue:value forKey:key error:outError];
}

- (void)updateToken
{
    self.userToken = [[TXApplicationManager sharedInstance].currentUserProfiles valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN]
    ? [TXApplicationManager sharedInstance].currentUserProfiles[TX_PROFILE_KEY_CURRENT_TOKEN]
    : @"";
}


@end