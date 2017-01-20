//
//  TXSystemManager.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXSystemManager.h"
#import "TXEaseMobHelper.h"
#import "TXContactManager.h"
#import "EMCDDeviceManager.h"
#import <NSDate+DateTools.h>
#import "NSDictionary+Utils.h"
#import "XGPush.h"
#import "BuglySDKHelper.h"
#import <Bugly/CrashReporter.h>
#import "AppDelegate.h"
#import "CircleListViewController.h"
#import "TXFeed+Circle.h"
#import "CircleListOtherCell.h"
#import "TXRequestHelper.h"
#import "UMessage.h"
#import "TXVideoCacheManager.h"
#import <AVFoundation/AVFoundation.h>
#import "TXCustomURLProtocol.h"
#import "EMSDWebImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <AddressBook/AddressBook.h>
#import "XCDSDHomeWorkNoticeManager.h"
#import "Reachability/Reachability.h"

#import "GameManager.h"

static const CGFloat kDefaultPlaySoundInterval = 1.0f;
static const NSInteger kNoDisturbStartHour = 22;
static const NSInteger kNoDisturbEndHour = 8;
static NSString *const kTXServerHost = @"txServerHost";
static NSString *const kTXServerFiltedHost = @"txFiltedHost";
static NSString *const kTXServerPort = @"txServerPort";
static NSString *const kTXEaseMobAppKey = @"txEMAppKey";
static NSString *const kTXWebBaseUrl = @"txWebBaseUrl";

NSString * const kChatListNotifyDeleteFlag = @"chatListNotifyDeleteFlag";
NSString * const kChatListLastNotifyId = @"chatListLastNotifyId";
NSString * const kChatListSwipeCardDeleteFlag = @"chatListSwipeCardDeleteFlag";
NSString * const kChatListLastSwipeCardId = @"chatListLastSwipeCardId";
NSString * const kChatListGardenPostDeleteFlag = @"chatListGardenPostDeleteFlag";
NSString * const kChatListLastGardenPostId = @"chatListLastGardenPostId";
NSString * const kChatListLastAttendanceTime = @"chatListAttendanceTime";
NSString * const kChatListHasAttendanceFlag = @"chatListHasAttendanceFlag";
NSString * const kChatListHomeWorkDeleteFlag = @"chatListHomeWorkDeleteFlag";
NSString * const kChatListLastHomeWorkId = @"chatListLastHomeWorkId";
@interface TXSystemManager()

@property (strong, nonatomic) NSDate *lastPlaySoundDate;
//是否是家长端
@property (nonatomic,readwrite,getter=isParentApp) BOOL parentApp;
//测试环境信息
@property (nonatomic,strong) NSMutableDictionary *serverModeDict;

@end

@implementation TXSystemManager
@synthesize enableGlobalSoundPlay = _enableGlobalSoundPlay;
@synthesize enableGlobalVibrationPlay = _enableGlobalVibrationPlay;
@synthesize parentApp = _parentApp;
@synthesize devVersion = _devVersion;

//创建单例
+ (instancetype)sharedManager
{
    static TXSystemManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
#if DEV_TEST
			_devVersion = YES;
#else
			_devVersion = NO;
#endif
		
        [self setupServerModeInfo];
        NSString *bundleIdString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        //if (bundleIdString && [bundleIdString isEqualToString:@"com.tuxing.chs.parent"]) {
        //modify by sck
        if (bundleIdString && [bundleIdString isEqualToString:@"com.shangde.ps.parents"]) {
            _parentApp = YES;
        }
        if (_devVersion) {
            [self updateCustomServerModeInfo];
            [NSURLProtocol registerClass:[TXCustomURLProtocol class]];
        }
        //创建单例
        [self initTXChatSDK];
        
        NSError *err = nil;
        NSDictionary *userRemindSetting = [[TXChatClient sharedInstance] getCurrentUserProfiles:&err];
        if(userRemindSetting){
            if([userRemindSetting containsKey:KUserSound]){
                _enableGlobalSoundPlay = [[userRemindSetting objectForKey:KUserSound] boolValue];
            }else{
                _enableGlobalSoundPlay = YES;
            }
            if([userRemindSetting containsKey:KUserVibration]){
                _enableGlobalVibrationPlay = [[userRemindSetting objectForKey:KUserVibration] boolValue];
            }else{
                _enableGlobalVibrationPlay = YES;
            }
            if([userRemindSetting containsKey:KUserNoDisturb]){
                _globalNoDisturbStatus = [[userRemindSetting objectForKey:KUserNoDisturb] integerValue];
            }else{
                _globalNoDisturbStatus = TXGlobalNoDisturbStatusClose;
            }
        }else{
            _enableGlobalSoundPlay = YES;
            _enableGlobalVibrationPlay = YES;
            _globalNoDisturbStatus = TXGlobalNoDisturbStatusClose;
        }
        //设置当前最前的聊天窗口用户id
        _currentChatId = @"";
    }
    return self;
}
//初始化 sdk
-(void)initTXChatSDK
{
    [[TXChatClient sharedInstance] setupWithVersion:[NSString stringWithFormat:@"%@_%@", TX_CHAT_CLIENT_PLATFORM,  [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]]];
    //    [TXChatClient sharedInstance].version = [NSString stringWithFormat:@"%@_%@", TX_CHAT_CLIENT_PLATFORM,  [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]];
}
//配置服务器信息
- (void)setupServerModeInfo
{
    _serverModeDict = [NSMutableDictionary dictionary];
    //正式环境
    
    //正式环境 modify by sck
    [_serverModeDict setObject:@{kTXServerHost:@"service.xcsdedu.com",kTXServerFiltedHost:@"service.xcsdedu.com",kTXServerPort:@"80",kTXEaseMobAppKey:KHuanXin_AppKey_Dis,kTXWebBaseUrl:@"http://service.xcsdedu.com",kJSHostUrl:KURL_H5_SERVER_ADDRESS_DIS} forKey:@"publicFormal"];
	
	//测试环境
	[_serverModeDict setObject:@{kTXServerHost:@"121.41.101.14",kTXServerFiltedHost:@"121.41.101.14",kTXServerPort:@"8080",kTXEaseMobAppKey:KHuanXin_AppKey_Test,kTXWebBaseUrl:@"http://121.41.101.14:8080/",kJSHostUrl:KURL_H5_SERVER_ADDRESS_TEST} forKey:@"publicTest"];
	
	//开发环境
	[_serverModeDict setObject:@{kTXServerHost:@"121.40.16.212",kTXServerFiltedHost:@"121.40.16.212",kTXServerPort:@"8080",kTXEaseMobAppKey:KHuanXin_AppKey_Dev,kTXWebBaseUrl:@"http://121.40.16.212:8080/",kJSHostUrl:KURL_H5_SERVER_ADDRESS_DEV} forKey:@"privateDev"];
}
#pragma mark - 程序激活
//执行程序激活的流程
- (void)setupAppLaunchActions
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *devicetoken = [USER_DEFAULT objectForKey:KDeviceTokenKey];

        if([devicetoken length] > 0)
        {
            [[TXRequestHelper shareInstance] updateDeviceTokenToServer:devicetoken];
        }
            
        TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
        if(currentUser)
        {
            [[CrashReporter sharedInstance] setUserId:[NSString stringWithFormat:@"用户UserId%lld", currentUser.userId]];
        }        
        if (_parentApp) {
            //通知列表先从本地读取联系人
            [[TXEaseMobHelper sharedHelper] notifyObserverRefreshChatList];
        }
        //获取联系人
        [[TXChatClient sharedInstance] fetchDepartments:^(NSError *error) {
//            DLog(@"fetchDepartments:");
            //从网络获取成功，通知列表更新群
            [[TXEaseMobHelper sharedHelper] notifyObserverRefreshChatList];
            if(!error)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *departs = [[TXChatClient sharedInstance] getAllDepartments:nil];
                    for(TXDepartment *index in departs)
                    {
                        [[TXChatClient sharedInstance] fetchDepartmentMembers:index.departmentId clearLocalData:NO onCompleted:^(NSError *error) {
    //                        DLog(@"error:%@", error);
                        }];
                    }
                });
            }
        }];
        //更新 用户设置信息
        [[TXChatClient sharedInstance] fetchUserProfiles:^(NSError *error, NSDictionary *userProfiles) {
            if(!error)
            {
                NSArray *profileKeys = [userProfiles allKeys];
                if ([profileKeys containsObject:KUserSound]) {
                    self.enableGlobalSoundPlay = [[userProfiles objectForKey:KUserSound] boolValue];
                }
                if ([profileKeys containsObject:KUserVibration]) {
                    self.enableGlobalVibrationPlay = [[userProfiles objectForKey:KUserVibration] boolValue];
                }
                if ([profileKeys containsObject:KUserNoDisturb]) {
                    self.globalNoDisturbStatus = [[userProfiles objectForKey:KUserNoDisturb] integerValue];
                }
                //更新环信推送配置
                [self updateEaseMobPushNotificationOptions];
                
                //bay gaoju
                [[NSNotificationCenter defaultCenter] postNotificationName:HomePostNotification object:nil];
            }
           
        }];
        //获取微学园信息
        BOOL isNeedFetchWXYPost = NO;
        TXPost *post = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:0 error:nil];
        if (!post) {
            //本地没有微学园数据
            isNeedFetchWXYPost = YES;
        }
        if (isNeedFetchWXYPost) {
            [[TXChatClient sharedInstance].postManager fetchPostGroups:LLONG_MAX gardenId:0 onCompleted:^(NSError *error, NSArray *postGroups, BOOL hasMore) {
                if (!error) {
                    //发送通知刷新列表
                    TXAsyncRunInMain(^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:ChatListFetchNewWXYPostNotification object:nil];
                    });
                }
            }];
        }
        //获取园公众号信息
        BOOL isNeedFetchGardenPost = NO;
        if (currentUser) {
            TXPost *post = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:currentUser.gardenId error:nil];
            if (!post) {
                //本地没有园数据
                isNeedFetchGardenPost = YES;
            }
        }
        if (isNeedFetchGardenPost) {
            [[TXChatClient sharedInstance].postManager fetchPostGroups:LLONG_MAX gardenId:currentUser.gardenId onCompleted:^(NSError *error, NSArray *postGroups, BOOL hasMore) {
                if (!error) {
                    //发送通知刷新列表
                    TXAsyncRunInMain(^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:ChatListRefreshGardenPostNotification object:nil];
                    });
                }
            }];
        }
        
        //add by mey
        XCSDHomeWorkNotice *lastHomeWork = [[XCDSDHomeWorkNoticeManager shareInstance] getHomeWorlLastHomeWorks];
        if (!lastHomeWork) {
            [[TXChatClient sharedInstance].xcsdHomeWorkManager fetchHomeWorks:YES maxHomeWorkId:LLONG_MAX onCompleted:^(NSError *error, NSArray *xcsdHomeWorks, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
                if (!error) {
                    //发送通知刷新列表
                    TXAsyncRunInMain(^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:HomeWorkFetchNewPostNotification object:nil];
                    });
                }
            }];
        }
        
        
        //拉取刷卡信息
        BOOL isNeedFetchCheckIn = NO;
        TXCheckIn *lastCheckIn = [[TXChatClient sharedInstance] getLastCheckIn:nil];
        if (!lastCheckIn) {
            isNeedFetchCheckIn = YES;
        }
        if (isNeedFetchCheckIn) {
            [[TXChatClient sharedInstance] fetchCheckIns:LLONG_MAX onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
                TXAsyncRunInMain(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_CHECKIN object:txCheckIns];
                });
            }];
        }
        //获取counter信息
        [[TXChatClient sharedInstance] fetchCounters:^(NSError *error, NSMutableDictionary *countersDictionary) {
            
        }];
        //拉取历史feeds
//        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
//        if (user) {
//            [self getHistoryFeeds];
//        }

    });
}
//更新环信推送配置
- (void)updateEaseMobPushNotificationOptions
{
    //更新推送设置
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    EMPushNotificationOptions *option = [[EMPushNotificationOptions alloc] init];
    option.nickname = currentUser.nickname;
    option.displayStyle = ePushNotificationDisplayStyle_messageSummary;
    //配置免打扰
    switch (self.globalNoDisturbStatus) {
        case TXGlobalNoDisturbStatusClose: {
            option.noDisturbStatus = ePushNotificationNoDisturbStatusClose;
            break;
        }
        case TXGlobalNoDisturbStatusDay: {
            option.noDisturbStatus = ePushNotificationNoDisturbStatusDay;
            break;
        }
        case TXGlobalNoDisturbStatusNightOnly: {
            option.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
            option.noDisturbingStartH = kNoDisturbStartHour;
            option.noDisturbingEndH = kNoDisturbEndHour;
            break;
        }
        default: {
            break;
        }
    }
    [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:option completion:^(EMPushNotificationOptions *options, EMError *error) {
        if (error) {
            DDLogDebug(@"更新options失败:%@",error);
        }else{
            DDLogDebug(@"更新option成功:%@",options);
        }
    } onQueue:nil];
}
//程序从后台唤醒机制
- (void)fetchInfoWhenAppBecomeActive
{
    NSError *error = nil;
    TXUser *txUser = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if (txUser) {
        //获取用户信息
        [[TXChatClient sharedInstance] fetchUserByUserId:txUser.userId onCompleted:^(NSError *error, TXUser *txUser) {
            if (error) {

            }else{
                
                [UMessage addTag:[NSString stringWithFormat:@"%@%lld", KXGGARDENTAG, txUser.gardenId] response:nil];
            }
        }];
        //调用ping接口
        [[TXChatClient sharedInstance] pingWithCompleted:^(NSError *error) {
            
        }];
        //更新 用户设置信息
        [[TXChatClient sharedInstance] fetchUserProfiles:^(NSError *error, NSDictionary *userProfiles) {
            if(!error)
            {
                NSArray *profileKeys = [userProfiles allKeys];
                if ([profileKeys containsObject:KUserSound]) {
                    self.enableGlobalSoundPlay = [[userProfiles objectForKey:KUserSound] boolValue];
                }
                if ([profileKeys containsObject:KUserVibration]) {
                    self.enableGlobalVibrationPlay = [[userProfiles objectForKey:KUserVibration] boolValue];
                }
                if ([profileKeys containsObject:KUserNoDisturb]) {
                    self.globalNoDisturbStatus = [[userProfiles objectForKey:KUserNoDisturb] integerValue];
                }
                //更新环信推送配置
                [self updateEaseMobPushNotificationOptions];
            }
        }];
        //登录环信流程
        BOOL isLoggedIn = [[EaseMob sharedInstance].chatManager isLoggedIn];
        BOOL isCanAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsCanAutoLogin];
        if (!isLoggedIn && isCanAutoLogin) {
            DDLogDebug(@"环信未登录，重新登录");
            NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:kEaseMobUserName];
            NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:kLocalPassword];
            if (userId && password && [userId length] && [password length]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //发送开始连接的通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
                });
                [[TXEaseMobHelper sharedHelper] startAsynLoginToEaseMobServerWithUserId:userId password:password];
            }
        }else{
            //优化红点逻辑
            UIApplication *application = [UIApplication sharedApplication];
            NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                application.applicationIconBadgeNumber = unReadNumber;
            });
        }
    }
}
#pragma mark - 被T时的重新登录
//重新登录
- (void)reLoginToServerWhenKickOffWithCompletion:(void(^)(BOOL isLoginSuccess,BOOL isInit,NSError *error))block
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalUserName];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
    [[TXChatClient sharedInstance] loginWithUsername:userName password:pwd onCompleted:^(NSError *error, TXUser *txUser) {
//        DDLogDebug(@"login result error:%@", error);
        if (error) {
            block(NO,YES,error);
        }else if (!txUser.isInit){
            block(NO,NO,nil);
        }else{
            //更改状态值
            [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLoginedStatus;
            //登录环信服务器
            NSString *easemobName = [[NSUserDefaults standardUserDefaults] objectForKey:kEaseMobUserName];
            [[TXEaseMobHelper sharedHelper] autoLoginEaseMobServerWithUserName:easemobName password:pwd completion:^(NSDictionary *loginInfo, EMError *error) {
                if (!error) {
                    DDLogDebug(@"重新登录环信server成功:%@",loginInfo);
                    //保存到UserDefaults
                    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",@(txUser.userId)] forKey:kEaseMobUserName];
                    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kLocalUserName];
                    [[NSUserDefaults standardUserDefaults] setValue:pwd forKey:kLocalPassword];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[TXSystemManager sharedManager] setupAppLaunchActions];
                    block(YES,YES,nil);
                }else{
                    DDLogDebug(@"重新登录环信server失败:%@",error);
                    block(NO,YES,nil);
                }
            }];
			
			[[GameManager getInstance] resetData];
        }
    }];
}
#pragma mark - 消息列表页通知+刷卡本地化存储
//保存聊天界面的数据
- (void)saveChatListData:(NSNumber *)data forKey:(NSString *)key
{
    if (!data || !key) {
        return;
    }
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%@_%@",@(currentUser.userId),key]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//获取聊天界面保存的信息
- (NSNumber *)chatListDataForKey:(NSString *)key
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        return nil;
    }
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",@(currentUser.userId),key]];
    return num;
}
#pragma mark - 声音和震动+免打扰
//判断是否可以播放声音
- (BOOL)isCanPlaySoundWithGroupId:(NSString *)groupId
{
    if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusClose) {
        if (groupId && [groupId length]) {
            BOOL isGroupNoDisturb = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:groupId];
            if (isGroupNoDisturb) {
                return NO;
            }
        }
        return _enableGlobalSoundPlay;
    }else if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusDay) {
        return NO;
    }else if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusNightOnly) {
        //判断是否在夜间时间22:00-08:00
        NSDate *date = [NSDate date];
        NSInteger hour = [date hour];
        if (hour >= kNoDisturbStartHour || hour < kNoDisturbEndHour) {
            return NO;
        }else{
            if (groupId && [groupId length]) {
                BOOL isGroupNoDisturb = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:groupId];
                if (isGroupNoDisturb) {
                    return NO;
                }
            }
            return _enableGlobalSoundPlay;
        }
    }
    return YES;
}
//判断是否可以震动
- (BOOL)isCanPlayVibrationWithGroupId:(NSString *)groupId
{
    if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusClose) {
        if (groupId && [groupId length]) {
            BOOL isGroupNoDisturb = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:groupId];
            if (isGroupNoDisturb) {
                return NO;
            }
        }
        return _enableGlobalVibrationPlay;
    }else if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusDay) {
        return NO;
    }else if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusNightOnly) {
        //判断是否在夜间时间22:00-08:00
        NSDate *date = [NSDate date];
        NSInteger hour = [date hour];
        if (hour >= kNoDisturbStartHour || hour < kNoDisturbEndHour) {
            return NO;
        }else{
            if (groupId && [groupId length]) {
                BOOL isGroupNoDisturb = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:groupId];
                if (isGroupNoDisturb) {
                    return NO;
                }
            }
            return _enableGlobalVibrationPlay;
        }
    }
    return YES;
}
//播放声音和震动
- (void)playSoundAndVibrationWithGroupId:(NSString *)groupId
                               emMessage:(EMMessage *)message
{
    [self checkAndPlayMessageSound:YES vibration:YES groupId:groupId emMessage:message];
}
//播放震动
- (void)playVibrationWithGroupId:(NSString *)groupId
                       emMessage:(EMMessage *)message
{
    [self checkAndPlayMessageSound:NO vibration:YES groupId:groupId emMessage:message];
}
//判断是否可以接收本地推送
- (BOOL)isCanReceiveLocalNotificationWithGroupId:(NSString *)groupId
{
    if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusClose) {
        if (groupId && [groupId length]) {
            BOOL isGroupNoDisturb = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:groupId];
            if (isGroupNoDisturb) {
                return NO;
            }
        }
        return YES;
    }else if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusDay) {
        return NO;
    }else if (_globalNoDisturbStatus == TXGlobalNoDisturbStatusNightOnly) {
        //判断是否在夜间时间22:00-08:00
        NSDate *date = [NSDate date];
        NSInteger hour = [date hour];
        if (hour >= kNoDisturbStartHour || hour < kNoDisturbEndHour) {
            return NO;
        }else{
            if (groupId && [groupId length]) {
                BOOL isGroupNoDisturb = [[TXEaseMobHelper sharedHelper] groupNoDisturbStatusWithId:groupId];
                if (isGroupNoDisturb) {
                    return NO;
                }
            }
            return YES;
        }
    }
    return YES;
}
//根据传递的数据判断播放声音震动还是播放单一项
- (void)checkAndPlayMessageSound:(BOOL)isPlaySound
                       vibration:(BOOL)isPlayVibration
                         groupId:(NSString *)groupId
                       emMessage:(EMMessage *)message
{
    //#if !TARGET_IPHONE_SIMULATOR
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        //本地推送或者APNS
        if ([self isCanReceiveLocalNotificationWithGroupId:groupId]) {
//            DDLogDebug(@"应该本地推送了");
            [self showLocalNotificationWithMessage:message];
        }
//        else{
//            DDLogDebug(@"开启了免打扰，不能接收本地推送");
//        }
    }else {
        NSTimeInterval timeInterval = [[NSDate date]
                                       timeIntervalSinceDate:self.lastPlaySoundDate];
        if (timeInterval < kDefaultPlaySoundInterval) {
            //如果距离上次响铃和震动时间太短, 则跳过响铃
            return;
        }
        //保存最后一次响铃时间
        self.lastPlaySoundDate = [NSDate date];
        
        // 收到消息时，播放音频
        if (isPlaySound && [self isCanPlaySoundWithGroupId:groupId]) {
            [[EMCDDeviceManager sharedInstance] playNewMessageSound];
        }
        // 收到消息时，震动
        if (isPlayVibration && [self isCanPlayVibrationWithGroupId:groupId]) {
            [[EMCDDeviceManager sharedInstance] playVibration];
        }
    }
    //#endif
}
//App前台时弹出提醒
- (void)showLocalNotificationOnAppInActiveWithTitle:(NSString *)title
{
    if (!title || ![title length]) {
        return;
    }
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        //不在前台
        return;
    }
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    notification.alertBody = title;
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
- (void)showLocalNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (message && options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[图片]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"[位置]";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"[语音]";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        BOOL isGroup = NO;
        if (message.messageType == eMessageTypeGroupChat) {
            isGroup = YES;
        }
        NSDictionary *dict = [[TXContactManager shareInstance] getUserByUserID:[message.from longLongValue] isGroup:isGroup complete:nil];
        if (dict) {
            NSString *conversationName = dict[@"name"];
            if (conversationName && [conversationName length]) {
                notification.alertBody = [NSString stringWithFormat:@"%@:%@", conversationName, messageStr];
            }else{
                notification.alertBody = messageStr;
            }
        }else{
            notification.alertBody = messageStr;
        }
    }else {
        if (message) {
            notification.alertBody = @"您有一条新消息";
        }else {
            notification.alertBody = @"您有一条新信息";
        }
    }
    
//#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
//#ifdef DEBUG
//    notification.alertBody = [[NSString alloc] initWithFormat:@"[本地推送]%@", notification.alertBody];
//#endif
    
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    BOOL isGroupChat = NO;
    if (message.messageType == eMessageTypeGroupChat) {
        isGroupChat = YES;
    }
    if ([self isCanPlaySoundWithGroupId:isGroupChat ? message.conversationChatter : nil]) {
        notification.soundName = UILocalNotificationDefaultSoundName;
    }else{
        notification.soundName = nil;
    }
    
//    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//    [userInfo setObject:[NSNumber numberWithInt:message.messageType] forKey:kMessageType];
//    [userInfo setObject:message.conversationChatter forKey:kConversationChatter];
//    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
    NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        application.applicationIconBadgeNumber = unReadNumber;
    });
}

#pragma mark - 亲子圈数据请求
- (void)getHistoryFeeds{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *feeds = [[TXChatClient sharedInstance] getFeeds:LLONG_MAX count:20 isInbox:YES error:nil];
        self.circleHistoryArr = [NSMutableArray array];
        for (TXFeed *feed in feeds) {
            NSArray *likes = [[TXChatClient sharedInstance] getComments:feed.feedId targetType:TXPBTargetTypeFeed commentType:TXPBCommentTypeLike maxCommentId:LLONG_MAX count:LLONG_MAX error:nil];
            NSArray *comments = [[TXChatClient sharedInstance] getComments:feed.feedId targetType:TXPBTargetTypeFeed commentType:TXPBCommentTypeReply maxCommentId:LLONG_MAX count:LLONG_MAX error:nil];
            
            feed.isFold = [NSNumber numberWithBool:YES];
            feed.circleLikes = [NSMutableArray arrayWithArray:likes];
            feed.circleComments = [NSMutableArray arrayWithArray:comments];
            dispatch_async(dispatch_get_main_queue(), ^{
                feed.likeLb = [CircleListViewController getNIAttributedLabelWith:likes];
                feed.commentLbArr = [CircleListViewController getAttrobuteLabelArr:feed];
                feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
            });
            [_circleHistoryArr addObject:feed];
        }
    });
}

//检查当前网络状态
- (void)checkIsAllowPlayMediaByCurrentNetworkStatus:(void(^)(BOOL isReachable,BOOL isCanPlay))block
{
    BOOL isNetworkReachable = YES;
    BOOL isCanPlay = YES;
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    switch (status) {
        case NotReachable: {
            //未连接
            isNetworkReachable = NO;
            isCanPlay = NO;
            break;
        }
        case ReachableViaWiFi: {
            //WIFI连接
            break;
        }
        case ReachableViaWWAN: {
            //流量连接
            if (_mediaNetworkType == TXMediaPlayNetworkType_OnlyByWifi) {
                isCanPlay = NO;
            }
            break;
        }
    }
    block(isNetworkReachable,isCanPlay);
    //    block(YES,NO);
}
//弹出流量使用确认alert
- (void)showMediaUseWWANAlertWithAuthorization:(void(^)(BOOL authorization))block
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = appdelegate.window;
    //    ButtonItem *allowOnceItem = [ButtonItem itemWithLabel:@"允许本次" andTextColor:kColorBlack action:^{
    //        block(YES);
    //    }];
    ButtonItem *allowAlwaysItem = [ButtonItem itemWithLabel:@"允许" andTextColor:kColorBlack action:^{
        self.mediaNetworkType = TXMediaPlayNetworkType_All;
        //更新数据
        [[TXChatClient sharedInstance].userManager saveSettingValue:@"1" forKey:kPlayVideoAndAudioBy2G3G4G error:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MediaPlayTypeShouldUpdate object:nil];
        block(YES);
    }];
    ButtonItem *cancelItem = [ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:^{
        block(NO);
    }];
    [window showVerticalAlertViewWithMessage:@"当前无Wifi，是否允许用流量播放?" andButtonItems:allowAlwaysItem,cancelItem, nil];
}
//检查多媒体播放权限
- (void)checkMediaPlayAuthorization:(void(^)(BOOL authorization))block
{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    UIWindow *window = appdelegate.window;
    [self checkIsAllowPlayMediaByCurrentNetworkStatus:^(BOOL isReachable, BOOL isCanPlay) {
        if (!isReachable) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window title:@"当前网络未连接,请稍后重试" animated:YES];
                [hud hide:YES afterDelay:1.5f];
                block(NO);
            });
        }else{
            if (!isCanPlay) {
                [self showMediaUseWWANAlertWithAuthorization:^(BOOL allowed) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(allowed);
                    });
                }];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(YES);
                });
            }
        }
    }];
}


#pragma mark - 缓存
//清空缓存文件
- (void)clearAllUnusedCache
{
    [[TXVideoCacheManager sharedManager] removeAllCachedCircleVideo];
}
//保存图片到本地cache，避免自己上传的图片二次加载
- (void)saveImageToCache:(UIImage *)image forURLString:(NSString *)urlString
{
    [[EMSDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:urlString]];
}
//删除本地cache的图片
- (void)deleteCacheImageForURLString:(NSString *)urlString
{
    if (!urlString) {
        return;
    }
    BOOL isExist = [[EMSDWebImageManager sharedManager] cachedImageExistsForURL:[NSURL URLWithString:urlString]];
    if (isExist) {
        [[EMSDWebImageManager sharedManager].imageCache removeImageForKey:urlString fromDisk:YES];
    }
}
#pragma mark - 权限请求
//检测麦克风的权限
- (void)checkMicrophonePermissionsWithBlock:(void(^)(BOOL granted))block
{
    NSString *mediaType = AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if(block != nil)
            block(granted);
    }];
}
//检测相机的权限
- (void)checkCameraAuthorizationStatusWithBlock:(void(^)(BOOL granted))block
{
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if(block)
            block(granted);
    }];
}


//请求相机和麦克风的权限
- (void)requestCameraAndMicrophonePermissionWithBlock:(void(^)(BOOL cameraGranted,BOOL microphoneGranted))block
{
    if (!IOS7_OR_LATER) {
        //已授权
        block(YES,YES);
        return;
    }
    __block BOOL isGrantCamera = YES;
    __block BOOL isGrantMacrophone = YES;
    dispatch_group_t permissionGroup = dispatch_group_create();
    
    //获取相机的权限
    dispatch_group_enter(permissionGroup);
    [[TXSystemManager sharedManager] checkCameraAuthorizationStatusWithBlock:^(BOOL granted) {
        if (!granted) {
            NSLog(@"未授权相机权限");
            isGrantCamera = NO;
        }else{
            NSLog(@"相机权限已授权");
        }
        dispatch_group_leave(permissionGroup);
    }];
    //获取麦克风的权限
    dispatch_group_enter(permissionGroup);
    [[TXSystemManager sharedManager] checkMicrophonePermissionsWithBlock:^(BOOL granted) {
        if (!granted) {
            NSLog(@"未授权麦克风权限");
            isGrantMacrophone = NO;
        }else{
            NSLog(@"麦克风权限已授权");
        }
        dispatch_group_leave(permissionGroup);
    }];
    dispatch_group_notify(permissionGroup, dispatch_get_main_queue(), ^{
        BOOL isGrantedPermission = isGrantCamera && isGrantMacrophone;
        if (isGrantedPermission) {
            //已授权
            block(YES,YES);
        }else{
            block(isGrantCamera,isGrantMacrophone);
        }
    });

}
//请求相机的权限
- (void)requestCameraPermissionWithBlock:(void(^)(BOOL cameraGranted))block
{
    if (!IOS7_OR_LATER) {
        //已授权
        block(YES);
        return;
    }
    __block BOOL isGrantCamera = YES;
    dispatch_group_t permissionGroup = dispatch_group_create();
    
    //获取相机的权限
    dispatch_group_enter(permissionGroup);
    [[TXSystemManager sharedManager] checkCameraAuthorizationStatusWithBlock:^(BOOL granted) {
        if (!granted) {
            NSLog(@"未授权相机权限");
            isGrantCamera = NO;
        }else{
            NSLog(@"相机权限已授权");
        }
        dispatch_group_leave(permissionGroup);
    }];
    
    dispatch_group_notify(permissionGroup, dispatch_get_main_queue(), ^{
        BOOL isGrantedPermission = isGrantCamera ;
        if (isGrantedPermission) {
            //已授权
            block(YES);
        }else{
            block(isGrantCamera);
        }
    });
    
}
-(void)CheckAddressBookAuthorization:(void (^)(bool isAuthorized))block
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus != kABAuthorizationStatusAuthorized)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         if (error)
                                                         {
                                                             NSLog(@"Error: %@", (__bridge NSError *)error);
                                                         }
                                                         else if (!granted)
                                                         {
                                                             
                                                             block(NO);
                                                         }
                                                         else
                                                         {
                                                             block(YES);
                                                         }
                                                     });
                                                 });
    }
    else
    {
        block(YES);
    }
    
}

//请求相册的权限
- (void)requestPhotoPermissionWithBlock:(void(^)(BOOL photoGranted))block
{
    __block BOOL isGrantPhoto = NO;
    dispatch_group_t permissionGroup = dispatch_group_create();
    //获取相机的权限
    if (iOSVersionGreaterThan(@"8")) {
        PHAuthorizationStatus authorizationStatus = [PHPhotoLibrary authorizationStatus];
        if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
            dispatch_group_enter(permissionGroup);
            //还未选择权限，请求权限
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized){
                    isGrantPhoto = YES;
                }else{
                    isGrantPhoto = NO;
                }
                dispatch_group_leave(permissionGroup);
            }];
        }else if (authorizationStatus == PHAuthorizationStatusAuthorized) {
            isGrantPhoto = YES;
        }
    }else{
        ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
        if (authorizationStatus == ALAuthorizationStatusAuthorized) {
            isGrantPhoto = YES;
        }
    }
    dispatch_group_notify(permissionGroup, dispatch_get_main_queue(), ^{
        block(isGrantPhoto);
    });
}
#pragma mark - 开发时的网络请求Host
//添加自定义环境
- (void)updateCustomServerModeInfo
{
    NSString *customRequestHost = [[NSUserDefaults standardUserDefaults] objectForKey:@"customServerHost"];
    NSString *customRequestPort = [[NSUserDefaults standardUserDefaults] objectForKey:@"customServerPort"];
    if (customRequestHost && customRequestPort && [customRequestHost length] && [customRequestPort length]) {
        NSString *emAppKey;
        NSString *customEMAppKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"customServerEMAppKey"];
        if (!customEMAppKey || ![customEMAppKey length]) {
            emAppKey = KHuanXin_AppKey_Dev;
        }else{
            emAppKey = customEMAppKey;
        }
        //自定义环境
        [_serverModeDict setObject:@{kTXServerHost:customRequestHost,kTXServerPort:customRequestPort,kTXEaseMobAppKey:emAppKey,kTXWebBaseUrl:[NSString stringWithFormat:@"http://%@:%@/",customRequestHost,customRequestPort]} forKey:@"customServerMode"];
    }else{
        [_serverModeDict removeObjectForKey:@"customServerMode"];
    }
}
//获取当前服务器环境的信息
- (NSDictionary *)currentServerModeDict
{
    NSString *modeKey;
    NSString *serverModeUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"serverMode"];
    if (!serverModeUrl || ![serverModeUrl length]) {
        modeKey = @"publicFormal";
    }else{
        modeKey = serverModeUrl;
    }
    if ([[_serverModeDict allKeys] containsObject:modeKey]) {
        NSDictionary *dict = _serverModeDict[modeKey];
        return dict;
    }
    return nil;
}
//获取请求的Host
- (NSString *)requestHost
{
    NSDictionary *dict = [self currentServerModeDict];
    if (dict) {
        return dict[kTXServerHost];
    }
    return @"api.tx2010.com";
}
//过滤h5的Host
- (NSString *)filtedHost
{
    NSDictionary *dict = [self currentServerModeDict];
    if (dict) {
        return dict[kTXServerFiltedHost];
    }
    return @"tx2010.com";
}
- (NSString *)requestPort
{
    NSDictionary *dict = [self currentServerModeDict];
    if (dict) {
        return dict[kTXServerPort];
    }
    return @"80";
}
//环信应用key
- (NSString *)easeMobAppKey
{
    NSDictionary *dict = [self currentServerModeDict];
    if (dict) {
        return dict[kTXEaseMobAppKey];
    }
    return KHuanXin_AppKey_Dis;
}
//h5页面baseUrl
- (NSString *)webBaseUrlString
{
    NSDictionary *dict = [self currentServerModeDict];
    if (dict) {
        return dict[kTXWebBaseUrl];
    }
    return @"http://h5.tx2010.com/";
}

- (NSString *)getJSHostUrlString
{
	NSDictionary *dict = [self currentServerModeDict];
	if (dict) {
		return dict[kJSHostUrl];
	}
	return KURL_H5_SERVER_ADDRESS_DIS;
}
@end
