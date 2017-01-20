//
//  BuglySDKHelper.h
//  BuglySDKDemo
//
//  Created by mqq on 15/1/26.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//
#import <Foundation/Foundation.h>


#import <Bugly/CrashReporter.h>


@interface BuglySDKHelper : NSObject

/**
 *    @brief  初始化SDK并进行App的基础信息设置, 比如：版本、渠道、用户身份标识等
 */
+ (void)initSDK;

/**
 *    @brief  设置崩溃处理回调函数, 开发者可以在回调函数中获取崩溃信息或为崩溃信息添加附加信息上报
 *
 *    @param _callback 崩溃处理回调函数的地址
 */
+ (void)setExceptionCallback:(exp_callback) _callback;

/**
 *  @brief 主动上报捕获的异常
 *
 *  @param anException <#anException description#>
 *  @param aMessage    <#aMessage description#>
 */
+ (void)reportException:(NSException *) anException withMessage:(NSString *) aMessage;

@end