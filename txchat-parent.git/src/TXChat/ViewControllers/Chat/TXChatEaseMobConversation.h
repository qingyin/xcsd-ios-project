//
//  TXChatEaseMobConversation.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatConversation.h"

@class EMConversation;
@interface TXChatEaseMobConversation : TXChatConversation

@property (nonatomic,strong) EMConversation *emConversation;

- (instancetype)initWithEMConversation:(EMConversation *)conversation;

- (instancetype)initWithGroupId:(NSString *)groupId;

//最后一条聊天的消息
+ (EMMessage *)lastChatMessageForConversation:(EMConversation *)conversation;

@end
