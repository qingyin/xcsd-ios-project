//
//  BuglySDKHelper.m
//  BuglySDKDemo
//
//  Created by mqq on 15/1/26.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "BuglySDKHelper.h"
#



@implementation BuglySDKHelper

+ (void)initSDK {

    // --- init for Bugly.framework ---
    // 调试阶段开启sdk日志打印, 发布阶段请务必关闭
#if DEBUG == 1
    [[CrashReporter sharedInstance] enableLog:YES];
#endif
    //启用卡顿监控
    [[CrashReporter sharedInstance] enableBlockMonitor:YES autoReport:YES];
    // SDK默认采用BundleShortVersion(BundleVersion)的格式作为版本,如果你的应用版本不是采用这样的格式，你可以通过此接口设置
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [[CrashReporter sharedInstance] setBundleVer:app_Version];
    //启用卡顿监控
    [[CrashReporter sharedInstance] enableBlockMonitor:YES autoReport:YES];
    
    // 如果你的App有对应的发布渠道(如AppStore),你可以通过此接口设置, 默认值为unknown,
#if DEBUG == 1
    [[CrashReporter sharedInstance] setChannel:@"测试"];
#else
    [[CrashReporter sharedInstance] setChannel:@"生产"];
#endif
    
    // 你可以在初始化之前设置本地保存的用户身份, 也可以在用户身份切换后调用此接口即时修改
//    [[CrashReporter sharedInstance] setUserId:[NSString stringWithFormat:@"测试用户:%@", @"tester"]];

    // 如果应用有自定义的设备标识、可以调用此接口设置, SDK默认通过UDID标识设备
    // [[CrashReporter sharedInstance] setDeviceId:@""];
    
    // 使用AppID初始化SDK
    if (![BUGLY_APP_ID isEqualToString:@""]) {
        [[CrashReporter sharedInstance] installWithAppId:BUGLY_APP_ID];
    } else {
        NSLog(@"Please input a valid App ID from Bugly");
    }
    // ------
    // 注意: 在调试SDK的捕获上报功能时，请注意以下内容:
    // 1. Xcode断开编译器，否则Xcode编译器会拦截应用错误信号，让应用进程挂起，方便开发者调试定位问题。此时，SDK无法顺利进行崩溃的错误上报
    // 2. 请关闭项目存在第三方捕获工具，否则会相互产生影响。因为崩溃捕获的机制一致，系统只会保持一个注册的崩溃处理函数
    // ------
    
    // --- end ---
}

/**
 *    @brief  崩溃发生时的回调处理函数, 开发者可以在这里获取崩溃信息, 并为崩溃信息添加附带信息上报
 *
 *    @return value could be ignore
 */
static int exception_callback_handler_test() {
    NSLog(@"enter the exception callback");
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
//    [[CrashReporter sharedInstance] setUserData:@"测试用户" value:[NSString stringWithFormat:@"Bugly用户测试:%@", BUGLY_APP_ID]];
    
    // 你可以通过次接口添加附件信息同崩溃信息一起上报
//    [[CrashReporter sharedInstance] setAttachLog:@"使用Bugly进行崩溃问题跟踪定位"];
    
    DDLogDebug(@"appcrash");
    
    return 1;
}




+ (void)setExceptionCallback:(exp_callback)_callback {
    if (_callback <= 0) {
        NSLog(@"please set valid callback method %lli", (long long)_callback);

#if DEBUG == 1
        NSLog(@"set callback method for test");
        exp_call_back_func = &exception_callback_handler_test;
#endif
    } else {
        exp_call_back_func = _callback;
    }

    NSLog(@"sdk has set callback method: %lli", (long long)exp_call_back_func);
    DDLogDebug(@"appcrash");
}

+ (void)reportException:(NSException *) anException withMessage:(NSString *) aMessage {
    [[CrashReporter sharedInstance] reportException:anException message:aMessage];
}

/**
 *    @brief  讲解引用其他SDK的项目都初始化注意事项
 */
- (void)init3rdSDKs {
    // --- init for Umeng sdk ---
    //    // 你需要在初始化之前关闭umeng的crash上报功能
    //    [MobClick setCrashReportEnabled:NO];

    //    [MobClick startWithAppkey:@"" reportPolicy:BATCH channelId:@"ch_umeng"];
    // --- end ---

    // --- init for TD sdk ---
    //     // 你需要在初始化之前关闭talkingdata的crash上报功能
    //    [TalkingData setExceptionReportEnabled:NO];
    //    [TalkingData setSignalReportEnabled:NO];

    //    [TalkingData sessionStarted:@"" withChannelId:@"ch_talkingdata"];
    //    [TalkingData setLogEnabled:YES];
    // --- end ---

    // --- others ---
    //  其他的SDK如果也有崩溃上报的功能, 请确认是否默认开启, 如果是默认开启, 请调用API接口关闭其崩溃上报功能。否则会导致多个SDK的崩溃上报功能产生冲突,从而影响崩溃问题的采集上报
    //
    // --- end
}

@end