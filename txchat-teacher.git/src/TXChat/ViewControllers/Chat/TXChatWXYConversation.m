//
//  TXChatWXYConversation.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXChatWXYConversation.h"
#import "NSDate+TuXing.h"

@implementation TXChatWXYConversation

//初始化会话Model
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.avatarImageName = @"conversation_wxy";
        self.displayName = @"理解孩子";
        self.detailMsg = dict[@"lastMsg"];
        if ([[dict allKeys] containsObject:@"time"]) {
            self.timeStamp = [dict[@"time"] longLongValue];
            self.time = [NSDate timeForChatListStyle:dict[@"time"]];
        }
        self.unReadCount = [dict[@"unreadNumbe"] integerValue];
    }
    return self;
}
//是否允许展示未读数
- (BOOL)isEnableUnreadCountDisplay
{
    return NO;
}
//是否允许未读数为0时展示红点
- (BOOL)isEnableShowRedDot
{
    return YES;
}
@end
