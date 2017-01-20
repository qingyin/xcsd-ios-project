//
//  TXEaseMobHelper.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/14.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TXServerConnectedStatus) {
    TXServerConnectedNormalStatus,         //普通状态
    TXServerConnectedLoginedStatus,        //土星服务器已登录状态中
    TXServerConnectedLogoffStatus,         //土星服务器已登出状态中
};

typedef NS_ENUM(NSInteger, TXEaseMobLogoffType) {
    TXEaseMobNormalLogoffType,             //普通注销
    TXEaseMobUserLogoffType,               //用户手动注销
    TXEaseMobOtherDeviceLoginedType,       //其他设备登录
    TXEaseMobServerRemovedCountType,       //服务器删除了当前账号
    TXEaseMobNotRemindType,                //不提醒type
};

typedef NS_ENUM(NSInteger, TXEaseMobRefreshType) {
    TXEaseMobRefreshTypeNone = 0,          //无
    TXEaseMobRefreshNotifyType,            //刷新通知
    TXEaseMobRefreshChatListType,          //刷新聊天列表
    TXEaseMobRefreshSwipeCardType,         //刷新刷卡列表
    TXEaseMobRefreshNetworkChangeType,     //网络状况变化
    TXEaseMobRefreshLoginStatusType,       //登录状态变化
    TXEaseMobRefreshCMDMessageType,        //新的CMD消息
};

typedef NS_ENUM(NSInteger, TXCMDMessageType) {
    TXCMDMessageType_None = 0,            //其他
    TXCMDMessageType_UnBindUser,          //解绑了用户
    TXCMDMessageType_ProfileChange,       //用户资料变更
    TXCMDMessageType_GagUser,             //某个用户被禁言
    TXCMDMessageType_RevokeMessage,       //撤回消息
    TXCMDMessageType_NewCheckInVoice,     //新的刷卡语音
};

typedef void(^TXEaseMobAutoLoginBlock)(NSDictionary *loginInfo, EMError *error);
typedef void(^TXEaseMobLogoffBlock)(NSDictionary *info, EMError *error,TXEaseMobLogoffType type);
extern NSString *const EaseMobAllGroupMembersUpdateNotification;


@protocol TXEaseMobMessageDelegate <NSObject>

//接收到发送消息的回调
-(void)didSendMessage:(EMMessage *)message error:(EMError *)error;

- (void)didReceiveHasReadResponse:(EMReceipt*)receipt;

//消息附件状态更新
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error;

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress;

//接收到消息
-(void)didReceiveMessage:(EMMessage *)message;

//接收到离线消息
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages;

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error;

- (void)didInterruptionRecordAudio;

//会话列表信息刷新
- (void)didUpdateConversationList;

//撤回了消息
- (void)didRevokeMessageIds:(NSArray *)messageIds
                       from:(NSString *)from
                         to:(NSString *)to
                    isGroup:(BOOL)isGroup;

@end

@interface TXEaseMobHelper : NSObject

//土星服务器在线状态值
@property (nonatomic,assign) TXServerConnectedStatus connectStatus;
@property (nonatomic,copy) TXEaseMobLogoffBlock logoffBlock;

//单例
+ (instancetype)sharedHelper;

//登录环信服务器
- (void)autoLoginEaseMobServerWithUserName:(NSString *)userName
                                  password:(NSString *)password
                                completion:(TXEaseMobAutoLoginBlock)block;

//登录到环信服务器
- (void)startAsynLoginToEaseMobServerWithUserId:(NSString *)userId
                                       password:(NSString *)password;

//手动注销环信服务器
- (void)logOffFromEaseMobServerWithUnbindDeviceToken:(BOOL)isUnbind
                                          logoffType:(TXEaseMobLogoffType)logoffType
                                          completion:(TXEaseMobLogoffBlock)block;

//ping完土星server后登陆服务器
- (void)loginAfterPingTXServerWithUserName:(NSString *)userName
                                  password:(NSString *)password;

//监听注销事件,暂时只支持一个对象监听（应该没有两个对象同时监听的需求）
- (void)observeLogOffEventWithBlock:(TXEaseMobLogoffBlock)block;

//添加环信刷新的回调
- (void)addEaseMobRefreshObserver:(id)observer selector:(SEL)selector type:(TXEaseMobRefreshType)type;

//移除环信刷新监听者,如果不指定type，默认移除所有observer下的所有监听类型
- (void)removeEaseMobRefreshObserver:(id)observer type:(TXEaseMobRefreshType)type;

//移除环信刷新监听者
- (void)removeEaseMobRefreshObserver:(id)observer;

//删除跟某个人或者群组的聊天会话
- (void)removeConversationByChatter:(NSString *)chatter
                      deleteMessage:(BOOL)isDelete;

//删除所有的会话
- (void)removeAllConversations;

//通知外部去获取新的通知
- (void)notifyObserversToFetchNewNotify;

//通知观察者刷新环信列表
- (void)notifyObserverRefreshChatList;

//从数据库移除空的会话
- (void)removeEmptyConversationsFromDB;

//添加消息监听代理
- (void)addMessageDelegate:(id<TXEaseMobMessageDelegate>)delegate;

//移除消息监听代理
- (void)removeMessageDelegate:(id<TXEaseMobMessageDelegate>)delegate;

/**
 *  设置群免打扰
 *
 *  @param groupId 环信群id
 *  @param isOpen  是否打开,YES为打开群免打扰状态，NO为关闭群免打扰状态
 *  @param completionBlock  block回调
 */
- (void)ignoreGroupDisturbWithId:(NSString *)groupId
                   disturbStatus:(BOOL)isOpen
                      completion:(void(^)(BOOL isSuccess))completionBlock;

/**
 *  获取群免打扰状态
 *
 *  @param groupId 环信群id
 *
 *  @return 群免打扰状态Value
 */
- (BOOL)groupNoDisturbStatusWithId:(NSString *)groupId;

/**
 *  发送CMD消息到群组
 *
 *  @param type    cmd消息类型
 */
- (void)sendCMDMessageWithType:(TXCMDMessageType)type;

//发送撤回消息
- (void)sendRevokeMessageCommandWithReceiver:(NSString *)receiver
                                     isGroup:(BOOL)isGroup
                                   messageId:(NSString *)messageId
                                        from:(NSString *)fromUserId;

//修改密码后重新登录
- (void)reLoginWhenChangePassword;

//判断用户是否存在
- (BOOL)checkIsStillExistUser:(NSString *)userId;

@end
