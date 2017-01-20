//
//  TXChatJSBConversation.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/10.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXChatJSBConversation.h"
#import "NSDate+TuXing.h"

@implementation TXChatJSBConversation

//初始化会话Model
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.avatarImageName = @"conversation_jsb";
        self.displayName = @"教师社区";
        self.detailMsg = dict[@"lastMsg"];
        self.timeStamp = [dict[@"time"] longLongValue];
        if (self.timeStamp == 0) {
            self.time = @"";
        }else{
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
