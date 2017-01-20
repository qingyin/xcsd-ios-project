//
//  TXChatGardenSubConversation.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/3.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXChatGardenSubConversation.h"
#import "NSDate+TuXing.h"

@implementation TXChatGardenSubConversation

//初始化会话Model
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.avatarImageName = @"conversation_garden";
        self.displayName = @"";
        TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
        if (currentUser && currentUser.gardenName && [currentUser.gardenName length]) {
            self.displayName = currentUser.gardenName;
        }
        self.displayName = [self.displayName stringByAppendingString:@"公众号"];
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
