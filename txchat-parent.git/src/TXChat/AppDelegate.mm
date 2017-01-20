//
//  AppDelegate.m
//  TXChat
//
//  Created by lingiqngwan on 5/17/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "AppDelegate.h"
#import "FoundViewController.h"
#import "HomeViewController.h"
#import "MineViewController.h"
#import "LoginViewController.h"
#import <Reachability/Reachability.h>
#import "AppDelegate+EaseMob.h"
#import "TXParentChatListViewController.h"
#import "TXEaseMobHelper.h"
#import "TXNoticeManager.h"
#import "TXCacheManage.h"
#import "Formatter.h"
#import "TXSystemManager.h"
#import "CustomTabBarController.h"
#import "CircleListViewController.h"
#import "IdentityViewController.h"
#import "CircleUploadCenter.h"
#import "XGPush.h"
#import "XGSetting.h"
#import "TXNoticeManager.h"
#import "TXCacheManage.h"
#import "BuglySDKHelper.h"
#import "TXNoticeManager.h"
#import "CustomNavigationController.h"
#import "ActiveViewController.h"
#import "TXCustomAlertWindow.h"
#import "TXUser+Utils.h"
#import "TXRequestHelper.h"
#import "SDiPhoneVersion.h"
#import "EMSDImageCache.h"
#import "Utils.h"
//#import "TXPatchManager.h"
#import "UMessage.h"
#import <TXChatCommon/UMSocial.h>
#import <TXChatCommon/UMSocialSinaHandler.h>
#import <TXChatCommon/UMSocialWechatHandler.h>
#import <TXChatCommon/UMSocialQQHandler.h>
#import "PublishmentDetailViewController.h"
#import "ShowWeiDou.h"
#import "SignInAnimation.h"
#import "UIButton+EMWebCache.h"
#import "TXCalendarManager.h"
#import <UMOnlineConfig.h>
#import "XCDSDHomeWorkNoticeManager.h"
#import "HomeWorkListViewController.h"

////----------
//
#include "CCAppDelegate.h"
#import "TXGreetingViewController.h"
//
//
////----------

//static CCAppDelegate s_sharedApplication;

static NSInteger const kLogoutRetryMaxCount = 5;

@interface AppDelegate ()
{
    BOOL _isIdentity;        //已经弹出身份选择
    BOOL _isHasLaunched;
    BOOL _isTokenExpiredAlertShowed;
    NSInteger _logoutRetryCount;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置状态栏效果
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticeError:) name:TX_NOTIFICATION_ERROR object:nil];
    self.isConnected = YES; //默认认为网络已连接
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [TXNoticeManager shareInstance];
    [TXCacheManage shareInstance];
    [CircleUploadCenter shareInstance];
//    [[TXPatchManager sharedManager] startEngine];
    //初始化2.0.3的默认值
    BOOL isInitFlag = [[NSUserDefaults standardUserDefaults] boolForKey:kIsHasInitAutoLoginFlag];
    if (!isInitFlag) {
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalUserName];
        NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
        if (userName && pwd && [userName length] && [pwd length]) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
        }
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsHasInitAutoLoginFlag];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //初始化友盟统计
    [self initUmeng];
    //初始化文件日志
    [self initFileLogger];
    //初始化信鸽推送
//    [self initXGPush:launchOptions];
    //初始化环信推送
    [self registerEaseMobRemoteNotification];
    //初始化环信设置
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    //初始化 bugly错误日志上报
    [self initBuglySDK];
    //初始化友盟推送
    [self initUMessage:launchOptions];
    //初始化Bugtags
    [self initBugtags];
    //初始化友盟分享
    [self setupShareConfig];
    
    //注册微豆 通知
    [self registerWeiDouNotification];
    //注册登录成功通知
    [self registerSignInNotification];
    DDLogDebug(@"app 启动");
    DDLogDebug(@"mobile system:%@", [[TXRequestHelper shareInstance] getMobileInfo]);
    //监听网络
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    reach.reachableBlock = ^(Reachability*reach)
    {
        if (self.isConnected == NO) {
            //网络从无网变成有网，获取用户信息
            [[TXSystemManager sharedManager] fetchInfoWhenAppBecomeActive];
        }
        self.isConnected = YES;
    };

    reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isConnected = NO;
            [self showNetworkReachableHud:NO];
//            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityStatus object:@{@"status":[NSNumber numberWithBool:NO]}];
        });
    };
    [reach startNotifier];
    //
//    BOOL isEaseMobAutoLogin = [[[EaseMob sharedInstance] chatManager] isAutoLoginEnabled];
    
    if ([USER_DEFAULT objectForKey:kFirstLogin]) {
        
        if ([self isAutoLogin]) {
            [self createTabBarView];
            //登陆环信服务器
            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kEaseMobUserName];
            NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
            [[TXEaseMobHelper sharedHelper] loginAfterPingTXServerWithUserName:userName password:pwd];
            dispatch_async(dispatch_get_main_queue(), ^{
                //发送开始连接的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
            });
            
            //        BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
            //        if (!isAutoLogin) {
            //            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kEaseMobUserName];
            //            NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
            //            [LoginViewController loginEaseMob:userName andPwd:pwd];
            //        }else {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                //发送开始连接的通知
            //                [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
            //            });
            //        }
            //执行默认的操作
            [[TXSystemManager sharedManager] setupAppLaunchActions];
            [self launchWithNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
            
        }else {
            [self createLoginView];
        }
    }else{
        
//        TXGreetingViewController *greeting = [[TXGreetingViewController alloc] init];
//        self.window.rootViewController = greeting;
        if ([self isAutoLogin]) {
            [self createTabBarView];
            //登陆环信服务器
            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kEaseMobUserName];
            NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
            [[TXEaseMobHelper sharedHelper] loginAfterPingTXServerWithUserName:userName password:pwd];
            dispatch_async(dispatch_get_main_queue(), ^{
                //发送开始连接的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
            });
            
            //        BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
            //        if (!isAutoLogin) {
            //            NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kEaseMobUserName];
            //            NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
            //            [LoginViewController loginEaseMob:userName andPwd:pwd];
            //        }else {
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                //发送开始连接的通知
            //                [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
            //            });
            //        }
            //执行默认的操作
            [[TXSystemManager sharedManager] setupAppLaunchActions];
            [self launchWithNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
            
        }else {
            [self createLoginView];
        }
    }
    
    [self.window makeKeyAndVisible];
    [self.window makeKeyWindow];
    
    NSDictionary *profileDict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    NSString *splashImg = [profileDict objectForKey:TX_PROFILE_KEY_SPLASH_IMAGE];
    NSError *error = nil;
    NSArray *adArr = [NSJSONSerialization JSONObjectWithData:[splashImg?splashImg:@"" dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    if (adArr.count) {
        UIView *adView = [[UIView alloc] initWithFrame:self.window.bounds];
        adView.backgroundColor = [UIColor whiteColor];
        [self.window addSubview:adView];
        
        UIButton *adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        adBtn.frame = adView.bounds;
        adBtn.adjustsImageWhenHighlighted = NO;
        adBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        adBtn.imageView.clipsToBounds = YES;
        [adBtn TX_setImageWithURL:[NSURL URLWithString:adArr[0][@"imgUrl"]] forState:UIControlStateNormal placeholderImage:nil];
        [adView addSubview:adBtn];
        if (adArr[0][@"url"] && [adArr[0][@"url"] length]) {
            [adBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                [adView removeFromSuperview];
                PublishmentDetailViewController *listVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:adArr[0][@"url"]];
                [self.viewController.navigationController pushViewController:listVc animated:YES];
                
            }];
        }
        
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 3*NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                adView.alpha = 0;
            } completion:^(BOOL finished) {
                [adView removeFromSuperview];
            }];
        });
    }
    
    //点击了push消息
    if (launchOptions) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //发送开始连接的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
        });
    }
    //注册注销事件
    [self registerLogoutObserverEvent];
    if(launchOptions != nil)
    {
        [MobClick event:@"push" label:@"点击推送进入"];
    }
    else
    {
        [MobClick event:@"push" label:@"正常启动"];
    }
//    [self checkUpdate];
    [EMSDImageCache sharedImageCache].maxMemoryCost =3*1024*1024;
    //初始化考勤控件
    [TXCalendarManager shareInstance];
    return YES;
}
//初始化分享内容
- (void)setupShareConfig
{
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:UMENG_APPKEY];
    
    //设置微信AppId
    [UMSocialWechatHandler setWXAppId:UMENG_WXAppId appSecret:UMENG_WXAppSecrect url:nil];
    
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setQQWithAppId:UMENG_QQAppId appKey:UMENG_QQAppKey url:nil];
    
    [UMSocialQQHandler setSupportWebView:YES];
    [UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline]];

}
- (void)showNetworkReachableHud:(BOOL)isReachable
{
    MBProgressHUD *failedHud = [[MBProgressHUD alloc] initWithView:self.window];
    //    failedHud.layer.cornerRadius = 5.f;
    //    failedHud.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
    //    [self.view addSubview:failedHud];
    [[TXCustomAlertWindow sharedWindow] showWithView:failedHud];
    
    failedHud.mode = MBProgressHUDModeNone;
    
    //    finishHud.delegate = self;
    if (isReachable) {
        failedHud.labelText = @"网络已连接";
    }else{
        failedHud.labelText = @"网络未连接";
    }
    [failedHud show:YES];
    //    [failedHud hide:YES afterDelay:1.5f];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [failedHud hide:YES];
        [[TXCustomAlertWindow sharedWindow] hide];
    });
}
//注册环信注销事件监听
- (void)registerLogoutObserverEvent
{
    [[TXEaseMobHelper sharedHelper] observeLogOffEventWithBlock:^(NSDictionary *info, EMError *error, TXEaseMobLogoffType type) {
        if (!error) {
            if (type == TXEaseMobOtherDeviceLoginedType) {
                //修改是否允许下次自动登录标示值
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsCanAutoLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (_isTokenExpiredAlertShowed) {
                    return;
                }
                _isTokenExpiredAlertShowed = YES;
                //HUD提示其他设备已登录当前账号
                ButtonItem *reloginItem = [ButtonItem itemWithLabel:@"重新登录" andTextColor:kColorBlack action:^{
                    [TXProgressHUD showHUDAddedTo:self.window withMessage:@""];
                    [[TXSystemManager sharedManager] reLoginToServerWhenKickOffWithCompletion:^(BOOL isLoginSuccess, BOOL isInit, NSError *error) {
                        [TXProgressHUD hideHUDForView:self.window animated:YES];
                        if (isLoginSuccess) {
                            //重新登录成功
                            DDLogDebug(@"被T后重登陆成功");
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }else{
                            //退出失败，退到登陆页重新登录
                            LoginViewController *loginVC = [[LoginViewController alloc] init];
                            CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                                                   initWithRootViewController:loginVC];
                            loginNV.navigationBarHidden = YES;
                            self.window.rootViewController = loginNV;
                            self.viewController = nil;
                            //isInit
                            if (!isInit) {
                                //进入激活流程
                                NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
                                ActiveViewController *avc = [[ActiveViewController alloc] init];
                                avc.isPwd = NO;
                                avc.password = pwd;
                                [loginNV pushViewController:avc animated:YES];
                            }
                            //UserDefaults数据更新
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        //重置状态
                        _isTokenExpiredAlertShowed = NO;
                    }];
                }];
                ButtonItem *cancelItem = [ButtonItem itemWithLabel:@"退出" andTextColor:kColorBlack action:^{
                    //清空App角标
                    UIApplication *application = [UIApplication sharedApplication];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        application.applicationIconBadgeNumber = 0;
                    });
                    [[TXChatClient sharedInstance] cleanCurrentContext];
                    //进入登陆界面
                    LoginViewController *loginVC = [[LoginViewController alloc] init];
                    CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                                           initWithRootViewController:loginVC];
                    loginNV.navigationBarHidden = YES;
                    self.window.rootViewController = loginNV;
                    self.viewController = nil;
                    //UserDefaults数据更新
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //重置状态
                    _isTokenExpiredAlertShowed = NO;
                }];
                [self.window showAlertViewWithMessage:@"你的帐号已在另一台设备登录，如非本人操作，请及时修改或找回密码。" andButtonItems:cancelItem,reloginItem, nil];
            }else if (type == TXEaseMobServerRemovedCountType) {
                //HUD提示服务器已删除当前账号
                ButtonItem *logoutButton = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                    //清空App角标
                    UIApplication *application = [UIApplication sharedApplication];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        application.applicationIconBadgeNumber = 0;
                    });
                    [[TXChatClient sharedInstance] cleanCurrentContext];
                    //进入登陆界面
                    LoginViewController *loginVC = [[LoginViewController alloc] init];
                    CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                                           initWithRootViewController:loginVC];
                    loginNV.navigationBarHidden = YES;
                    self.window.rootViewController = loginNV;
                    self.viewController = nil;
                    //UserDefaults数据更新
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }];
                NSString *alertMsg = @"帐号已下线，请重新登录";
                [self.window showAlertViewWithMessage:alertMsg andButtonItems:logoutButton, nil];
                //UserDefaults数据更新
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
                //修改是否允许下次自动登录标示值
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsCanAutoLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else if (type == TXEaseMobNotRemindType) {
                DDLogDebug(@"不提醒注销环信已成功");
            }else{
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                                       initWithRootViewController:loginVC];
                loginNV.navigationBarHidden = YES;
                self.window.rootViewController = loginNV;
                self.viewController = nil;
                //UserDefaults数据更新
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
                //修改是否允许下次自动登录标示值
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsCanAutoLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else{
            DDLogDebug(@"注销环信服务器失败:%@",@(type));
        }
    }];
}
//注销环信服务器
- (void)logoutEaseMobAccountWhenTokenExpiredWithTokenError:(NSError *)error
{
    if (_logoutRetryCount >= kLogoutRetryMaxCount) {
        _logoutRetryCount = 0;
        DDLogDebug(@"noticeError注销环信超过最大限制");
        [self showTokenExpiredAlertWithLogoutEMStatus:NO tokenError:error];
        return;
    }
    _logoutRetryCount += 1;
    if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
        //设置状态值
        [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLogoffStatus;
        //注销环信
        [[TXEaseMobHelper sharedHelper] logOffFromEaseMobServerWithUnbindDeviceToken:YES logoffType:TXEaseMobNotRemindType completion:^(NSDictionary *info, EMError *emError, TXEaseMobLogoffType type) {
            [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedNormalStatus;
            if (emError) {
                DDLogDebug(@"noticeError注销环信服务器失败:%@",emError);
                [self logoutEaseMobAccountWhenTokenExpiredWithTokenError:error];
            }else{
                //注销成功,添加LOG记录
                DDLogDebug(@"noticeError注销环信服务器成功");
                _logoutRetryCount = 0;
                [self showTokenExpiredAlertWithLogoutEMStatus:YES tokenError:error];
            }
        }];
    }else{
        _logoutRetryCount = 0;
        [self showTokenExpiredAlertWithLogoutEMStatus:YES tokenError:error];
    }
}
//显示token过期弹窗
- (void)showTokenExpiredAlertWithLogoutEMStatus:(BOOL)isLogout
                                     tokenError:(NSError *)error
{
    [TXProgressHUD hideHUDForView:self.window animated:YES];
    ButtonItem *reloginItem = [ButtonItem itemWithLabel:@"重新登录" andTextColor:kColorBlack action:^{
        [TXProgressHUD showHUDAddedTo:self.window withMessage:@""];
        [[TXSystemManager sharedManager] reLoginToServerWhenKickOffWithCompletion:^(BOOL isLoginSuccess, BOOL isInit, NSError *error) {
            [TXProgressHUD hideHUDForView:self.window animated:YES];
            if (isLoginSuccess) {
                //重新登录成功
                DDLogDebug(@"被T后重登陆成功");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }else{
                //退出失败，退到登陆页重新登录
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                                       initWithRootViewController:loginVC];
                loginNV.navigationBarHidden = YES;
                self.window.rootViewController = loginNV;
                self.viewController = nil;
                //isInit
                if (!isInit) {
                    //进入激活流程
                    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
                    ActiveViewController *avc = [[ActiveViewController alloc] init];
                    avc.isPwd = NO;
                    avc.password = pwd;
                    [loginNV pushViewController:avc animated:YES];
                }
                //UserDefaults数据更新
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            //重置状态
            _isTokenExpiredAlertShowed = NO;
        }];
    }];
    ButtonItem *cancelItem = [ButtonItem itemWithLabel:@"退出" andTextColor:kColorBlack action:^{
        //退出环信服务器
        if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
            //设置状态值
            [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLogoffStatus;
            //注销环信
            [[TXEaseMobHelper sharedHelper] logOffFromEaseMobServerWithUnbindDeviceToken:YES logoffType:TXEaseMobNotRemindType completion:^(NSDictionary *info, EMError *emError, TXEaseMobLogoffType type) {
                [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedNormalStatus;
                if (emError) {
                    DDLogDebug(@"noticeError注销环信服务器失败:%@",emError);
                }else{
                    //注销成功,添加LOG记录
                    DDLogDebug(@"noticeError注销环信服务器成功");
                }
            }];
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
        }else{
            DDLogDebug(@"未登录环信服务器，无须注销easemob");
        }
        //清空App角标
        UIApplication *application = [UIApplication sharedApplication];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            application.applicationIconBadgeNumber = 0;
        });
        [[TXChatClient sharedInstance] cleanCurrentContext];
        //退出到登陆界面
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                               initWithRootViewController:loginVC];
        loginNV.navigationBarHidden = YES;
        self.window.rootViewController = loginNV;
        self.viewController = nil;
        //UserDefaults数据更新
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEaseMobUserName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocalPassword];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //重置状态
        _isTokenExpiredAlertShowed = NO;
    }];
    NSString *message = error.userInfo[kErrorMessage];
    [self.window showAlertViewWithMessage:message andButtonItems:cancelItem,reloginItem, nil];
}
- (void)noticeError:(NSNotification *)notification{
    DDLogDebug(@"noticeError:%@",notification);
    NSError *error = notification.object;
    if (error.code == TX_STATUS_UNAUTHORIZED ||
        error.code == TX_STATUS_DB_INIT_FAILED ||
        error.code == TX_STATUS_LOCAL_USER_EXPIRED) {
        //修改是否允许下次自动登录标示值
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIsCanAutoLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (_isTokenExpiredAlertShowed) {
            return;
        }
        _isTokenExpiredAlertShowed = YES;
        //注销环信
        [TXProgressHUD showHUDAddedTo:self.window title:@"账户已过期,正在注销请稍候" animated:YES];
        //        [TXProgressHUD showHUDAddedTo:self.window withMessage:@""];
        [self logoutEaseMobAccountWhenTokenExpiredWithTokenError:error];
    }
}

//友盟统计
-(void)initUmeng
{
    [MobClick setCrashReportEnabled:NO];
    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy)REALTIME channelId:nil];

}



-(void)initFileLogger
{
    return;
//    Formatter *formatter = [[Formatter alloc] init];
//    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
//    [fileLogger setLogFormatter:formatter];
//    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    [DDLog addLogger:fileLogger];
}


#pragma mark - UMeng HandleURL跳转
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    return [UMSocialSnsService handleOpenURL:url];
}
#pragma mark -  信鸽推送

- (void)registerPushForIOS8{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    //Types
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    //Actions
    UIMutableUserNotificationAction *acceptAction = [[UIMutableUserNotificationAction alloc] init];
    
    acceptAction.identifier = @"ACCEPT_IDENTIFIER";
    acceptAction.title = @"Accept";
    
    acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    acceptAction.destructive = NO;
    acceptAction.authenticationRequired = NO;
    
    //Categories
    UIMutableUserNotificationCategory *inviteCategory = [[UIMutableUserNotificationCategory alloc] init];
    
    inviteCategory.identifier = @"INVITE_CATEGORY";
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextDefault];
    
    [inviteCategory setActions:@[acceptAction] forContext:UIUserNotificationActionContextMinimal];
    
    NSSet *categories = [NSSet setWithObjects:inviteCategory, nil];
    
    
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
}

- (void)registerPush{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

//注册信鸽推送
-(void)initXGPush:(NSDictionary *)launchOptions
{
    [XGPush startApp:KXGPUSHID appKey:KXGPUSHKEY];
    
    //注销之后需要再次注册前的准备
    void (^successCallback)(void) = ^(void){
        //如果变成需要注册状态
        if(![XGPush isUnRegisterStatus])
        {
            //iOS8注册push方法
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
            
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if(sysVer < 8){
                [self registerPush];
            }
            else{
                [self registerPushForIOS8];
            }
#else
            //iOS8之前注册push方法
            //注册Push服务，注册后才能收到推送
            [self registerPush];
#endif
        }
    };
    [XGPush initForReregister:successCallback];
    
    //推送反馈(app不在前台运行时，点击推送激活时)
    [XGPush handleLaunching:launchOptions];
    
    //推送反馈回调版本示例
    void (^successBlock)(void) = ^(void){
        //成功之后的处理
        NSLog(@"[XGPush]handleLaunching's successBlock");
    };
    
    void (^errorBlock)(void) = ^(void){
        //失败之后的处理
        NSLog(@"[XGPush]handleLaunching's errorBlock");
    };
    
    [XGPush handleLaunching:launchOptions successCallback:successBlock errorCallback:errorBlock];
}



- (BOOL)isAutoLogin{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        DDLogDebug(@"currentUser未初始化成功");
        return NO;
    }
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalUserName];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalPassword];
    BOOL isCanAutoLogin = [[NSUserDefaults standardUserDefaults] boolForKey:kIsCanAutoLogin];
    if (!userName || !pwd || !isCanAutoLogin) {
        return NO;
    }
    return YES;
}

-(void)initBuglySDK
{
    [BuglySDKHelper initSDK];
    
    // 设置崩溃捕获回调方法,参数为回调函数的地址. App可以在此回调中处理崩溃发生时的现场信息,
    [BuglySDKHelper setExceptionCallback:exception_callback_handler_adhoc];

}
static int exception_callback_handler_adhoc() {
    DDLogDebug(@"enter the exception callback");
    NSException *exception = [[CrashReporter sharedInstance] getCurrentException];
    if (exception) {
        NSLog(@"sdk catch an NSException: \n%@:%@\nRetrace stack:\n%@", [exception name], [exception reason], [exception callStackSymbols]);
    } else {
        NSString *type  = [[CrashReporter sharedInstance] getCrashType];
        NSString *stack = [[CrashReporter sharedInstance] getCrashStack];
        NSLog(@"sdk catch an exception: \nType:%@ \nTrace stack:\n%@", type, stack);
        
        NSString *crashLog = [[CrashReporter sharedInstance] getCrashLog];
        if (crashLog) {
            NSLog(@"sdk save a crash log: \n%@", crashLog);
        }
    }
    
    // 你可以通过此接口添加附带信息同崩溃信息一起上报, 以key-value形式组装
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if(currentUser != nil)
    {
        [[CrashReporter sharedInstance] setUserData:@"userId" value:[NSString stringWithFormat:@"%lld", currentUser.userId]];
    }    
    NSString *devicetoken = [USER_DEFAULT objectForKey:KDeviceTokenKey];
    [[CrashReporter sharedInstance] setUserData:@"devicetoken" value:devicetoken];
    
    // 你可以通过次接口添加附件信息同崩溃信息一起上报
//    [[CrashReporter sharedInstance] setAttachLog:@"使用Bugly进行崩溃问题跟踪定位"];
    
    DDLogDebug(@"appcrash");
    
    return 1;
}
#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define _IPHONE80_ 80000
    //初始化友盟推送
-(void)initUMessage:(NSDictionary *)launchOptions
{
    
    [UMOnlineConfig updateOnlineConfigWithAppkey:UMENG_APPKEY];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    [UMessage startWithAppkey:UMENG_APPKEY launchOptions:launchOptions];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
}
- (void)onlineConfigCallBack:(NSNotification *)notification {
    NSLog(@"online config has fininshed and params = %@", notification.userInfo);
    NSString *testValue =  [UMOnlineConfig getConfigParams:@"test"];
    NSLog(@"testValue:%@", testValue);
}

//初始化Bugtags
-(void)initBugtags
{
//    if([TXSystemManager sharedManager].isDevVersion )
//    {
//        [Bugtags startWithAppKey:BUGTAGS_APP_ID invocationEvent:BTGInvocationEventBubble];
//    }
}

-(void)launchWithNotification:(NSDictionary *)localNotif
{
    if(localNotif == nil)
    {
        return ;
    }
    NSInteger type = [[localNotif objectForKey:@"pushType"] intValue];
    if(type  == TXPBPushTypePushLerngarden)
    {
        //        NSDictionary *dict = [localNotif valueForKey:@"aps"];
        NSString *url = [localNotif objectForKey:@"url"];
        //        NSString *pushId = [localNotif objectForKey:@"id"];
        DDLogDebug(@"localNotif:%@", localNotif);
        if([self isAutoLogin])
        {
            
            UIViewController *VC = self.window.rootViewController;
            if(VC && [VC isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *nav = (UINavigationController *)VC;
                PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:url];
                detailVc.postType = TXHomePostType_WeiXueYuanPush;
                [nav pushViewController:detailVc animated:YES];
            }
        }
    }else if(type == TXPBPushTypePushHomework) {
        
        if([self isAutoLogin])
        {
            
            UIViewController *VC = self.window.rootViewController;
            if(VC && [VC isKindOfClass:[UINavigationController class]])
            {
                UINavigationController *nav = (UINavigationController *)VC;
                HomeWorkListViewController *homeworkVC = [[HomeWorkListViewController alloc] init];
                [nav pushViewController:homeworkVC animated:YES];
            }
        }
    }
}

- (void)createLoginView {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    CustomNavigationController *loginNV = [[CustomNavigationController alloc]
                                           initWithRootViewController:loginVC];
    loginNV.navigationBarHidden = YES;
    self.window.rootViewController = loginNV;
}


- (void)createTabBarView{
    //消息
    UIViewController *messageVC = [[TXParentChatListViewController alloc] init];
    //家园
    UIViewController *homeVC = [[HomeViewController alloc] init];
//    //亲子圈
//    UIViewController *foundVC = [[CircleListViewController alloc] init];
    //发现
    UIViewController *foundVC = [[FoundViewController alloc] init];
    //我的
    UIViewController *mineVC = [[MineViewController alloc] init];
    
    CustomTabBarController *tabBarController = [[CustomTabBarController alloc] init];
    [tabBarController setViewControllers:@[messageVC, homeVC, foundVC, mineVC]];
    tabBarController.selectedViewController=homeVC;
    tabBarController.selectedIndex=1;
    self.viewController = tabBarController;
    
    [self customizeTabBarForController:tabBarController];
    
    CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:self.viewController];
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    //注册底部栏通知
    [self registerBottomCounterNotification];
    
    // 检查更新
    [self checkUpdate];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    NSArray *tabBarItemImages = @[@{@"title":@"消息",@"img":@"nav_message"}, @{@"title":@"学堂",@"img":@"nav_home"}, @{@"title":@"发现",@"img":@"nav_circle"},@{@"title":@"我",@"img":@"nav_mine"}];
    
    NSInteger index = 0;
    [tabBarController.tabBar setHeight:kTabBarHeight];
    tabBarController.tabBar.backgroundView.backgroundColor = kColorWhite;
    [tabBarController.tabBar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)]];
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        NSDictionary *dic = [tabBarItemImages objectAtIndex:index];
        [item setTitle:dic[@"title"]];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            item.unselectedTitleAttributes = @{
                                           NSFontAttributeName: [UIFont systemFontOfSize:12],
                                           NSForegroundColorAttributeName: kColorItem,
                                           };
            item.selectedTitleAttributes = @{
                                               NSFontAttributeName: [UIFont systemFontOfSize:12],
                                               NSForegroundColorAttributeName: kColorType,
                                               };
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            item.unselectedTitleAttributes = @{
                                           UITextAttributeFont: [UIFont systemFontOfSize:12],
                                           UITextAttributeTextColor: kColorItem,
                                           };
            item.selectedTitleAttributes = @{
                                               UITextAttributeFont: [UIFont systemFontOfSize:12],
                                               UITextAttributeTextColor: kColorType,
                                               };
#endif
        }
        [item setBadgeBackgroundColor:RGBCOLOR(255, 0, 0)];
        item.badgePositionAdjustment = UIOffsetMake(-4, 3);
        if ([SDiPhoneVersion deviceSize] == iPhone47inch ||
            [SDiPhoneVersion deviceSize] == iPhone55inch){
            [item setBadgeTextFont:[UIFont systemFontOfSize:4.5f]];
        }else{
            [item setBadgeTextFont:[UIFont systemFontOfSize:3.f]];
        }
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",dic[@"img"]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",dic[@"img"]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}
//消息列表页是否有微学园或者园公众号的红点
- (BOOL)isPostConversationHasNewData
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        return NO;
    }
    BOOL isHasData = NO;
    TXPost *post = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:0 error:nil];
    TXPost *gardenPost = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:currentUser.gardenId error:nil];
    NSDictionary *profileDict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (post) {
        //本地数据库有微学园数据
        if (profileDict && [[profileDict allKeys] containsObject:TX_PROFILE_KEY_LEARN_GARDEN_CLICKED]) {
            int64_t isClick = [profileDict[TX_PROFILE_KEY_LEARN_GARDEN_CLICKED] longLongValue];
            if (isClick == 0) {
                //未阅读
                isHasData = YES;
            }
        }else{
            isHasData = YES;
        }
    }
    if (!isHasData && gardenPost) {
        //本地数据库有微学园数据
        if (profileDict && [[profileDict allKeys] containsObject:TX_PROFILE_KEY_GARDEN_OFFICIAL_ACCOUNT_CLICKED]) {
            int64_t isClick = [profileDict[TX_PROFILE_KEY_GARDEN_OFFICIAL_ACCOUNT_CLICKED] longLongValue];
            if (isClick == 0) {
                //未阅读
                isHasData = YES;
            }
        }else{
            isHasData = YES;
        }
    }
    return isHasData;
}
//获取请假消息红点
- (BOOL)isAttendanceConversationHasNewData
{
    BOOL isHasNewAttendance = NO;
    NSDictionary *restDict = [self countValueForType:TXClientCountType_Approve];
    NSInteger restNewValue = [[restDict valueForKey:TXClientCountNewValueKey] integerValue];
    if (restNewValue > 0) {
        //有新的请假
        isHasNewAttendance = YES;
    }
    return isHasNewAttendance;
}
-(void)registerBottomCounterNotification
{
    DDLogDebug(@"registerBottomCounterNotification");
    
    //处理作业刷新事件
    [self subscribeCountType:TXClientCountType_HomeWork refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (oldValue < newValue) {
            [[XCDSDHomeWorkNoticeManager shareInstance] asyncNewsHomeWorks];
        }
    } invokeNow:YES];
    
    //注册微学园count事件
    [self subscribeCountType:TXClientCountType_LearnGarden refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (newValue > 0) {
            [[TXChatClient sharedInstance] setUserProfileValue:0 forKey:TX_PROFILE_KEY_LEARN_GARDEN_CLICKED];
            //拉取最新的微学园信息
            [[TXChatClient sharedInstance].postManager fetchPostGroups:LLONG_MAX gardenId:0 onCompleted:^(NSError *error, NSArray *postGroups, BOOL hasMore) {
                if (!error) {
                    //发送通知刷新列表
                    TXAsyncRunInMain(^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:ChatListFetchNewWXYPostNotification object:nil];
                    });
                }
            }];
        }
    } invokeNow:YES];
    //注册园公众号count事件
    [self subscribeCountType:TXClientCountType_GardenPost refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (newValue > 0) {
            [[TXChatClient sharedInstance] setUserProfileValue:0 forKey:TX_PROFILE_KEY_GARDEN_OFFICIAL_ACCOUNT_CLICKED];
            //拉取最新的微学园信息
            TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
            if (!currentUser) {
                return;
            }
            [[TXChatClient sharedInstance].postManager fetchPostGroups:LLONG_MAX gardenId:currentUser.gardenId onCompleted:^(NSError *error, NSArray *postGroups, BOOL hasMore) {
                if (!error) {
                    //发送通知刷新列表
                    TXAsyncRunInMain(^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:ChatListRefreshGardenPostNotification object:nil];
                    });
                }
            }];
        }
    } invokeNow:YES];
    //处理通知刷新事件
    [self subscribeCountType:TXClientCountType_Notice refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (oldValue < newValue) {
            [[TXNoticeManager shareInstance] asyncNewsNotices];
        }
    } invokeNow:YES];
    //处理刷卡刷新事件
    [self subscribeCountType:TXClientCountType_Checkin refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (newValue > 0) {
            [[TXChatClient sharedInstance] fetchCheckIns:LLONG_MAX onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
                TXAsyncRunInMain(^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_CHECKIN object:txCheckIns];
                });
            }];
        }
    } invokeNow:YES];
    //处理消息页的红点
//    [self subscribeMultipleCountTypes:@[@(TXClientCountType_Checkin),@(TXClientCountType_Notice),@(TXClientCountType_LearnGarden),@(TXClientCountType_GardenPost),@(TXClientCountType_Approve),@(TXClientCountType_HomeWork)] refreshBlock:^(NSArray *values) {
    
    [self subscribeMultipleCountTypes:@[@(TXClientCountType_Notice),@(TXClientCountType_LearnGarden),@(TXClientCountType_HomeWork)] refreshBlock:^(NSArray *values) {
//        NSLog(@"订阅array:%@",values);
        if ([self isCanShowHomeUnreadCount]) {
            TXAsyncRunInMain(^{
                //处理消息的红点
                RDVTabBarItem *msgItem =  [[[self.viewController tabBar] items] objectAtIndex:0];
                /*先判断消息是否还有未读*/
                NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
                
                if (unReadNumber > 0) {
                    [msgItem setBadgeValue:@" "];
                    [msgItem layoutIfNeeded];
                }else{
                    for(NSDictionary *subDict in values)
                    {
                        NSNumber *countValue = subDict[TXClientCountNewValueKey];
                        if([countValue integerValue] > 0){
                            [msgItem setBadgeValue:@" "];
                            [msgItem layoutIfNeeded];
                            break;
                        }else{
                            [msgItem setBadgeValue:@""];
                            [msgItem layoutIfNeeded];
                        }
                    }
                }
                //判断是否已经有红点
                if ([msgItem.badgeValue isEqualToString:@""]) {
                    //还没有红点
                    if ([self isPostConversationHasNewData]) {
                        //读取微学园和园公众号的红点
                        [msgItem setBadgeValue:@" "];
                        [msgItem layoutIfNeeded];
                    }else if ([self isAttendanceConversationHasNewData]) {
                        //读取请假消息的红点
                        [msgItem setBadgeValue:@" "];
                        [msgItem layoutIfNeeded];
                    }else{
                        [msgItem setBadgeValue:@""];
                        [msgItem layoutIfNeeded];
                    }
                }
            });
        }
    } invokeNow:YES];
    //处理亲子圈的红点
    //[self subscribeMultipleCountTypes:@[@(TXClientCountType_Feed),@(TXClientCountType_FeedComment)]
    [self subscribeMultipleCountTypes:@[@(TXClientCountType_Feed),@(TXClientCountType_FeedComment),@(TXClientCountType_LearnGarden)] refreshBlock:^(NSArray *values) {
//        NSLog(@"亲子圈values:%@",values);
        if ([self isCanShowHomeUnreadCount]) {
            TXAsyncRunInMain(^{
                BOOL isShowBadge = NO;
                for(NSDictionary *subDict in values)
                {
                    NSNumber *countValue = subDict[TXClientCountNewValueKey];
                    if([countValue integerValue] > 0){
                        isShowBadge = YES;
                        break;
                    }
                }
                RDVTabBarItem *feedItem =  [[[self.viewController tabBar] items] objectAtIndex:2];
                if(isShowBadge){
                    [feedItem setBadgeValue:@" "];
                }else{
                    [feedItem setBadgeValue:@""];
                }
                [feedItem layoutIfNeeded];
            });
        }
    } invokeNow:YES];
    
    //---------------------------
    
    //modify sck
    NSMutableArray *types = [NSMutableArray arrayWithCapacity:1];
    NSArray *array = @[@{@"name":TX_PROFILE_KEY_OPTION_ANNOUNCEMENT, @"type":@(TXClientCountType_Announcement)},
                       @{@"name":TX_PROFILE_KEY_OPTION_ACTIVITY, @"type":@(TXClientCountType_Activity)},
                       @{@"name":TX_PROFILE_KEY_OPTION_RECIPES, @"type":@(TXClientCountType_Rest)},
                       @{@"name":TX_PROFILE_KEY_OPTION_MEDICINE, @"type":@(TXClientCountType_Medicine)},
                       @{@"name":TX_PROFILE_KEY_OPTION_CHECK_IN, @"type":@(TXClientCountType_Checkin)},
                       @{@"name":TX_PROFILE_KEY_OPTION_NOTICE, @"type":@(TXClientCountType_Notice)},@{@"name":TX_PROFILE_KEY_OPTION_HOMEWORK, @"type":@(TXClientCountType_HomeWork)}];
    NSArray *homeMenuList = nil;
    NSDictionary *userProfiles = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    NSString *homeMenuStr = nil;
    if(userProfiles != nil)
    {
        homeMenuStr = [userProfiles objectForKey:KHOMELIST];
    }
    if(homeMenuStr != nil)
    {
        homeMenuList = [homeMenuStr componentsSeparatedByString:@","];
    }
    if(homeMenuList != nil)
    {
        for(NSDictionary *index in array)
        {
            if([homeMenuList containsObject:[index objectForKey:@"name"]])
            {
                [types addObject:[index objectForKey:@"type"]];
            }
        }
    }
    //处理家园界面的红点
    [self subscribeMultipleCountTypes:types refreshBlock:^(NSArray *values) {
        if ([self isCanShowHomeUnreadCount]) {
            TXAsyncRunInMain(^{
                RDVTabBarItem *homeItem =  [[[self.viewController tabBar] items] objectAtIndex:1];
                for(NSDictionary *subDict in values)
                {
                    NSNumber *countValue = subDict[TXClientCountNewValueKey];
                    if([countValue integerValue] > 0){
                        [homeItem setBadgeValue:@" "];
                        [homeItem layoutIfNeeded];
                        break;
                    }else{
                        [homeItem setBadgeValue:@""];
                        [homeItem layoutIfNeeded];
                    }
                }
            });
        }
    } invokeNow:YES];
}

-(void)removeNotification
{
    [self unSubscribeAll];
}
- (BOOL)isCanShowHomeUnreadCount
{
    if(self.viewController == nil || [self.viewController tabBar] == nil
       || [[self.viewController tabBar]items] == nil || [[[self.viewController tabBar]items] count] < 2)
    {
        return NO;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
    
    [[TXChatClient sharedInstance].dataReportManager turnTimerOnOff:NO];
    [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeEnterBackground];
    [[TXChatClient sharedInstance].dataReportManager reportNow];
    //add by mey
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewApplicationDidEnterBackground" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
    
    [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeEnterForeground];
    [[TXChatClient sharedInstance].dataReportManager turnTimerOnOff:YES];
    [UMOnlineConfig updateOnlineConfigWithAppkey:UMENG_APPKEY];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WebViewApplicationWillEnterForeground" object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //添加从后台唤醒逻辑
    if (_isHasLaunched) {
        [[TXSystemManager sharedManager] fetchInfoWhenAppBecomeActive];
        [self checkUpdate];
    }
    if (!_isHasLaunched) {
        _isHasLaunched = YES;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[TXChatClient sharedInstance].dataReportManager reportNow];
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}
//注册deviceToken成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //    [[SystemSettingManager sharedSystemSettingManager] setDeviceToken:deviceToken];
    NSString *deviceTokenString = [[NSString alloc] initWithFormat:@"deviceTokenString %@", deviceToken];
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
//    [UMessage registerDeviceToken:deviceToken];

    DDLogDebug(@"%@",[NSString stringWithFormat:@"注册环信devicetoken成功%@",deviceTokenString]);
    
//信鸽推送
//    void (^successBlock)(void) = ^(void){
//        //成功之后的处理
//        DDLogDebug(@"[XGPush]register successBlock");
//    };
//    
//    void (^errorBlock)(void) = ^(void){
//        //失败之后的处理
//        DDLogDebug(@"[XGPush]register errorBlock");
//    };
    
    //注册设备
//    [[XGSetting getInstance] setChannel:@"appstore"];
    
//    NSString * deviceTokenStr = [XGPush registerDevice:deviceToken successCallback:successBlock errorCallback:errorBlock];

    NSString *deviceTokenStr = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    DDLogDebug(@"umeng:%@",deviceTokenStr);
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if(currentUser != nil)
    {
        [[TXRequestHelper shareInstance] updateDeviceTokenToServer:deviceTokenStr];        
    }
    DDLogDebug(@"UMENGDeviceToken:%@",deviceTokenStr);
    [USER_DEFAULT setObject:deviceTokenStr forKey:KDeviceTokenKey];
    [UMessage registerDeviceToken:deviceToken];

}


// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    DDLogDebug(@"获取devicetoken失败:%@",error);
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    //推送反馈(app运行时)
    [XGPush handleReceiveNotification:userInfo];
    
    
    //回调版本示例
    /*
     void (^successBlock)(void) = ^(void){
     //成功之后的处理
     NSLog(@"[XGPush]handleReceiveNotification successBlock");
     };
     
     void (^errorBlock)(void) = ^(void){
     //失败之后的处理
     NSLog(@"[XGPush]handleReceiveNotification errorBlock");
     };
     
     void (^completion )(void) = ^(void){
     //失败之后的处理
     NSLog(@"[xg push completion]userInfo is %@",userInfo);
     };
     
     [XGPush handleReceiveNotification:userInfo successCallback:successBlock errorCallback:errorBlock completion:completion];
     */
    
    [self handleReceiveRemoteNotification:userInfo];
}

-(void)handleReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSInteger type = [[userInfo objectForKey:@"pushType"] intValue];
    DLog(@"pushType:%@", @(type));
    switch (type) {
        case TXPBPushTypeNotice:
        {
            [[TXNoticeManager shareInstance] asyncNewsNotices];
            [[TXChatClient sharedInstance] fetchCounters:^(NSError *error, NSMutableDictionary *countersDictionary) {
                if(error)
                {
                    DDLogDebug(@"error:%@",error);
                }
            }];
        }
            break;
        case TXPBPushTypeCheckin:
        {
            [[TXCacheManage shareInstance] refreshCheckinDataSource];
        }
            break;
        case TXPBPushTypeGakuen:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_WXYNEWMSG object:nil userInfo:userInfo];
            });
        }
            break;
        case TXPBPushTypeMedicine:
        {

        }
            break;
        case TXPBPushTypePushLerngarden:
        {
            TXUser *current = [[TXChatClient sharedInstance] getCurrentUser:nil];
            if(current == nil)
            {
                return ;
            }
            WEAKSELF
            ButtonItem *cancel = [ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:^{
                
            } ];
            ButtonItem *confirm = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [weakSelf launchWithNotification:userInfo];
            } ];
            [self.window showAlertViewWithMessage:@"乐学堂有新内容，是否打开?" andButtonItems:cancel, confirm,nil];
        }
            break;
        case TXPBPushTypePushHomework: {
            break;
        }
            
        default:
            break;
    }
    
    
    

}

// 注册推送
- (void)registerEaseMobRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}
//版本检查
-(void)checkUpdate
{
    TXUser *current = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if(current == nil)
    {
        return ;
    }
    
    [[TXChatClient sharedInstance] upgrade:TXPBPlatformTypeIos onCompleted:^(NSError *error, TXPBUpgradeResponse *txpbUpgradeResponse) {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            NSString *lastVersion = (NSString *)[USER_DEFAULT objectForKey:KUPDATEVERSION];
            if(lastVersion != nil && [lastVersion containsString:txpbUpgradeResponse.upgrade.versionCode] && !txpbUpgradeResponse.upgrade.mustUpdate)
            {
                return;
            }
            if(txpbUpgradeResponse.upgrade.isUpdate)
            {
                if(txpbUpgradeResponse.upgrade.mustUpdate)
                {
                    ButtonItem *updateItem = [ButtonItem itemWithLabel:@"立即更新" andTextColor:kColorBlack action:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:txpbUpgradeResponse.upgrade.updateUrl]];
                        exit(0);
                    }];
                    [self.window showAlertViewWithMessage:txpbUpgradeResponse.upgrade.showMsg andButtonItems:updateItem, nil];
                }
                else
                {
                    ButtonItem *nextItem = [ButtonItem itemWithLabel:@"不了,下次" andTextColor:kColorBlack action:^{
                        [USER_DEFAULT setObject:[NSString stringWithFormat:@"%@", txpbUpgradeResponse.upgrade.versionCode] forKey:KUPDATEVERSION];
                    }];
                    ButtonItem *updateItem = [ButtonItem itemWithLabel:@"立即更新" andTextColor:kColorBlack action:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:txpbUpgradeResponse.upgrade.updateUrl]];
                        exit(0);
                    }];
                    [self.window showAlertViewWithMessage:txpbUpgradeResponse.upgrade.showMsg andButtonItems:nextItem,updateItem, nil];
                }
            }
        }
    }];

}


//收到微豆动画
-(void)registerWeiDouNotification
{
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WeiDouAwarded:) name:TX_NOTIFICATION_WEI_DOU_AWARDED object:nil];
}

-(void)WeiDouAwarded:(NSNotification *)notification
{
//    NSNumber *number = (NSNumber *)notification.object;
//    if(number == nil)
//    {
//        return;
//    }
//    TXAsyncRunInMain(^{
//        [[ShowWeiDou sharedManager] showRcvWeiDou:number.integerValue];
//    });
}

//收到微豆动画
-(void)registerSignInNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signInAnimation:) name:TX_NOTIFICATION_WEI_DOU_AWARDED_BY_CHECK_IN object:nil];
}

-(void)signInAnimation:(NSNotification *)notification
{
    NSNumber *number = (NSNumber *)notification.object;
    if(number == nil)
    {
        return;
    }
    TXAsyncRunInMain(^{
        [[SignInAnimation sharedManager] showSignInAnimation:number.integerValue];
    });
}



@end
