//
//  TXChatConversationData.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TXChatConversationData <NSObject>

@required
//图片远程地址
- (NSString *)avatarRemoteUrlString;
//图片名称
- (NSString *)avatarImageName;
//标题名称
- (NSString *)displayName;
//具体内容
- (NSString *)detailMsg;
//时间
- (NSString *)time;

- (BOOL)isService;

//时间戳
- (long long)timeStamp;
//未读数,展示优先级小于enableUnreadCountDisplay属性
- (NSInteger)unReadCount;
//是否允许展示未读数
- (BOOL)isEnableUnreadCountDisplay;
//是否允许展示红点
- (BOOL)isEnableShowRedDot;

@end
