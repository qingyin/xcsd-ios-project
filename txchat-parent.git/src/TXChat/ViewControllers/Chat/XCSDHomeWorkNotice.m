//
//  XCSDHomeWorkNotice.m
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "XCSDHomeWorkNotice.h"
#import "NSDate+TuXing.h"

@implementation XCSDHomeWorkNotice
//初始化会话Model
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.avatarImageName = @"conversation_mentalWork";
        self.displayName = @" 学能作业";
        NSString *senderName = dict[@"senderName"];
        if (senderName && [senderName length]) {
            self.detailMsg = [NSString stringWithFormat:@"%@ %@",senderName,dict[@"lastMsg"]];
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
