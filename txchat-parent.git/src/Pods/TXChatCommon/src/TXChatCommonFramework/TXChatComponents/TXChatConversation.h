//
//  TXChatConversation.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatConversationData.h"

typedef NS_ENUM(NSInteger, TXChatConversationType) {
    TXChatConversationTypeChat,              //单聊会话
    TXChatConversationTypeGroupChat,         //群聊会话
    TXChatConversationTypeNotify,            //通知
    TXChatConversationTypeSwipeCard          //刷卡
};

//会话基类
@interface TXChatConversation : NSObject <TXChatConversationData>

/**
 *  会话id
 */
@property (nonatomic,copy) NSString *conversationId;

/**
 *  会话cell中图片的远程地址
 */
@property (nonatomic,copy) NSString *avatarRemoteUrlString;

/**
 *  会话Cell中图片的名称
 */
@property (nonatomic,copy) NSString *avatarImageName;

/**
 *  会话的标题名称
 */
@property (nonatomic,copy) NSString *displayName;

/**
 *  会话的具体消息内容
 */
@property (nonatomic,copy) NSString *detailMsg;

/**
 *  会话的时间
 */
@property (nonatomic,copy) NSString *time;

/**
 *  时间戳
 */
@property (nonatomic) long long timeStamp;

/**
 *  会话类型
 */
@property (nonatomic) TXChatConversationType type;

/**
 *  是否允许展示未读数标示，默认为YES
 */
@property (nonatomic) BOOL isEnableUnreadCountDisplay;

//是否允许展示红点
@property (nonatomic) BOOL isEnableShowRedDot;

/**
 *  未读数
 */
@property (nonatomic) NSInteger unReadCount;

@property (nonatomic, assign) BOOL isService;

/**
 *  初始化会话Model
 *
 *  @param dict 会话信息
 *
 *  @return 会话Model
 */
- (instancetype)initWithConversationAttributes:(NSDictionary *)dict;


@end
