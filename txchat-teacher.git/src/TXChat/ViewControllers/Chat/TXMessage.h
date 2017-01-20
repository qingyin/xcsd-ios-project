//
//  TXMessage.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXMessageModelData.h"
#import <YYText.h>

@interface TXMessage : NSObject<TXMessageModelData>

//消息发送者的id
@property (nonatomic,copy) NSString *userId;
//消息id
@property (nonatomic,copy) NSString *messageId;
//发送的文本
@property (nonatomic,copy) NSString *text;
//头像image
@property (nonatomic,strong) UIImage *avatarImage;
//头像url
@property (nonatomic,copy) NSString *avatarUrlString;
//接收还是发送
@property (nonatomic) TXBubbleMessageType bubbleMessageType;
//消息内容类型
@property (nonatomic) TXBubbleMessageMediaType messageMediaType;
//发送者的名称
@property (nonatomic,copy) NSString *senderName;
//时间字符串
@property (nonatomic,copy) NSString *time;
//是否已读
@property (nonatomic) BOOL isVoiceRead;
//是否是时间类型的消息，如果是的话，显示在中间位置
@property (nonatomic) BOOL isTimeMessage;
//提前计算好高度并缓存
@property (nonatomic) CGFloat rowHeight;
//环信消息message
@property (nonatomic, strong)EMMessage *message;
//图片消息大小
@property (nonatomic) CGSize imageSize;
//图片缩略图大小
@property (nonatomic) CGSize thumbnailImageSize;
//图片本地地址
@property (nonatomic,copy) NSString *imageLocalPath;
//缩略图本地地址
@property (nonatomic,copy) NSString *thumbnailImageLocalPath;
//图片远端地址
@property (nonatomic,copy) NSString *imageRemoteURL;
//文本大小
@property (nonatomic) CGSize textSize;
//是否是群聊
@property (nonatomic) BOOL isGroupChat;
//语音
@property (nonatomic, copy) NSString *voicelocalPath;
@property (nonatomic, copy) NSString *voiceRemotePath;
@property (nonatomic) NSInteger voiceTime;
@property (nonatomic) CGFloat voiceBubbleLength;
@property (nonatomic, strong) EMChatVoice *chatVoice;
@property (nonatomic) BOOL isVoicePlaying;
@property (nonatomic) BOOL isVoicePlayed;
//发送状态
@property (nonatomic) MessageDeliveryState status;
//是否是tip消息
@property (nonatomic) BOOL isTipMessage;
@property (nonatomic,copy) NSString *tipMessage;
//视频消息
@property (nonatomic) CGSize videoSize;
@property (nonatomic) CGSize videoThumbSize;
@property (nonatomic,copy) NSString *videoLocalThumbnailImageURL;
@property (nonatomic,copy) NSString *videoRemoteThumbnailImageURL;
@property (nonatomic,copy) NSString *videoLocalPath;
@property (nonatomic,copy) NSString *videoRemoteURL;
//文本排版
@property (nonatomic,strong) YYTextLayout *textLayout;
@property (nonatomic,assign) CGFloat textFixedLineHeight;

@property (nonatomic, assign) BOOL isShare;

@property (nonatomic, assign) BOOL isService;

@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareImageUrl;
@property (nonatomic, copy) NSString *shareUrl;


//初始化消息Model
- (instancetype)initBubbleMessageWithEMMessage:(EMMessage *)msg
                                   isGroupChat:(BOOL)isGroup;

@end
