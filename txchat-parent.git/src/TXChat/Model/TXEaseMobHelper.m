//
//  TXEaseMobHelper.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/14.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXEaseMobHelper.h"
#import "TXSystemManager.h"
#import "TXChatSendHelper.h"
#import "TXContactManager.h"
#import <Reachability.h>
#import  <TXChatSDK/TXDeletedMessage.h>

static NSString *const kEMCachedGroupMembers = @"emCachedGroupMember";
static NSTimeInterval const kReconnectHeartBeatTimeInterval = 5;
static NSTimeInterval const kPingServerHeartBeatTimeInterval = 1;
NSString *const EaseMobAllGroupMembersUpdateNotification = @"emAllGroupMembersUpdateNotification";
static NSString *const kUnbindUserCMDString = @"unbindUser";
static NSString *const kProfileChangeCMDString = @"profileChange";
static NSString *const kGagUserCMDString = @"gagUser";
static NSString *const kRevokeMsgCMDString = @"revokeMsg";
static NSString *const kNewCheckinVoiceCMDString = @"checkinVoice";

@interface WeakReferenceObj : NSObject
@property (nonatomic, weak) id weakRef;
@end

@implementation WeakReferenceObj
+ (WeakReferenceObj *)weakReferenceWithObj:(id)obj{
    WeakReferenceObj *weakObj = [[WeakReferenceObj alloc] init];
    weakObj.weakRef = obj;
    return weakObj;
}
@end

static NSString *const kEaseMobObserverObject = @"observerObject";
static NSString *const kEaseMobObserverSelector = @"observerSelector";
static NSString *const kEaseMobObserverType = @"observerType";
static NSInteger const kEaseMobLogoffRetryTime = 10;

@interface TXEaseMobHelper()
<EMChatManagerDelegate>

@property (nonatomic,strong) NSDictionary *autoLoginDict;
@property (nonatomic,copy) TXEaseMobAutoLoginBlock autoLoginBlock;
@property (nonatomic,strong) NSMutableArray *observerList;
@property (nonatomic) NSInteger logoffRetryTime;
@property (nonatomic,strong) NSMutableArray *messageDelegates;
@property (nonatomic,strong) NSTimer *reconnectTimer;
@property (nonatomic,strong) NSMutableDictionary *cacheMemberDict;
@property (nonatomic,strong) NSMutableDictionary *conversationDict;
@property (nonatomic,strong) NSMutableDictionary *unhandledRevokeMsgDict;
@property (nonatomic,strong) NSTimer *pingServerTimer;
@property (nonatomic) BOOL isPingHandled;
@property (nonatomic) BOOL isPingRequesting;

@end

@implementation TXEaseMobHelper

#pragma mark - 生命周期
- (void)dealloc{
    _observerList = nil;
    _messageDelegates = nil;
    [self unRegisterEaseMobDelegate];
}
//单例
+ (instancetype)sharedHelper
{
    static TXEaseMobHelper *_helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[self alloc] init];
    });
    return _helper;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerEaseMobDelegate];
        _observerList = [[NSMutableArray alloc] init];
        _messageDelegates = [[NSMutableArray alloc] init];
        _conversationDict = [[NSMutableDictionary alloc] init];
        [self setupUnHandledRevokeMessages];
        _logoffRetryTime = 0;
//        [self initializeCacheMemberDict];
        _connectStatus = TXServerConnectedLoginedStatus;
    }
    return self;
}
//处理未处理的撤回消息
- (void)setupUnHandledRevokeMessages
{
    _unhandledRevokeMsgDict = [[NSMutableDictionary alloc] init];
    NSArray *list = [[TXChatClient sharedInstance].deletedMessageManager queryAllDeletedMessage];
    [list enumerateObjectsUsingBlock:^(TXDeletedMessage *obj, NSUInteger idx, BOOL *stop) {
        NSString *msgId = obj.msgId;
        [_unhandledRevokeMsgDict setValue:obj forKey:msgId];
    }];
    NSArray *keysArray = [_unhandledRevokeMsgDict allKeys];
    [keysArray enumerateObjectsUsingBlock:^(NSString *msgId, NSUInteger idx, BOOL *stop) {
        TXDeletedMessage *txDeleteMsg = [_unhandledRevokeMsgDict valueForKey:msgId];
        [self deleteEaseMobMessageWithMessageId:txDeleteMsg.msgId cmdMsgId:txDeleteMsg.cmdMsgId from:txDeleteMsg.fromUserId to:txDeleteMsg.toUserId isGroup:txDeleteMsg.isGroup isAddUnHandledMsgToLocalList:NO];
    }];
}
#pragma mark - 代理注册+解除
// 向sdk中注册回调
- (void)registerEaseMobDelegate{
    // 此处先取消一次，是为了保证只将self注册过一次回调。
    [self unRegisterEaseMobDelegate];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}
// 取消sdk中注册的回调
- (void)unRegisterEaseMobDelegate{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}
#pragma mark - 登录+注销
//开启timer
- (void)startReconnectTimer
{
    if (_reconnectTimer) {
        [self stopReconnectTimer];
    }
    _reconnectTimer = [NSTimer timerWithTimeInterval:kReconnectHeartBeatTimeInterval target:self selector:@selector(reConnectToEaseMobWhenHeartBeatTimeScheduled) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_reconnectTimer forMode:NSRunLoopCommonModes];
}
//关闭timer
- (void)stopReconnectTimer
{
    [_reconnectTimer invalidate];
    _reconnectTimer = nil;
}
//开启timer
- (void)startPingServerTimerWithUserInfo:(NSDictionary *)userInfo
{
    if (_pingServerTimer) {
        [self stopPingServerTimer];
    }
    _isPingHandled = YES;
    _pingServerTimer = [NSTimer timerWithTimeInterval:kPingServerHeartBeatTimeInterval target:self selector:@selector(pingServerTimerScheduled:) userInfo:userInfo repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_pingServerTimer forMode:NSRunLoopCommonModes];
}
//关闭timer
- (void)stopPingServerTimer
{
    [_pingServerTimer invalidate];
    _pingServerTimer = nil;
}
//ping服务器的timer响应
- (void)pingServerTimerScheduled:(NSTimer *)timer
{
    //    NSLog(@"userInfo是:%@",timer.userInfo);
    NSString *userName = timer.userInfo[@"userName"];
    NSString *password = timer.userInfo[@"password"];
    [self loginAfterPingTXServerWithUserName:userName password:password];
}
//自动重连环信
- (void)reConnectToEaseMobWhenHeartBeatTimeScheduled
{
    DDLogDebug(@"重连环信timer fired");
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    BOOL isLoggedIn = [[EaseMob sharedInstance].chatManager isLoggedIn];
    if (reach.isReachable && !isLoggedIn) {
        //登录环信server
        DDLogDebug(@"尝试重连环信");
        dispatch_async(dispatch_get_main_queue(), ^{
            //发送开始连接的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
        });
        NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:kEaseMobUserName];
        NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:kLocalPassword];
        [self startAsynLoginToEaseMobServerWithUserId:userName password:password];
    }else{
        DDLogDebug(@"网络无连接，重连环信失败");
    }
}
//登录环信服务器
- (void)autoLoginEaseMobServerWithUserName:(NSString *)userName
                                  password:(NSString *)password
                                completion:(TXEaseMobAutoLoginBlock)block
{
    self.autoLoginBlock = block;
    //判断是否是登陆状态
    BOOL isLoggedIn = [[EaseMob sharedInstance].chatManager isLoggedIn];
    if (isLoggedIn) {
        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
            [self loginEaseMobServerWithUserName:userName password:password];
        } onQueue:nil];
    }else{
        [self loginEaseMobServerWithUserName:userName password:password];
    }
}
- (void)loginEaseMobServerWithUserName:(NSString *)userName password:(NSString *)password
{
    //判断是否自动登录
    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
    if (!isAutoLogin) {
        [self startAsynLoginToEaseMobServerWithUserId:userName password:password];
    }else{
        //Block返回数据
        if (self.autoLoginDict) {
            self.autoLoginBlock(self.autoLoginDict,nil);
            self.autoLoginBlock = nil;
            self.autoLoginDict = nil;
        }
        //通知外部刷新环信消息
        [self notifyObserverRefreshChatList];
        //获取群组列表
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
    }

}
//登录到环信服务器
- (void)startAsynLoginToEaseMobServerWithUserId:(NSString *)userId
                                       password:(NSString *)password
{
    DDLogDebug(@"开始登陆环信服务器");
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userId password:password completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error) {
            // 设置自动登录
            /*
             此属性如果被设置为YES, 会在以下几种情况下被重置为NO:
             1. 用户发起的登出动作;
             2. 用户在别的设备上更改了密码, 导致此设备上自动登陆失败;
             3. 用户的账号被从服务器端删除;
             4. 用户从另一个设备把当前设备上登陆的用户踢出.
             */
            //打印信息
            DDLogDebug(@"环信登录成功:%@",loginInfo);
            //设置是否自动登录
//            [[EaseMob sharedInstance].chatManager enableAutoLogin];
//            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            //通知外部刷新环信消息
            [self notifyObserverRefreshChatList];
            //通知监听者登录状态变化
            [self notifyObserversLoginStatusChangedWithIsSuccess:YES];
            //block返回
            if (self.autoLoginBlock) {
                self.autoLoginBlock(loginInfo,nil);
                self.autoLoginBlock = nil;
            }
            //关闭timer
            [self stopReconnectTimer];
            //优化红点逻辑
            UIApplication *application = [UIApplication sharedApplication];
            NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                application.applicationIconBadgeNumber = unReadNumber;
            });
            //获取群组列表
            [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
            
        }else{
            DDLogDebug(@"环信登录失败:%@",error);
            BOOL isLoggedIn = [[EaseMob sharedInstance].chatManager isLoggedIn];
            if (isLoggedIn) {
                //已经是登录状态，重复登录的问题
                [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                //设置是否自动登录
//                [[EaseMob sharedInstance].chatManager enableAutoLogin];
//                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                //通知外部刷新环信消息
                [self notifyObserverRefreshChatList];
                //通知监听者登录状态变化
                [self notifyObserversLoginStatusChangedWithIsSuccess:YES];
                //block返回
                if (self.autoLoginBlock) {
                    self.autoLoginBlock(loginInfo,nil);
                    self.autoLoginBlock = nil;
                }
                //关闭timer
                [self stopReconnectTimer];
            }else{
                //通知监听者登录状态变化
                [self notifyObserversLoginStatusChangedWithIsSuccess:NO];
                //重试自动登录
                //                [self retryLoginWithUsername:userName password:password];
                //block返回
                if (self.autoLoginBlock) {
                    self.autoLoginBlock(loginInfo,error);
                    self.autoLoginBlock = nil;
                }
                //开启重连timer
                [self startReconnectTimer];
            }
        }
    } onQueue:nil];
}
//手动注销环信服务器
- (void)logOffFromEaseMobServerWithUnbindDeviceToken:(BOOL)isUnbind
                                          logoffType:(TXEaseMobLogoffType)logoffType
                                          completion:(TXEaseMobLogoffBlock)block
{
    if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
        //已登录服务器
        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:isUnbind completion:^(NSDictionary *info, EMError *error) {
            if (!error) {
                DDLogDebug(@"退出环信服务器成功");
                //退出环信服务器成功逻辑
                if (block) {
                    block(info,nil,logoffType);
                }
                if (logoffType == TXEaseMobUserLogoffType) {
                    self.logoffBlock(info,nil,TXEaseMobUserLogoffType);
                }else{
                    self.logoffBlock(nil,nil,logoffType);
                }
                self.logoffRetryTime = 0;
            }else{
                DDLogDebug(@"退出环信服务器失败:%@",error);
                if (block) {
                    block(nil,error,logoffType);
                }
                self.logoffBlock(nil,error,logoffType);
            }
        } onQueue:nil];
    }else{
        //未登录服务器
        if (block) {
            block(nil,nil,logoffType);
        }
        self.logoffBlock(nil,nil,logoffType);
        self.logoffRetryTime = 0;
        //设置是否自动登录
//        [[EaseMob sharedInstance].chatManager disableAutoLogin];
//        [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
    }
}
//监听注销事件
- (void)observeLogOffEventWithBlock:(TXEaseMobLogoffBlock)block
{
    self.logoffBlock = block;
}
//登录失败后重试登录
- (void)retryLoginWithUsername:(NSString *)userName
                      password:(NSString *)password
{
    [self autoLoginEaseMobServerWithUserName:userName password:password completion:self.autoLoginBlock];
}
//修改密码后重新登录
- (void)reLoginWhenChangePassword
{
    if ([[EaseMob sharedInstance].chatManager isLoggedIn]) {
        //已登录服务器
        [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
            if (!error) {
                DDLogDebug(@"修改密码退出环信服务器成功");
                //退出环信服务器成功逻辑
                self.logoffRetryTime = 0;
                //用新账号登录环信
                [self reConnectToEaseMobWhenHeartBeatTimeScheduled];
            }else{
                DDLogDebug(@"修改密码退出环信服务器失败:%@",error);
            }
        } onQueue:nil];
    }
}
//ping完土星server后登陆服务器
- (void)loginAfterPingTXServerWithUserName:(NSString *)userName
                                  password:(NSString *)password
{
    if (_isPingRequesting) {
        return;
    }
    _isPingRequesting = YES;
    [[TXChatClient sharedInstance].counterManager fetchCounters:^(NSError *error, NSMutableDictionary *countersDictionary) {
        _isPingRequesting = NO;
        if (error) {
            if (error.code == TX_STATUS_UNAUTHORIZED ||
                error.code == TX_STATUS_DB_INIT_FAILED ||
                error.code == TX_STATUS_LOCAL_USER_EXPIRED) {
                //token过期，不再继续登陆
                DDLogDebug(@"该用户token有误，T出");
            }else{
                //1秒之后继续登陆
                if (!_isPingHandled) {
                    [self startPingServerTimerWithUserInfo:@{@"userName":userName,@"password":password}];
                }
            }
        }else{
            [self stopPingServerTimer];
            _isPingHandled = NO;
            //没有错误，开始登陆环信
            [self autoLoginEaseMobServerWithUserName:userName password:password completion:^(NSDictionary *loginInfo, EMError *error) {
                if (!error) {
                    DDLogDebug(@"登录环信server成功:%@",loginInfo);
                    [[TXSystemManager sharedManager] setupAppLaunchActions];
                }else{
                    DDLogDebug(@"登录环信server失败:%@",error);
                }
            }];
        }
    }];
}
#pragma mark - 消息和通知
//通知外部去获取新的通知
- (void)notifyObserversToFetchNewNotify
{
    [_observerList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        WeakReferenceObj *weakObj = obj[kEaseMobObserverObject];
        id observer = weakObj.weakRef;
        NSInteger type = [obj[kEaseMobObserverType] integerValue];
        if (observer && type == TXEaseMobRefreshNotifyType) {
            //注册类型对应,执行对应方法
            SEL observerSEL = NSSelectorFromString(obj[kEaseMobObserverSelector]);
            [observer performSelectorOnMainThread:observerSEL withObject:nil waitUntilDone:NO];
        }
    }];
}
//删除跟某个人的聊天会话
- (void)removeConversationByChatter:(NSString *)chatter
                      deleteMessage:(BOOL)isDelete
{
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:isDelete append2Chat:YES];
}
//删除所有的会话
- (void)removeAllConversations
{
    [[EaseMob sharedInstance].chatManager removeAllConversationsWithDeleteMessages:YES append2Chat:YES];
}
//从数据库移除空的会话
- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}
//添加消息监听代理
- (void)addMessageDelegate:(id<TXEaseMobMessageDelegate>)delegate
{
    [self removeMessageDelegate:delegate];
    //添加新的监听者
    @synchronized(self){
        WeakReferenceObj *obj = [[WeakReferenceObj alloc] init];
        obj.weakRef = delegate;
        [_messageDelegates addObject:obj];
    }
}
//移除消息监听代理
- (void)removeMessageDelegate:(id<TXEaseMobMessageDelegate>)delegate
{
    if (!delegate) {
        return;
    }
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < [_messageDelegates count]; i ++)
    {
        WeakReferenceObj *obj = [_messageDelegates objectAtIndex:i];
        id weakDelegate = obj.weakRef;
        if (!weakDelegate || weakDelegate == delegate) {
            [indexs addIndex:i];
        }
    }
    if ([indexs count])
    {
        @synchronized(self){
            [_messageDelegates removeObjectsAtIndexes:indexs];
        }
    }
}
#pragma mark - CMD消息发送
//发送CMD消息到群组
- (void)sendCMDMessageWithType:(TXCMDMessageType)type
{
    if (type == TXCMDMessageType_None) {
        return;
    }
    EMChatCommand *cmdChat = [[EMChatCommand alloc] init];
    switch (type) {
        case TXCMDMessageType_UnBindUser: {
            cmdChat.cmd = kUnbindUserCMDString;
            break;
        }
        case TXCMDMessageType_ProfileChange: {
            cmdChat.cmd = kProfileChangeCMDString;
            break;
        }
        case TXCMDMessageType_GagUser: {
            cmdChat.cmd = kGagUserCMDString;
            break;
        }
        default: {
            break;
        }
    }
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmdChat];
    // 生成message
    NSArray *listArray = [[TXContactManager shareInstance] getAllGroupId];
    for (NSInteger i = 0; i < [listArray count]; i++) {
        NSString *receiverId = listArray[i];
        EMMessage *message = [[EMMessage alloc] initWithReceiver:receiverId bodies:@[body]];
        message.messageType = eMessageTypeGroupChat;  // 设置是否是群聊
//        message.isGroup = YES; // 设置是否是群聊
        [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil];
    }
}
#pragma mark - 消息撤回功能
//发送撤回消息
- (void)sendRevokeMessageCommandWithReceiver:(NSString *)receiver
                                     isGroup:(BOOL)isGroup
                                   messageId:(NSString *)messageId
                                        from:(NSString *)fromUserId
{
    //发送撤回CMD
    EMChatCommand *cmdChat = [[EMChatCommand alloc] init];
    cmdChat.cmd = kRevokeMsgCMDString;
    EMCommandMessageBody *body = [[EMCommandMessageBody alloc] initWithChatObject:cmdChat];
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:receiver bodies:@[body]];
    message.ext = @{@"msg_id":messageId,@"to_user_id":receiver,@"from_user_id":fromUserId,@"is_group":@(isGroup)};
    // 设置是否是群聊
    if (isGroup) {
        message.messageType = eMessageTypeGroupChat;
    }else{
        message.messageType = eMessageTypeChat;
    }
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:nil onQueue:nil completion:^(EMMessage *message, EMError *error) {
        [self handleRevokeCMDMessage:message];
    } onQueue:nil];
}
//处理撤回的CMD消息
- (BOOL)handleRevokeCMDMessage:(EMMessage *)cmdMessage
{
    NSDictionary *cmdExt = cmdMessage.ext;
    NSLog(@"cmd消息中的扩展属性是 -- %@",cmdExt);
    if (cmdExt) {
        NSString *messageId = [cmdExt valueForKey:@"msg_id"];
        NSString *commandMsgId = cmdMessage.messageId;
        if (messageId && [messageId length] && commandMsgId && [commandMsgId length]) {
            NSString *from = [cmdExt valueForKey:@"from_user_id"];
            NSString *to = [cmdExt valueForKey:@"to_user_id"];
            BOOL isGroup = [[cmdExt valueForKey:@"is_group"] boolValue];
            [self deleteEaseMobMessageWithMessageId:messageId cmdMsgId:commandMsgId from:from to:to isGroup:isGroup isAddUnHandledMsgToLocalList:YES];
        }
        return YES;
    }
    return YES;
}
//处理撤回的消息
- (BOOL)handleRevokeMessage:(EMMessage *)cmdMessage
{
//    NSLog(@"撤回的消息EXT:%@",cmdMessage.ext);
    NSDictionary *cmdExt = cmdMessage.ext;
    if (cmdExt) {
        BOOL isRevokeMsg = [[cmdExt valueForKey:@"isRevokeMsg"] boolValue];
        if (isRevokeMsg) {
            NSString *messageId = [cmdExt valueForKey:@"msg_id"];
            NSString *commandMsgId = cmdMessage.messageId;
            if (messageId && [messageId length] && commandMsgId && [commandMsgId length]) {
                NSString *from = [cmdExt valueForKey:@"from_user_id"];
                NSString *to = [cmdExt valueForKey:@"to_user_id"];
                BOOL isGroup = [[cmdExt valueForKey:@"is_group"] boolValue];
                [self deleteEaseMobMessageWithMessageId:messageId cmdMsgId:commandMsgId from:from to:to isGroup:isGroup isAddUnHandledMsgToLocalList:YES];
            }
            return YES;
        }else{
            //判断是否在未处理的消息列表中
            NSString *msgId = cmdMessage.messageId;
            if ([_unhandledRevokeMsgDict valueForKey:msgId]) {
                //删除掉该条消息
                TXDeletedMessage *txDeleteMsg = [_unhandledRevokeMsgDict valueForKey:msgId];
                [self deleteEaseMobMessageWithMessageId:txDeleteMsg.msgId cmdMsgId:txDeleteMsg.cmdMsgId from:txDeleteMsg.fromUserId to:txDeleteMsg.toUserId isGroup:txDeleteMsg.isGroup isAddUnHandledMsgToLocalList:NO];
                return NO;
            }
            return YES;
        }
    }
    return YES;
}
//删除环信的消息
- (void)deleteEaseMobMessageWithMessageId:(NSString *)messageId
                                 cmdMsgId:(NSString *)commandMsgId
                                     from:(NSString *)from
                                       to:(NSString *)to
                                  isGroup:(BOOL)isGroup
             isAddUnHandledMsgToLocalList:(BOOL)isAdd
{
    NSString *revokeChatter;
    if (isGroup) {
        revokeChatter = to;
    }else{
        TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
        NSString *currentUserId = [NSString stringWithFormat:@"%@",@(currentUser.userId)];
        if (from && [from isEqualToString:currentUserId]) {
            revokeChatter = to;
        }else{
            revokeChatter = from;
        }
    }
    EMConversation *conver = [self getEMConversationForChatter:revokeChatter isGroup:isGroup];
    if (conver) {
        EMMessage *revokemsg = [conver loadMessageWithId:messageId];
        if (revokemsg) {
            BOOL isRemoved = [conver removeMessageWithId:messageId];
            if (isRemoved) {
                //移除消息成功,然后移除cmdMsgId
//                [conver removeMessageWithId:commandMsgId];
                //移除数据库和内存中的cmdMsgId
                if ([_unhandledRevokeMsgDict valueForKey:messageId]) {
                    [[TXChatClient sharedInstance].deletedMessageManager deleteDeletedMessageByMsgId:messageId];
                    [_unhandledRevokeMsgDict removeObjectForKey:messageId];
                }
            }
            [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
                id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
                if (weakDelegate && [weakDelegate respondsToSelector:@selector(didReceiveMessage:)]) {
                    [weakDelegate didRevokeMessageIds:@[messageId] from:from to:to isGroup:isGroup];
                }
            }];
        }else{
            //暂未存在这条消息,改为稍后处理
            if (isAdd) {
                //保存到数据库
                TXDeletedMessage *txDeleteMsg = [[TXDeletedMessage alloc] init];
                txDeleteMsg.msgId = messageId;
                txDeleteMsg.cmdMsgId = commandMsgId;
                txDeleteMsg.fromUserId = from;
                txDeleteMsg.toUserId = to;
                txDeleteMsg.isGroup = isGroup;
                [[TXChatClient sharedInstance].deletedMessageManager addDeletedMessage:txDeleteMsg error:nil];
                //添加到内存中
                [_unhandledRevokeMsgDict setValue:txDeleteMsg forKey:messageId];
            }
        }
    }
}
//获取会话
- (EMConversation *)getEMConversationForChatter:(NSString *)chatter
                                        isGroup:(BOOL)isGroup
{
    if (!chatter) {
        return nil;
    }
    EMConversation *conversation = [self.conversationDict valueForKey:chatter];
    if (conversation) {
        return conversation;
    }
    EMConversation *aConversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:isGroup ? eConversationTypeGroupChat : eConversationTypeChat];
    [self.conversationDict setValue:aConversation forKey:chatter];
    return aConversation;
}
#pragma mark - helper
//判断用户是否存在
- (BOOL)checkIsStillExistUser:(NSString *)userId
{
    if (!_cacheMemberDict || ![[_cacheMemberDict allValues] count]) {
        return YES;
    }
    __block BOOL isExist = NO;
    [_cacheMemberDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL *stop) {
        if ([obj containsObject:userId]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    return isExist;
}
//更新缓存列表
- (void)updateCacheMemberDict
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (currentUser) {
        NSString *cacheKey = [NSString stringWithFormat:@"%@-%@",@(currentUser.userId),kEMCachedGroupMembers];
        [[NSUserDefaults standardUserDefaults] setValue:_cacheMemberDict forKey:cacheKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
//初始化缓存列表数据到内存中
- (void)initializeCacheMemberDict
{
    _cacheMemberDict = [NSMutableDictionary dictionary];
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (currentUser) {
        NSString *cacheKey = [NSString stringWithFormat:@"%@-%@",@(currentUser.userId),kEMCachedGroupMembers];
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:cacheKey];
        if (dict) {
            [_cacheMemberDict setDictionary:dict];
        }
    }
}
#pragma mark - 群免打扰
//设置群免打扰
- (void)ignoreGroupDisturbWithId:(NSString *)groupId
                   disturbStatus:(BOOL)isOpen
                      completion:(void(^)(BOOL isSuccess))completionBlock
{
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:groupId isIgnore:isOpen completion:^(NSArray *ignoreGroupsList, EMError *error) {
        error == nil ? completionBlock(YES) : completionBlock(NO);
    } onQueue:nil];
}

//获取群免打扰状态
- (BOOL)groupNoDisturbStatusWithId:(NSString *)groupId
{
    NSArray *ignoreGroupList = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    if ([ignoreGroupList containsObject:groupId]) {
        return YES;
    }
    return NO;
}
#pragma mark - 环信回调通知观察者刷新
//添加环信刷新的回调
- (void)addEaseMobRefreshObserver:(id)observer selector:(SEL)selector type:(TXEaseMobRefreshType)type
{
    [self removeEaseMobRefreshObserver:observer type:type];
    //添加新的监听者
    NSString *selString = NSStringFromSelector(selector);
    WeakReferenceObj *weakObj = [[WeakReferenceObj alloc] init];
    weakObj.weakRef = observer;
    NSDictionary *observerDict = @{kEaseMobObserverObject: weakObj,kEaseMobObserverSelector: selString,kEaseMobObserverType: @(type)};
    @synchronized(self){
        [_observerList addObject:observerDict];
    }
}
//移除环信刷新监听者,如果不指定type，默认移除所有observer下的所有监听类型
- (void)removeEaseMobRefreshObserver:(id)observer type:(TXEaseMobRefreshType)type
{
    [self removeEaseMobRefreshObserver:observer isAllType:NO subType:type];
}
//移除环信刷新监听者
- (void)removeEaseMobRefreshObserver:(id)observer
{
    [self removeEaseMobRefreshObserver:observer isAllType:YES subType:TXEaseMobRefreshTypeNone];
}
//移除监听者和对应类型
- (void)removeEaseMobRefreshObserver:(id)observer isAllType:(BOOL)isAll subType:(TXEaseMobRefreshType)type
{
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < [_observerList count]; i ++)
    {
        NSDictionary *dict = [_observerList objectAtIndex:i];
        if (isAll) {
            WeakReferenceObj *weakObj = dict[kEaseMobObserverObject];
            if (weakObj.weakRef == observer)
            {
                [indexs addIndex:i];
            }
        }else{
            NSInteger observerType = [dict[kEaseMobObserverType] integerValue];
            WeakReferenceObj *weakObj = dict[kEaseMobObserverObject];
            if (weakObj.weakRef == observer && type == observerType)
            {
                [indexs addIndex:i];
            }
        }
    }
    if ([indexs count])
    {
        @synchronized(self){
            [_observerList removeObjectsAtIndexes:indexs];
        }
    }
}
//通知观察者刷新聊天列表
- (void)notifyObserverRefreshChatList
{
    [_observerList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        WeakReferenceObj *weakObj = obj[kEaseMobObserverObject];
        id observer = weakObj.weakRef;
        NSInteger type = [obj[kEaseMobObserverType] integerValue];
        if (observer && type == TXEaseMobRefreshChatListType) {
            //注册类型对应,执行对应方法
            SEL observerSEL = NSSelectorFromString(obj[kEaseMobObserverSelector]);
            [observer performSelectorOnMainThread:observerSEL withObject:nil waitUntilDone:NO];
        }
    }];
}
//登录状态变化
- (void)notifyObserversLoginStatusChangedWithIsSuccess:(BOOL)isSuccess
{
    [_observerList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        WeakReferenceObj *weakObj = obj[kEaseMobObserverObject];
        id observer = weakObj.weakRef;
        NSInteger type = [obj[kEaseMobObserverType] integerValue];
        if (observer && type == TXEaseMobRefreshLoginStatusType) {
            //注册类型对应,执行对应方法
            SEL observerSEL = NSSelectorFromString(obj[kEaseMobObserverSelector]);
            [observer performSelectorOnMainThread:observerSEL withObject:@(isSuccess) waitUntilDone:NO];
        }
    }];
}
#pragma mark - EMChatManagerLoginDelegate
// 将要开始自动登录
- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    DDLogDebug(@"开始自动登录环信服务器info:%@ error:%@",loginInfo,error);
    self.autoLoginDict = loginInfo;
    //block返回
    if (self.autoLoginBlock) {
        self.autoLoginBlock(loginInfo,error);
        self.autoLoginBlock = nil;
        self.autoLoginDict = nil;
    }
}
// 自动登录结束
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {
        DDLogDebug(@"自动登录环信服务器成功:%@",loginInfo);
        if (_connectStatus != TXServerConnectedLogoffStatus) {
            //通知监听者登录状态变化
            [self notifyObserversLoginStatusChangedWithIsSuccess:YES];
            //关闭timer
            [self stopReconnectTimer];
        }
    }else{
        DDLogDebug(@"自动登录环信服务器失败info:%@ error:%@",loginInfo,error);
        if (_connectStatus != TXServerConnectedLogoffStatus) {
            //通知监听者登录状态变化
            [self notifyObserversLoginStatusChangedWithIsSuccess:NO];
            //开启重连timer
            [self startReconnectTimer];
        }
    }
    if (_connectStatus != TXServerConnectedLogoffStatus) {
        self.autoLoginDict = loginInfo;
        //block返回
        if (self.autoLoginBlock) {
            self.autoLoginBlock(loginInfo,error);
            self.autoLoginBlock = nil;
            self.autoLoginDict = nil;
        }
        //通知外部刷新环信消息
        [self notifyObserverRefreshChatList];
        //获取群组列表
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
    }else{
        //发起注销请求
        [self normalLogoffEaseMobServer];
    }
}
//将要发起自动重连操作
- (void)willAutoReconnect
{
    DDLogDebug(@"开始自动重连环信");
    dispatch_async(dispatch_get_main_queue(), ^{
        //发送开始连接的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobStartLoginNotification object:nil];
    });
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:kEaseMobUserName];
    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:kLocalPassword];
    [self startAsynLoginToEaseMobServerWithUserId:userName password:password];
}
//自动重连操作完成后的回调（成功的话，error为nil，失败的话，查看error的错误信息）
- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    DDLogDebug(@"自动重连完成:%@",error);
    //获取群组列表
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
}
//用户注销后的回调
- (void)didLogoffWithError:(EMError *)error
{
    DDLogDebug(@"注销环信服务器:%@",error);
}
//普通注销环信服务器
- (void)normalLogoffEaseMobServer
{
    DDLogDebug(@"普通注销环信服务器");
    if (self.logoffRetryTime >= kEaseMobLogoffRetryTime) {
        self.logoffRetryTime = 0;
        return;
    }
    if (self.connectStatus != TXServerConnectedLogoffStatus) {
        return;
    }
    //注销当前账号
    WEAKSELF
    //注销失败，继续注销，直到注销成功或者大于重试次数
    [self logOffFromEaseMobServerWithUnbindDeviceToken:YES logoffType:TXEaseMobNormalLogoffType completion:^(NSDictionary *info, EMError *error, TXEaseMobLogoffType type) {
        if (error) {
            weakSelf.logoffRetryTime += 1;
            [weakSelf normalLogoffEaseMobServer];
        }
    }];
}
//当前登录账号在其它设备登录时的通知回调
- (void)didLoginFromOtherDevice
{
    DDLogDebug(@"当前账号从其他设备登录");
    if (self.logoffRetryTime >= kEaseMobLogoffRetryTime) {
        self.logoffRetryTime = 0;
        return;
    }
    //注销当前账号
    WEAKSELF
    //注销失败，继续注销，直到注销成功或者大于重试次数
    //注销土星服务器在线状态
    [[TXChatClient sharedInstance] logout:^(NSError *error) {
        if (error) {
            weakSelf.logoffRetryTime += 1;
            [weakSelf didLoginFromOtherDevice];
        }else{
            //设置状态值
            [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLogoffStatus;
            //退出环信服务器
            [self logOffFromEaseMobServerWithUnbindDeviceToken:NO logoffType:TXEaseMobOtherDeviceLoginedType completion:^(NSDictionary *info, EMError *error, TXEaseMobLogoffType type) {
                [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedNormalStatus;
                if (error) {
                    weakSelf.logoffRetryTime += 1;
                    [weakSelf didLoginFromOtherDevice];
                }
            }];
        }
    }];
}
//当前登录账号已经被从服务器端删除
- (void)didRemovedFromServer
{
    DDLogDebug(@"当前账号从服务器删除");
    if (self.logoffRetryTime >= kEaseMobLogoffRetryTime) {
        self.logoffRetryTime = 0;
        return;
    }
    //注销当前账号
    WEAKSELF
    [[TXChatClient sharedInstance] logout:^(NSError *error) {
        if (error) {
            weakSelf.logoffRetryTime += 1;
            [weakSelf didLoginFromOtherDevice];
        }else{
            //设置状态值
            [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLogoffStatus;
            //退出环信服务器
            [self logOffFromEaseMobServerWithUnbindDeviceToken:YES logoffType:TXEaseMobServerRemovedCountType completion:^(NSDictionary *info, EMError *error, TXEaseMobLogoffType type) {
                //注销失败，继续注销，直到注销成功
                [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedNormalStatus;
                if (error) {
                    weakSelf.logoffRetryTime += 1;
                    [weakSelf didRemovedFromServer];
                }
            }];
        }
    }];
}
#pragma mark - EMChatManagerChatDelegate
//接收到cmd消息
- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    DDLogDebug(@"接收到cmdMessage:%@",cmdMessage);
    EMCommandMessageBody *body = (EMCommandMessageBody *)cmdMessage.messageBodies.lastObject;
    NSString *action = body.action;
    TXCMDMessageType cmdType = TXCMDMessageType_None;
    if (action && [action isEqualToString:kUnbindUserCMDString]) {
        cmdType = TXCMDMessageType_UnBindUser;
    }else if (action && [action isEqualToString:kProfileChangeCMDString]) {
        cmdType = TXCMDMessageType_ProfileChange;
    }else if (action && [action isEqualToString:kGagUserCMDString]) {
        cmdType = TXCMDMessageType_GagUser;
    }else if (action && [action isEqualToString:kRevokeMsgCMDString]) {
        cmdType = TXCMDMessageType_RevokeMessage;
    }else if (action && [action isEqualToString:kNewCheckinVoiceCMDString]) {
        cmdType = TXCMDMessageType_NewCheckInVoice;
    }
    if (cmdType != TXCMDMessageType_NewCheckInVoice) {
        //刷卡语音改为通知发送
        [_observerList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            WeakReferenceObj *weakObj = obj[kEaseMobObserverObject];
            id observer = weakObj.weakRef;
            NSInteger type = [obj[kEaseMobObserverType] integerValue];
            if (observer && type == TXEaseMobRefreshCMDMessageType) {
                //注册类型对应,执行对应方法
                SEL observerSEL = NSSelectorFromString(obj[kEaseMobObserverSelector]);
                [observer performSelectorOnMainThread:observerSEL withObject:@(cmdType) waitUntilDone:NO];
            }
        }];
    }
    //判断是否解绑了用户
    if (cmdType == TXCMDMessageType_UnBindUser) {
        //获取群组列表
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
    }else if (cmdType == TXCMDMessageType_RevokeMessage) {
        //撤回消息
        [self handleRevokeCMDMessage:cmdMessage];
    }else if (cmdType == TXCMDMessageType_NewCheckInVoice) {
        //发送通知
        TXAsyncRunInMain(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ReceiveNewCheckinVoiceNotification object:nil];
        });
    }
}
//会话列表信息更新时的回调
- (void)didUpdateConversationList:(NSArray *)conversationList
{
    [self notifyObserverRefreshChatList];
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didUpdateConversationList)]) {
            [weakDelegate didUpdateConversationList];
        }
    }];
}
//未读数更新
-(void)didUnreadMessagesCountChanged
{
    [self notifyObserverRefreshChatList];
    //更新tabitem按钮标示
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TX_NOTIFICATION_COUNTER_REFRESHED object:nil userInfo:nil];
    });
    //更新AppIcon角标
    UIApplication *application = [UIApplication sharedApplication];
    NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        application.applicationIconBadgeNumber = unReadNumber;
    });
}
//更新群组消息
- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self notifyObserverRefreshChatList];
    //获取所有group信息
//    NSLog(@"allGroups:%@",allGroups);
//    [allGroups enumerateObjectsUsingBlock:^(EMGroup *obj, NSUInteger idx, BOOL *stop) {
//        [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:obj.groupId includesOccupantList:YES];
//    }];
}
//- (void)didFetchGroupInfo:(EMGroup *)group error:(EMError *)error
//{
////    NSLog(@"群组信息:%@",group);
////    NSLog(@"列表:%@",group.occupants);
//    //添加进缓存列表
//    if (group) {
//        [_cacheMemberDict setValue:group.occupants forKey:group.groupId];
//        [self updateCacheMemberDict];
//    }
//    //发送通知告诉外部列表更新
//    TXAsyncRunInMain(^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:EaseMobAllGroupMembersUpdateNotification object:nil];
//    });
//}
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (reason == eGroupLeaveReason_BeRemoved) {
        //被群主T出群，当做账号被销毁处理
        DDLogDebug(@"当前账号从群组中移除");
//        self.logoffBlock(nil,nil,TXEaseMobServerRemovedCountType);
        [[TXChatClient sharedInstance] fetchDepartments:^(NSError *error) {
            //从网络获取成功，通知列表更新群
            [[TXEaseMobHelper sharedHelper] notifyObserverRefreshChatList];
            if(!error)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSArray *departs = [[TXChatClient sharedInstance] getAllDepartments:nil];
                    for(TXDepartment *index in departs)
                    {
                        [[TXChatClient sharedInstance] fetchDepartmentMembers:index.departmentId clearLocalData:NO onCompleted:nil];
                    }
                });
            }
        }];
    }
}
////将要接收离线消息的回调
//- (void)willReceiveOfflineMessages
//{
//    NSLog(@"将要接收离线消息");
//}

//接收到离线透传消息的回调
- (void)didReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    DDLogDebug(@"离线透传消息:%@",offlineCmdMessages);
    for (EMMessage *cmdMessage in offlineCmdMessages) {
        EMCommandMessageBody *body = (EMCommandMessageBody *)cmdMessage.messageBodies.lastObject;
        NSString *action = body.action;
        TXCMDMessageType cmdType = TXCMDMessageType_None;
        if (action && [action isEqualToString:kUnbindUserCMDString]) {
            cmdType = TXCMDMessageType_UnBindUser;
        }else if (action && [action isEqualToString:kProfileChangeCMDString]) {
            cmdType = TXCMDMessageType_ProfileChange;
        }else if (action && [action isEqualToString:kGagUserCMDString]) {
            cmdType = TXCMDMessageType_GagUser;
        }else if (action && [action isEqualToString:kRevokeMsgCMDString]) {
            cmdType = TXCMDMessageType_RevokeMessage;
        }else if (action && [action isEqualToString:kNewCheckinVoiceCMDString]) {
            cmdType = TXCMDMessageType_NewCheckInVoice;
        }
        if (cmdType != TXCMDMessageType_NewCheckInVoice) {
            //离线的新刷卡语音不处理
            [_observerList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                WeakReferenceObj *weakObj = obj[kEaseMobObserverObject];
                id observer = weakObj.weakRef;
                NSInteger type = [obj[kEaseMobObserverType] integerValue];
                if (observer && type == TXEaseMobRefreshCMDMessageType) {
                    //注册类型对应,执行对应方法
                    SEL observerSEL = NSSelectorFromString(obj[kEaseMobObserverSelector]);
                    [observer performSelectorOnMainThread:observerSEL withObject:@(cmdType) waitUntilDone:NO];
                }
            }];
        }
        //判断是否解绑了用户
        if (cmdType == TXCMDMessageType_UnBindUser) {
            //获取群组列表
            [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
        }else if (cmdType == TXCMDMessageType_RevokeMessage) {
            //撤回消息
            [self handleRevokeCMDMessage:cmdMessage];
        }
    }
}
#pragma mark - 回调给外部的环信代理
//接收到发送消息的回调
-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didSendMessage:error:)]) {
            [weakDelegate didSendMessage:message error:error];
        }
    }];
    //处理撤回消息
//    [self handleRevokeMessage:message];
}
- (void)didReceiveHasReadResponse:(EMReceipt*)receipt
{
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didReceiveHasReadResponse:)]) {
            [weakDelegate didReceiveHasReadResponse:receipt];
        }
    }];
}
//消息附件状态更新
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error
{
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didMessageAttachmentsStatusChanged:error:)]) {
            [weakDelegate didMessageAttachmentsStatusChanged:message error:error];
        }
    }];
}
- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress
{
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didFetchingMessageAttachments:progress:)]) {
            [weakDelegate didFetchingMessageAttachments:message progress:progress];
        }
    }];
}
//收到消息时的回调
- (void)didReceiveMessage:(EMMessage *)message
{
//    DDLogDebug(@"接收到消息:%@",message);
    //处理撤回消息
//    BOOL isHandled = [self handleRevokeMessage:message];
//    if (isHandled) {
//        [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
//            id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
//            if (weakDelegate && [weakDelegate respondsToSelector:@selector(didReceiveMessage:)]) {
//                [weakDelegate didReceiveMessage:message];
//            }
//        }];
//    }
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didReceiveMessage:)]) {
            [weakDelegate didReceiveMessage:message];
        }
    }];
//    NSDictionary *extDict = message.ext;
//    BOOL isRevokeMsg = [[extDict valueForKey:@"isRevokeMsg"] boolValue];
//    if (isRevokeMsg) {
//        return;
//    }
    //播放声音或震动
    BOOL isGroupChat = NO;
    if (message.messageType == eMessageTypeGroupChat) {
        isGroupChat = YES;
    }
    if ([[TXSystemManager sharedManager].currentChatId length] && [[TXSystemManager sharedManager].currentChatId isEqualToString:message.conversationChatter]) {
        //播放震动
        [[TXSystemManager sharedManager] playVibrationWithGroupId:isGroupChat ? message.conversationChatter : nil emMessage:message];
    }else{
        //播放声音和震动
        [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:isGroupChat ? message.conversationChatter : nil emMessage:message];
    }
}
//接收到离线非透传消息的回调
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
//    DDLogDebug(@"离线非透传消息:%@",offlineMessages);
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didReceiveOfflineMessages:)]) {
            [weakDelegate didReceiveOfflineMessages:offlineMessages];
        }
    }];
    for (EMMessage *message in offlineMessages) {
        //处理撤回消息
//        [self handleRevokeMessage:message];
//        NSDictionary *extDict = message.ext;
//        BOOL isRevokeMsg = [[extDict valueForKey:@"isRevokeMsg"] boolValue];
//        if (!isRevokeMsg) {
//            //播放声音或震动
//            BOOL isGroupChat = NO;
//            if (message.messageType == eMessageTypeGroupChat) {
//                isGroupChat = YES;
//            }
//            if ([[TXSystemManager sharedManager].currentChatId length] && [[TXSystemManager sharedManager].currentChatId isEqualToString:message.conversationChatter]) {
//                //播放震动
//                [[TXSystemManager sharedManager] playVibrationWithGroupId:isGroupChat ? message.conversationChatter : nil emMessage:message];
//            }else{
//                //播放声音和震动
//                [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:isGroupChat ? message.conversationChatter : nil emMessage:message];
//            }
//        }
        //播放声音或震动
        BOOL isGroupChat = NO;
        if (message.messageType == eMessageTypeGroupChat) {
            isGroupChat = YES;
        }
        if ([[TXSystemManager sharedManager].currentChatId length] && [[TXSystemManager sharedManager].currentChatId isEqualToString:message.conversationChatter]) {
            //播放震动
            [[TXSystemManager sharedManager] playVibrationWithGroupId:isGroupChat ? message.conversationChatter : nil emMessage:message];
        }else{
            //播放声音和震动
            [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:isGroupChat ? message.conversationChatter : nil emMessage:message];
        }
    }
}
- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didReceiveMessageId:chatter:error:)]) {
            [weakDelegate didReceiveMessageId:messageId chatter:conversationChatter error:error];
        }
    }];
}
- (void)didInterruptionRecordAudio
{
    [_messageDelegates enumerateObjectsUsingBlock:^(WeakReferenceObj *obj, NSUInteger idx, BOOL *stop) {
        id<TXEaseMobMessageDelegate> weakDelegate = obj.weakRef;
        if (weakDelegate && [weakDelegate respondsToSelector:@selector(didInterruptionRecordAudio)]) {
            [weakDelegate didInterruptionRecordAudio];
        }
    }];
}
#pragma mark - EMChatManagerUtilDelegate
// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    BOOL isDisconnected = NO;
    if (connectionState == eEMConnectionDisconnected) {
        isDisconnected = YES;
    }else{
        isDisconnected = NO;
    }
    [_observerList enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        WeakReferenceObj *weakObj = obj[kEaseMobObserverObject];
        id observer = weakObj.weakRef;
        NSInteger type = [obj[kEaseMobObserverType] integerValue];
        if (observer && type == TXEaseMobRefreshNetworkChangeType) {
            //注册类型对应,执行对应方法
            SEL observerSEL = NSSelectorFromString(obj[kEaseMobObserverSelector]);
            [observer performSelectorOnMainThread:observerSEL withObject:@(isDisconnected) waitUntilDone:NO];
        }
    }];
}

@end
