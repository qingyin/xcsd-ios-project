//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXApplicationManager.h"

@implementation TXApplicationManager {
    /**
    * 工作目录,/Documents
    */
    NSString *_workingDirectoryPath;

    /**
    * 用于持久化appContext的文件路径
    */
    NSString *_appContextFilePath;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (TXApplicationManager *)init {
    if (self = [super init]) {
        _workingDirectoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE)[0];
        _appContextFilePath = [_workingDirectoryPath stringByAppendingPathComponent:TX_APP_CONTEXT_FILE_NAME];
        _currentUserProfiles = [PSPDFThreadSafeMutableDictionary dictionary];
        _logDirectoryPath = [_workingDirectoryPath stringByAppendingPathComponent:@"sdkLogs"];

        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc] initWithLogsDirectory:_logDirectoryPath]];
        [DDLog addLogger:fileLogger];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onError:)
                                                     name:TX_NOTIFICATION_ERROR
                                                   object:nil];

        [self tryReloadAppContextFromFile];
    }
    return self;
}

- (void)onError:(NSNotification *)notification {
    if (notification && notification.object) {
        NSInteger errorCode = ((NSError *) notification.object).code;
        if (errorCode == TX_STATUS_LOCAL_USER_EXPIRED ||
                errorCode == TX_STATUS_UNAUTHORIZED ||
                errorCode == TX_STATUS_KICK_OFF) {
            [self cleanCurrentContext];
        }
    }
}

- (void)tryReloadAppContextFromFile {
    NSError *error;

    if (![[[NSFileManager alloc] init] fileExistsAtPath:_appContextFilePath]) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithContentsOfFile:_appContextFilePath];
    if (!dictionary) {
        return;
    }

    NSString *currentUsername = dictionary[TX_PROFILE_KEY_CURRENT_USERNAME];
    if (!currentUsername) {
        return;
    }

    NSString *currentToken = dictionary[TX_PROFILE_KEY_CURRENT_TOKEN];
    if (!currentToken) {
        return;
    }

    _currentUserDbManager = [[TXUserDbManager alloc] initWithUsername:currentUsername error:&error];
    TX_POST_NOTIFICATION_IF_ERROR(error);

    _currentToken = currentToken;
    _currentUserProfiles = [PSPDFThreadSafeMutableDictionary dictionaryWithDictionary:dictionary];

    [self setCurrentUser:[_currentUserDbManager.userDao queryUserByUsername:currentUsername error:&error]];
}

- (void)replaceCurrentUserWithNewUser:(TXUser *)txUser
                                token:(NSString *)token
                         userProfiles:(NSArray *)userProfiles
                             outError:(NSError **)error {
    NSError *innerError;

    //为该用户初始化数据库管理器
    _currentUserDbManager = [[TXUserDbManager alloc] initWithUsername:txUser.username error:&innerError];
    if (innerError) {
        *error = innerError;
        return;
    }

    //保存当前用户信息到数据库
    [_currentUserDbManager.userDao addUser:txUser error:&innerError];
    if (innerError) {
        *error = innerError;
        return;
    }

    //profiles
    for (TXPBUserProfile *txpbUserProfile in userProfiles) {
        _currentUserProfiles[txpbUserProfile.option] = txpbUserProfile.value;
    }

    _currentToken = token;

    [self setCurrentUser:txUser];

    [self flushAppContextToFile];
}

- (void)setCurrentUser:(TXUser *)user {
    _currentUser = user;
    [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_CURRENT_USER_CHANGED object:nil];
}

- (void)flushAppContextToFile {
    DDLogInfo(@"%s currentUser is null? %s", __FUNCTION__, _currentUser ? "NO" : "YES");
    if (_currentUser) {
        TX_RUN_ON_MAIN(
                if (_currentUserProfiles && _currentUser && _currentUser.username && _currentToken) {
                    _currentUserProfiles[TX_PROFILE_KEY_CURRENT_USERNAME] = _currentUser.username;
                    _currentUserProfiles[TX_PROFILE_KEY_CURRENT_TOKEN] = _currentToken;
                    [[_currentUserProfiles copy] writeToFile:_appContextFilePath atomically:TRUE];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KUpdateToken object:nil];
                }
        );
    }
}

- (void)cleanCurrentContext {
    DDLogInfo(@"%s", __FUNCTION__);

    [[NSFileManager defaultManager] removeItemAtPath:_appContextFilePath error:nil];
    [self setCurrentUser:nil];
    _currentUserProfiles = [PSPDFThreadSafeMutableDictionary dictionary];
}

- (void)log:(NSString *)content onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s content=%@", __FUNCTION__, content);

    TXPBCollectLogRequestBuilder *requestBuilder = [TXPBCollectLogRequest builder];
    requestBuilder.content = content;

    [[TXHttpClient sharedInstance] sendRequest:@"/collect_log"
                                         token:_currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       TX_RUN_ON_MAIN(
                                               onCompleted(error);
                                       )
                                   }];
}

- (void)updateDeviceToken:(NSString *)deviceToken
             platformType:(TXPBPlatformType)platformType
                osVersion:(NSString *)osVersion
            mobileVersion:(NSString *)mobileVersion
                 deviceId:(NSString *)deviceId
              onCompleted:(void (^)(NSError *error))onCompleted {
    DDLogInfo(@"%s deviceToken=%@ txpbPlatformType=%d osVersion=%@ mobileVersion=%@ deviceId=%@",
            __FUNCTION__, deviceToken, (int) platformType, osVersion, mobileVersion, deviceId);

    TXPBUpdateDeviceTokenRequestBuilder *requestBuilder = [TXPBUpdateDeviceTokenRequest builder];
    requestBuilder.deviceToken = deviceToken;
    requestBuilder.platformType = platformType;
    requestBuilder.osVersion = osVersion;
    requestBuilder.mobileVersion = mobileVersion;
    requestBuilder.deviceId = deviceId;

    [[TXHttpClient sharedInstance] sendRequest:@"/update_device_token"
                                         token:_currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       TX_POST_NOTIFICATION_IF_ERROR(error);
                                       TX_RUN_ON_MAIN(
                                               onCompleted(error);
                                       );
                                   }];
}

- (void)upgrade:(TXPBPlatformType)txpbPlatformType onCompleted:(void (^)(NSError *error, TXPBUpgradeResponse *txpbUpgradeResponse))onCompleted {
    DDLogInfo(@"%s txpbPlatformType=%d", __FUNCTION__, (int) txpbPlatformType);

    TXPBUpgradeRequestBuilder *requestBuilder = [TXPBUpgradeRequest builder];
    requestBuilder.platformType = txpbPlatformType;

    [[TXHttpClient sharedInstance] sendRequest:@"/upgrade"
                                         token:_currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       TXPBUpgradeResponse *txpbUpgradeResponse;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBUpgradeResponse, txpbUpgradeResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                   onCompleted(error, txpbUpgradeResponse);
                                           );
                                       }
                                   }];
}

- (void)deleteLocalCache {
    DDLogInfo(@"%s", __FUNCTION__);

    [_currentUserDbManager.postDao deleteAllPostByType:TXPBPostTypeActivity];
    [_currentUserDbManager.postDao deleteAllPostByType:TXPBPostTypeAgreement];
    [_currentUserDbManager.postDao deleteAllPostByType:TXPBPostTypeAnnouncement];
    [_currentUserDbManager.postDao deleteAllPostByType:TXPBPostTypeIntro];
    [_currentUserDbManager.postDao deleteAllPostByType:TXPBPostTypeRecipes];
}

@end