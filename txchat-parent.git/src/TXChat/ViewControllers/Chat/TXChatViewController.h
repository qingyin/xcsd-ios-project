//
//  TXChatViewController.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXMessageModelData.h"
#import "TXMessageTableView.h"
#import "BaseViewController.h"
#import "TXMessageInputView.h"

@protocol TXChatTableViewControllerDataSource <NSObject>

@required
- (NSInteger)numberOfMessages;
- (id <TXMessageModelData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
//是否禁言
- (BOOL)isForbiddenSpeak;

@optional

@end

@protocol TXChatTableViewControllerDelegate <NSObject>

@required
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
//展示禁止发言的HUD
- (void)showForbiddenSpeakTipHUD;

@end

@interface TXChatViewController : BaseViewController

@property (nonatomic, strong) EMConversation *conversation;//会话管理者
@property (nonatomic) BOOL isGroup;
@property (nonatomic, strong) TXMessageTableView *messageTableView;
@property (nonatomic, strong) TXMessageInputView *msgInputView;
@property (nonatomic, weak) id<TXChatTableViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<TXChatTableViewControllerDelegate> delegate;
//是否正在加载更多旧的消息数据
@property (nonatomic, assign) BOOL loadingMoreMessage;
//是否存在聊天用户
@property (nonatomic, getter=isExistChatUser) BOOL existChatUser;

//刷新并滚动到具体位置
- (void)reloadChatViewAndScrollToIndexPath:(NSIndexPath *)indexPath
                                  animated:(BOOL)animated
                                mustScroll:(BOOL)mustScroll;

//添加消息
-(void)addMessage:(EMMessage *)message;

//发送文本消息
- (void)sendTextMessage:(NSString *)textMessage;

- (void)sendImageMessage:(UIImage *)image;

- (void)sendVoiceMessage:(EMChatVoice *)voice;

- (void)sendVideoMessage:(EMChatVideo *)video;

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read;

- (BOOL)shouldMarkMessageAsRead:(EMMessage *)message read:(BOOL)read;

//点击头像的回调方法
- (void)clickAvatarWithUserId:(NSString *)userId;

//下拉加载更多功能
- (void)triggleMessageHeaderRefreshing;

//结束下拉加载刷新
- (void)endMessageHeaderRefreshing;

//隐藏头部的刷新控件
- (void)hideMessageHeaderRefreshingView;

//撤回消息
- (void)handleRevokeMessage:(id<TXMessageModelData>)data;

@end
