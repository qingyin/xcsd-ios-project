//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXUser.h"
#import "TXChatManagerBase.h"
#import "PSPDFThreadSafeMutableDictionary.h"

@interface TXApplicationManager : TXChatManagerBase

/**
* 当前登录的用户
*/
@property(strong, readonly) TXUser *currentUser;

/**
* 当前登录用户的个性化配置信息
*/
@property(strong, readonly) PSPDFThreadSafeMutableDictionary *currentUserProfiles;

/**
* 当前登录用户的个人数据库
*/
@property(strong, readonly) TXUserDbManager *currentUserDbManager;

/**
* 当前登录用户的token
*/
@property(strong, readonly) NSString *currentToken;

/**
 * 日志目录
 */
@property(strong, readonly) NSString *logDirectoryPath;

+ (instancetype)sharedInstance;

/**
* 删除本地缓存
*/
- (void)deleteLocalCache;

/**
* 更新本机到deviceToken到服务端
*/
- (void)updateDeviceToken:(NSString *)deviceToken
             platformType:(TXPBPlatformType)platformType
                osVersion:(NSString *)osVersion
            mobileVersion:(NSString *)mobileVersion
                 deviceId:(NSString *)deviceId
              onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 在服务端记录一条日志
*/
- (void)log:(NSString *)content onCompleted:(void (^)(NSError *error))onCompleted;

- (void)upgrade:(TXPBPlatformType)txpbPlatformType onCompleted:(void (^)(NSError *error, TXPBUpgradeResponse *txpbUpgradeResponse))onCompleted;

- (void)cleanCurrentContext;

- (void)flushAppContextToFile;

- (void)tryReloadAppContextFromFile;

- (void)replaceCurrentUserWithNewUser:(TXUser *)txUser
                                token:(NSString *)token
                         userProfiles:(NSArray *)userProfiles
                             outError:(NSError **)error;
@end