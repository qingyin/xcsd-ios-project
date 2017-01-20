//
//  TXChatSwipeCardConversation.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatSwipeCardConversation.h"
#import "NSDate+TuXing.h"

@implementation TXChatSwipeCardConversation

//初始化会话Model
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.avatarImageName = @"conversation_safe";
        self.displayName = @"云卫士提醒";
        self.detailMsg = dict[@"lastMsg"];
        self.timeStamp = [dict[@"time"] longLongValue];
        self.time = [NSDate timeForChatListStyle:dict[@"time"]];
        self.unReadCount = [dict[@"unreadNumbe"] integerValue];
    }
    return self;
}
//是否允许展示未读数
- (BOOL)isEnableUnreadCountDisplay
{
    return NO;
}
//是否允许展示红点
- (BOOL)isEnableShowRedDot
{
    return YES;
}
@end
