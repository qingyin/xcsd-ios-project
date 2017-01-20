//
//  TXChatNotifyConversation.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatNotifyConversation.h"
#import "NSDate+TuXing.h"

@implementation TXChatNotifyConversation

//初始化会话Model
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.avatarImageName = @"conversation_notify";
        self.displayName = @"通知";
        NSString *senderName = dict[@"senderName"];
        if (senderName && [senderName length]) {
            self.detailMsg = [NSString stringWithFormat:@"%@:%@",senderName,dict[@"lastMsg"]];
        }else{
            self.detailMsg = dict[@"lastMsg"];
        }
        self.timeStamp = [dict[@"time"] longLongValue];
        self.time = [NSDate timeForChatListStyle:dict[@"time"]];
        self.unReadCount = [dict[@"unreadNumbe"] integerValue];
    }
    return self;
}
//是否允许展示未读数
- (BOOL)isEnableUnreadCountDisplay
{
    return YES;
}
//是否允许展示红点
- (BOOL)isEnableShowRedDot
{
    return YES;
}
@end
