//
//  AppDelegate+EaseMob.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "AppDelegate.h"
#import "IChatManagerDelegate.h"

@interface AppDelegate (EaseMob)
<IChatManagerDelegate>

- (void)easemobApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
