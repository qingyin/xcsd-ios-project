//
//  TXMessageModelData.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/5.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMob.h>
#import <YYText.h>

typedef NS_ENUM(NSInteger, TXBubbleMessageType) {
    TXBubbleMessageTypeOutgoing = 0,       //发送
    TXBubbleMessageTypeIncoming            //接收
};

typedef NS_ENUM(NSInteger, TXBubbleMessageMediaType) {
    TXBubbleMessageMediaTypeText,         //文字
    TXBubbleMessageMediaTypePhoto,        //图片
    TXBubbleMessageMediaTypeVoice,        //语音
    TXBubbleMessageMediaTypeEmotion,      //表情
    TXBubbleMessageMediaTypeVideo,        //视频
};

@protocol TXMessageModelData <NSObject>

@required
//消息的发送者id
- (NSString *)userId;
//发送的文本
- (NSString *)text;
//头像image
- (UIImage *)avatarImage;
//头像url
- (NSString *)avatarUrlString;
//接收还是发送
- (TXBubbleMessageType)bubbleMessageType;
//消息内容类型
- (TXBubbleMessageMediaType)messageMediaType;
//是否是时间类型的消息，如果是的话，显示在中间位置
- (BOOL)isTimeMessage;
//获取高度
- (CGFloat)rowHeight;
//环信消息体
- (EMMessage *)message;
//是否是群聊
- (BOOL)isGroupChat;

- (BOOL)isShare;

- (BOOL)isService;

- (NSString *)shareTitle;

- (NSString *)shareImageUrl;

- (NSString *)shareUrl;

@optional
//是否发送状态
- (MessageDeliveryState)status;
//设置发送状态
- (void)setStatus:(MessageDeliveryState)status;

//发送者的名称
- (NSString *)senderName;
//时间字符串
- (NSString *)time;
//是否已读
- (BOOL)isVoiceRead;
//设置是否已读
- (void)setIsVoiceRead:(BOOL)isRead;
//图片消息大小
- (CGSize)imageSize;
//图片缩略图大小
- (CGSize)thumbnailImageSize;
//图片本地地址
- (NSString *)imageLocalPath;
//缩略图本地地址
- (NSString *)thumbnailImageLocalPath;
//图片远端地址
- (NSString *)imageRemoteURL;
//文本大小
- (CGSize)textSize;
//语音
- (NSString *)voicelocalPath;
- (NSString *)voiceRemotePath;
- (NSInteger)voiceTime;
- (CGFloat)voiceBubbleLength;
- (BOOL)isVoicePlaying;
- (void)setIsVoicePlaying:(BOOL)isVoicePlaying;
- (BOOL)isVoicePlayed;
- (void)setIsVoicePlayed:(BOOL)isVoicePlayed;
- (EMChatVoice *)chatVoice;
//tip提示
- (BOOL)isTipMessage;
- (NSString *)tipMessage;
//视频
- (CGSize)videoSize;
- (CGSize)videoThumbSize;
- (NSString *)videoLocalThumbnailImageURL;
- (NSString *)videoRemoteThumbnailImageURL;
- (NSString *)videoLocalPath;
- (NSString *)videoRemoteURL;
//文本的排版layout
- (YYTextLayout *)textLayout;
//文本矫正的行高
- (CGFloat)textFixedLineHeight;

@end
