//
//  AppDelegate+EaseMob.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "AppDelegate+EaseMob.h"
#import "TXSystemManager.h"

@implementation AppDelegate (EaseMob)

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *apnsCertName = nil;
    NSString *emAppKey;
    BOOL isEnableConsoleLogger = YES;
    if ([TXSystemManager sharedManager].isDevVersion) {
#if DEBUG
        apnsCertName = @"wjy_parent_dev";
#else
        apnsCertName = @"wjy_parent_adhoc";
#endif
        emAppKey = [[TXSystemManager sharedManager] easeMobAppKey];
    }else{
        apnsCertName = @"wjy_parent_adhoc";
		emAppKey = KHuanXin_AppKey_Dis;
    }
	
#if DEV_TEST
	apnsCertName = @"wjy_parent_dev";
	emAppKey = KHuanXin_AppKey_Dev;
#else
	apnsCertName = @"wjy_parent_adhoc";
	emAppKey = KHuanXin_AppKey_Dis;
#endif
	
    [[EaseMob sharedInstance] registerSDKWithAppKey:emAppKey apnsCertName:apnsCertName otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:isEnableConsoleLogger]}];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
