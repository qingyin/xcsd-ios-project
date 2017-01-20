//
//  TXParentChatViewController.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXParentChatViewController.h"
#import "NSDate+TuXing.h"
#import "TXMessage.h"
#import "ParentsDetailViewController.h"
#import "EMCDDeviceManager.h"
#import "EMCDDeviceManagerDelegate.h"
#import "MessageReadManager.h"
#import "TXPhotoBrowserViewController.h"
#import "GroupDetailViewController.h"
#import <BlockUI.h>
#import "TXMessageZoomViewController.h"
#import "TXContactManager.h"
#import "TXSystemManager.h"
#import "TXEaseMobHelper.h"
#import "PublishmentDetailViewController.h"
#import "TXMessageInputView.h"
#import "TXMessageTextView.h"
#import <AVFoundation/AVFoundation.h>
#import "NSObject+EXTParams.h"
#import "TXVideoPreviewViewController.h"
#import "TXReportManager.h"
#import "InnerPublishDetailController.h"

static NSInteger const kPageCount = 20;
static NSInteger const kTimeDisplayDuration = 300;

@interface TXParentChatViewController ()
<IChatManagerDelegate,
TXChatTableViewControllerDataSource,
TXChatTableViewControllerDelegate,
UIActionSheetDelegate,
TXEaseMobMessageDelegate,
EMCDDeviceManagerDelegate>
{
    dispatch_queue_t _messageQueue;
}
//@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (nonatomic,strong) NSMutableArray *msgDataSource;//tableView数据源
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDate *chatTagDate;
@property (nonatomic,strong) NSString *chatter;
@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic, assign) BOOL isTeacher;

@end

@implementation TXParentChatViewController

#pragma mark - Life Cycle
- (void)dealloc
{
    DLog(@"%s",__func__);
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    [[TXEaseMobHelper sharedHelper] removeMessageDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    self = [super init];
    if (self) {
        _messages = [NSMutableArray array];
        //根据接收者的username获取当前会话的管理者
        self.conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:isGroup ? eConversationTypeGroupChat : eConversationTypeChat];
//        self.conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter isGroup:isGroup];
        //设置消息为已读
        [self.conversation markAllMessagesAsRead:YES];
        self.isGroup = isGroup;
        //设置title
        self.chatter = chatter;
        //设置标题
        NSDictionary *userDict = [[TXContactManager shareInstance] getUserByUserID:[chatter longLongValue] isGroup:isGroup  complete:^(NSDictionary *userInfo, NSError *error) {
            if(!error)
            {
                self.titleStr = userInfo[@"name"];
            }
        }];
        if (userDict) {
            NSString *sendNameString = userDict[@"name"];
            if (sendNameString && [sendNameString length]) {
                self.titleStr = sendNameString;
            }
        }
        
        if ([self.titleStr isEqualToString:@"老师"]) {
            self.isTeacher = YES;
        }
//        //判断是否还存在当前用户
//        if (!isGroup) {
//            self.existChatUser = [[TXEaseMobHelper sharedHelper] checkIsStillExistUser:chatter];
//        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupEaseMobConfigure];
    [self commonSetup];
    [self fetchMessageFromLocalDBWithIsScrollToBottom:NO];
}
#pragma mark - UI视图更新
- (void)createCustomNavBar
{
    self.shouldLimitTitleLabelWidth = YES;
    self.umengEventText = @"聊天";
    [super createCustomNavBar];
    [self updateNavigationLeftButtonView];
    
    if (self.isGroup) {
        //bay gaoju
        [self.btnRight setImage:[UIImage imageNamed:@"classDetailIcon"] forState:UIControlStateNormal];
        [self.btnRight addTarget:self action:@selector(onClickGroupManagerButton) forControlEvents:UIControlEventTouchUpInside];
    }else{
        if([self.chatter isEqualToString:KTXCustomerChatter])
        {
            [self.btnRight setTitle:@"诊断" forState:UIControlStateNormal];
            [self.btnRight addTarget:self action:@selector(updateReportToServer) forControlEvents:UIControlEventTouchUpInside];
        }else{
            //bay gaoju
//            [self.btnRight setImage:[UIImage imageNamed:@"personalIcon"] forState:UIControlStateNormal];
//            [self.btnRight addTarget:self action:@selector(onClickPersonalInfoButton) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //设置聊天窗口id
    [TXSystemManager sharedManager].currentChatId = self.chatter;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //设置聊天窗口id
    [TXSystemManager sharedManager].currentChatId = @"";
    //停用光感器
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}
//更新左侧导航栏按钮视图
- (void)updateNavigationLeftButtonView
{
    //设置左标题
    if (_isNormalBack) {
        return;
    }
    NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
    if (unReadNumber > 0) {
        [self.btnLeft setTitle:[NSString stringWithFormat:@"消息(%@)",unReadNumber > 99 ? @"..." : @(unReadNumber)] forState:UIControlStateNormal];
    }else{
        [self.btnLeft setTitle:@"消息" forState:UIControlStateNormal];
    }
}
#pragma mark - 初始化设置
- (void)commonSetup
{
    //注册代理
    self.dataSource = self;
    self.delegate = self;
    //初始化操作队列
    _messageQueue = dispatch_queue_create("tuxingMessage.com", NULL);
    //注册通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMessageImageLoadSuccessNotification:) name:EMMessageImageLoadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveEaseMobAllGroupMembersUpdateNotification:) name:EaseMobAllGroupMembersUpdateNotification object:nil];
}
#pragma mark - 环信内容设置
//初始化环信设置
- (void)setupEaseMobConfigure
{
    [[TXEaseMobHelper sharedHelper] addMessageDelegate:self];
    [EMCDDeviceManager sharedInstance].delegate = self;
}
#pragma mark - 通知
- (void)onReceiveMessageImageLoadSuccessNotification:(NSNotification *)notification
{
    EMMessage *message = notification.object;
    if (message && [message isKindOfClass:[EMMessage class]]) {
        [self onMessageImageHasRead:message];
    }
}
- (void)onReceiveEaseMobAllGroupMembersUpdateNotification:(NSNotification *)notification
{
    //判断是否还存在当前用户
//    if (!self.isGroup) {
//        self.existChatUser = [[TXEaseMobHelper sharedHelper] checkIsStillExistUser:self.chatter];
//    }
}
- (void)onMessageImageHasRead:(EMMessage *)message
{
    //发送已读回执
    if ([self shouldAckMessage:message read:YES])
    {
        [self sendHasReadResponseForMessages:@[message]];
    }
}
#pragma mark - 信息加载+更新
//从本地加载数据
- (void)fetchMessageFromLocalDBWithIsScrollToBottom:(BOOL)isScrollToBottom
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(_messageQueue, ^{
        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;

        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:([weakSelf.messages count] + kPageCount) before:timestamp];

//        weakSelf.messages = [messages mutableCopy];
        weakSelf.messages = [NSMutableArray arrayWithArray:messages];
        NSInteger currentCount = [weakSelf.msgDataSource count];
//        weakSelf.msgDataSource = [[weakSelf formatMessages:messages] mutableCopy];
        NSArray *formatMessages = [weakSelf formatMessages:messages];
        weakSelf.msgDataSource = [NSMutableArray arrayWithArray:formatMessages];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isScrollToBottom) {
                if ([weakSelf.msgDataSource count] > 0) {
                    [weakSelf reloadChatViewAndScrollToIndexPath:[NSIndexPath indexPathForRow:[weakSelf.msgDataSource count] - 1 inSection:0] animated:NO mustScroll:NO];
                }else{
                    [weakSelf reloadChatViewAndScrollToIndexPath:nil animated:NO mustScroll:NO];
                }
            }else{
                if ([weakSelf.msgDataSource count] - currentCount > 0) {
                    [weakSelf reloadChatViewAndScrollToIndexPath:[NSIndexPath indexPathForRow:[weakSelf.msgDataSource count] - currentCount - 1 inSection:0] animated:NO mustScroll:NO];
                }else{
                    [weakSelf reloadChatViewAndScrollToIndexPath:nil animated:NO mustScroll:NO];
                }
            }
            if ([messages count] < kPageCount) {
                //隐藏下拉刷新控件
                [weakSelf hideMessageHeaderRefreshingView];
            }
        });
        //从数据库导入时重新下载没有下载成功的附件
        for (NSInteger i = 0; i < [weakSelf.msgDataSource count]; i++)
        {
            id obj = weakSelf.msgDataSource[i];
            if ([obj isKindOfClass:[TXMessage class]])
            {
                TXMessage *msg = (TXMessage *)obj;
                if (![msg isTimeMessage] && ![msg isTipMessage]) {
                    [weakSelf downloadUnFinishedMessageAttachments:msg];
                }
            }
        }
    });

}
//下载没有完成下载的附件
- (void)downloadUnFinishedMessageAttachments:(TXMessage *)model
{
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [self reloadTableViewDataWithMessage:model.message];
        }
    };
    
    if ([model messageMediaType] == TXBubbleMessageMediaTypePhoto) {
        id<IEMMessageBody> messageBody = [[[model message] messageBodies] firstObject];
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:model.message progress:nil completion:completion onQueue:nil];
        }
    }
}
//格式化多个message
- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSString *currentUserId = [NSString stringWithFormat:@"%@",@(currentUser.userId)];
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
//            NSDictionary *extDict = message.ext;
//            BOOL isRevokeMsg = [[extDict valueForKey:@"isRevokeMsg"] boolValue];
//            if (isRevokeMsg) {
//                continue;
//            }
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > kTimeDisplayDuration || tempDate < -kTimeDisplayDuration || (self.chatTagDate == nil)) {
                TXMessage *timeModel = [[TXMessage alloc] init];
                timeModel.time = [createDate formattedTime];
                timeModel.isTimeMessage = YES;
                timeModel.bubbleMessageType = TXBubbleMessageTypeOutgoing;
                [formatArray addObject:timeModel];
                self.chatTagDate = createDate;
            }
            TXMessage *model = [[TXMessage alloc] initBubbleMessageWithEMMessage:message isGroupChat:self.isGroup];
            if (!currentUser) {
                model.bubbleMessageType = TXBubbleMessageTypeOutgoing;
            }else{
                if (message.from && [message.from isEqualToString:currentUserId]) {
                    model.bubbleMessageType = TXBubbleMessageTypeOutgoing;
                }else{
                    model.bubbleMessageType = TXBubbleMessageTypeIncoming;
                }
            }
            model.isTimeMessage = NO;
            model.isTipMessage = NO;
            [formatArray addObject:model];
        }
    }
    
    return formatArray;
}
//格式化单个message
-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > kTimeDisplayDuration || tempDate < -kTimeDisplayDuration || (self.chatTagDate == nil)) {
        TXMessage *timeModel = [[TXMessage alloc] init];
        timeModel.time = [createDate formattedTime];
        timeModel.isTimeMessage = YES;
        timeModel.bubbleMessageType = TXBubbleMessageTypeOutgoing;
        [ret addObject:timeModel];
        self.chatTagDate = createDate;

    }
    TXMessage *model = [[TXMessage alloc] initBubbleMessageWithEMMessage:message isGroupChat:self.isGroup];
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        model.bubbleMessageType = TXBubbleMessageTypeOutgoing;
    }else{
        NSString *currentUserId = [NSString stringWithFormat:@"%@",@(currentUser.userId)];
        if ((!message.from || ![message.from length]) || [message.from isEqualToString:currentUserId]) {
            model.bubbleMessageType = TXBubbleMessageTypeOutgoing;
        }else{
            model.bubbleMessageType = TXBubbleMessageTypeIncoming;
        }
    }
    model.isTimeMessage = NO;
    model.isTipMessage = NO;
    [ret addObject:model];
    //判断是否已经不存在该用户
//    if (!self.isExistChatUser) {
//        //添加已离开标示
//        NSString *leaveTipString;
//        if (self.titleStr && [self.titleStr length]) {
//            leaveTipString = [NSString stringWithFormat:@"%@已经离开微家园",self.titleStr];
//        }else{
//            leaveTipString = @"该用户已经离开微家园";
//        }
//        TXMessage *timeModel = [[TXMessage alloc] init];
//        timeModel.tipMessage = leaveTipString;
//        timeModel.isTipMessage = YES;
//        timeModel.bubbleMessageType = TXBubbleMessageTypeOutgoing;
//        [ret addObject:timeModel];
//    }
    
    return ret;
}
//添加消息
-(void)addMessage:(EMMessage *)message isFromSelf:(BOOL)isSelf
{
//    NSDictionary *extDict = message.ext;
//    BOOL isRevokeMsg = [[extDict valueForKey:@"isRevokeMsg"] boolValue];
//    if (isRevokeMsg) {
//        return;
//    }
    __block BOOL isExist = NO;
    [_messages enumerateObjectsUsingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
        if ([message.messageId isEqualToString:obj.messageId]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    if (isExist) {
        //已存在该消息，去重不添加
//        //清空已发送文本
//        self.msgInputView.inputTextView.text = @"";

        return;
    }
//    DDLogDebug(@"message:%@", message);
    __weak TXParentChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        @synchronized (self) {
            [_messages addObject:message];
            NSArray *newMessages = [weakSelf formatMessage:message];
            [weakSelf.msgDataSource addObjectsFromArray:newMessages];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf reloadChatViewAndScrollToIndexPath:[NSIndexPath indexPathForRow:[weakSelf.msgDataSource count] - 1 inSection:0] animated:YES mustScroll:isSelf];
            if (isSelf) {
                //清空已发送文本
                self.msgInputView.inputTextView.text = @"";
            }
        });
    });
}
#pragma mark - 继承父类的方法
- (void)addMessage:(EMMessage *)message
{
    [self addMessage:message isFromSelf:YES];
}

- (void)sendTextMessage:(NSString *)textMessage
{
    [super sendTextMessage:textMessage];
    
    if (!self.isGroup) {
        [self reportEvent:XCSDPBEventTypeSingleChat bid:self.chatter];
    }else{
        
        if (self.isTeacher) {
            [self reportEvent:XCSDPBEventTypeTeacherGroupChat bid:self.chatter];
        }else{
            [self reportEvent:XCSDPBEventTypeGroupChat bid:self.chatter];
        }
    }
}
- (void)sendImageMessage:(UIImage *)image
{
    [super sendImageMessage:image];
    
    if (!self.isGroup) {
        [self reportEvent:XCSDPBEventTypeSingleChat bid:self.chatter];
    }else{
        
        if (self.isTeacher) {
            [self reportEvent:XCSDPBEventTypeTeacherGroupChat bid:self.chatter];
        }else{
            [self reportEvent:XCSDPBEventTypeGroupChat bid:self.chatter];
        }
    }
}
- (void)sendVoiceMessage:(EMChatVoice *)voice
{
    [super sendVoiceMessage:voice];
    
    if (!self.isGroup) {
        [self reportEvent:XCSDPBEventTypeSingleChat bid:self.chatter];
    }else{
        
        if (self.isTeacher) {
            [self reportEvent:XCSDPBEventTypeTeacherGroupChat bid:self.chatter];
        }else{
            [self reportEvent:XCSDPBEventTypeGroupChat bid:self.chatter];
        }
    }
}
- (void)sendVideoMessage:(EMChatVideo *)video
{
    [super sendVideoMessage:video];
    
    if (!self.isGroup) {
        [self reportEvent:XCSDPBEventTypeSingleChat bid:self.chatter];
    }else{
        
        if (self.isTeacher) {
            [self reportEvent:XCSDPBEventTypeTeacherGroupChat bid:self.chatter];
        }else{
            [self reportEvent:XCSDPBEventTypeGroupChat bid:self.chatter];
        }
    }
}

- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        if (_isNormalBack) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}
//跳转到详情
- (void)clickAvatarWithUserId:(NSString *)userId
{
    if([userId isEqualToString:KTXCustomerChatter] && !self.isGroup)
    {
        return;
    }
    ParentsDetailViewController *parentsDetail = [[ParentsDetailViewController alloc] initWithIdentity:[userId longLongValue]];
    parentsDetail.emChatterId = userId;
    [self.navigationController pushViewController:parentsDetail animated:YES];
}
//点击群管理界面
- (void)onClickGroupManagerButton
{
//    NSLog(@"点击了群管理按钮");
    BOOL isParent = [TXSystemManager sharedManager].isParentApp;
    GroupDetailViewController *groupDetail = [[GroupDetailViewController alloc] initWithParent:isParent groupId:self.chatter];
    [self.navigationController pushViewController:groupDetail animated:YES];
}
//查看个人信息
- (void)onClickPersonalInfoButton
{
    ParentsDetailViewController *parentsDetail = [[ParentsDetailViewController alloc] initWithIdentity:[self.chatter longLongValue]];
    parentsDetail.emChatterId = self.chatter;
    [self.navigationController pushViewController:parentsDetail animated:YES];
}
//下拉加载更多功能
- (void)triggleMessageHeaderRefreshing
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(_messageQueue, ^{
//        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        
        EMMessage *firstMessage = [weakSelf.messages firstObject];
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:kPageCount before:firstMessage.timestamp];
        if ([messages count] > 0) {
            [weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
            
            NSArray *formatMessages = [weakSelf formatMessages:messages];
            [weakSelf.msgDataSource insertObjects:formatMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formatMessages count])]];
            NSInteger currentIndex = [formatMessages count];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf endMessageHeaderRefreshing];
                [weakSelf reloadChatViewAndScrollToIndexPath:[NSIndexPath indexPathForRow:currentIndex - 1 inSection:0] animated:NO mustScroll:YES];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf endMessageHeaderRefreshing];
                [weakSelf hideMessageHeaderRefreshingView];
            });
        }
    });

}
//撤回消息
- (void)handleRevokeMessage:(id<TXMessageModelData>)data
{
    EMMessage *message = [data message];
    EMMessageType type = [message messageType];
    BOOL isGroup = NO;
    if (type == eMessageTypeGroupChat) {
        isGroup = YES;
    }
    NSString *from;
    NSString *to;
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (isGroup) {
        //群聊
        if ([[data userId] longLongValue] == currentUser.userId) {
            //当前用户所发
            from = [NSString stringWithFormat:@"%@",@(currentUser.userId)];
            to = message.to;
        }else{
            //其他用户所发
            from = message.to;
            to = message.from;
        }
    }else{
        //单聊
        from = [NSString stringWithFormat:@"%@",@(currentUser.userId)];
        to = message.to;
    }
    [[TXEaseMobHelper sharedHelper] sendRevokeMessageCommandWithReceiver:to isGroup:isGroup messageId:message.messageId from:from];
}
#pragma mark - getter
- (NSMutableArray *)msgDataSource
{
    if (_msgDataSource == nil) {
        _msgDataSource = [NSMutableArray array];
    }
    return _msgDataSource;
}
- (NSDate *)chatTagDate
{
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    return _chatTagDate;
}
- (MessageReadManager *)messageReadManager
{
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}
#pragma mark - private
- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
//            [[EaseMob sharedInstance].chatManager sendHasReadResponseForMessage:message];
        }
    });
}
- (void)markMessagesAsRead:(NSArray*)messages
{
    EMConversation *conversation = self.conversation;
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [conversation markMessageWithId:message.messageId asRead:YES];
            //更新标题
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNavigationLeftButtonView];
            });
        }
    });
}
#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"kRouterEventTextBubbleDoubleTapEventName"]) {
        id<TXMessageModelData> model = [userInfo objectForKey:@"message"];
        TXMessageZoomViewController *zoomVc = [[TXMessageZoomViewController alloc] initWithDisplayMessage:[model text]];
        zoomVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:zoomVc animated:YES completion:nil];
    }
    else if ([eventName isEqualToString:@"kRouterEventAudioBubbleTapEventName"]) {
        id<TXMessageModelData> model = [userInfo objectForKey:@"message"];
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:@"kRouterEventImageBubbleTapEventName"]) {
        id<TXMessageModelData> model = [userInfo objectForKey:@"message"];
        [self chatImageCellBubblePressed:model];
    }else if ([eventName isEqualToString:@"kRouterEventRetryButtonTapEventName"]) {
        id<TXMessageModelData> model = [userInfo objectForKey:@"message"];
        //弹出提示
        [self showNormalSheetWithTitle:nil items:@[@"重新发送",@"删除"] clickHandler:^(NSInteger index) {
            NSIndexPath *indexPath = userInfo[@"indexPath"];
            if (index == 0) {
                //重新发送
                if (([model status] != eMessageDeliveryState_Failure) && ([model status] != eMessageDeliveryState_Pending)) {
                    return;
                }
                [model setStatus:eMessageDeliveryState_Delivering];
                id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
                [chatManager asyncResendMessage:[model message] progress:nil];
                [self.messageTableView beginUpdates];
                [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.messageTableView endUpdates];
            }else if (index == 1) {
                //删除
                [self.conversation removeMessage:[model message]];
                if (indexPath.row < [self.msgDataSource count]) {
                    [self.msgDataSource removeObjectAtIndex:indexPath.row];
                }
                [self.messageTableView beginUpdates];
                [self.messageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.messageTableView endUpdates];
            }
        } completion:nil];
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重新发送",@"删除", nil];
//        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        actionSheet.destructiveButtonIndex = 1;
//        [actionSheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//            NSIndexPath *indexPath = userInfo[@"indexPath"];
//            if (buttonIndex == 0) {
//                //重新发送
//                if (([model status] != eMessageDeliveryState_Failure) && ([model status] != eMessageDeliveryState_Pending)) {
//                    return;
//                }
//                [model setStatus:eMessageDeliveryState_Delivering];
//                id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
//                [chatManager asyncResendMessage:[model message] progress:nil];
//                [self.messageTableView beginUpdates];
//                [self.messageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                [self.messageTableView endUpdates];
//            }else if (buttonIndex == 1) {
//                //删除
//                [self.conversation removeMessage:[model message]];
//                if (indexPath.row < [self.msgDataSource count]) {
//                    [self.msgDataSource removeObjectAtIndex:indexPath.row];
//                }
//                [self.messageTableView beginUpdates];
//                [self.messageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                [self.messageTableView endUpdates];
//            }
//        }];

    }else if ([eventName isEqualToString:@"kRouterEventTextBubbleClickLinkURLEventName"]){
        //跳转url
        NSString *urlString = [userInfo objectForKey:@"url"];
        PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:urlString];
        [self.navigationController pushViewController:detailVc animated:YES];
    }else if ([eventName isEqualToString:@"kRouterEventVideoBubbleTapEventName"]) {
        //视频
        id<TXMessageModelData> model = [userInfo objectForKey:@"message"];
        [self chatVideoCellBubblePressed:model];
    }else if ([eventName isEqualToString:@"kRouterEventShareTapEventName"]) {
        NSString *url = [userInfo objectForKey:@"shareUrl"];
        NSString *title = [userInfo objectForKey:@"shareTitle"];
        NSString *imageUrl = [userInfo objectForKey:@"shareImageUrl"];
        InnerPublishDetailController *detailVC = [[InnerPublishDetailController alloc] initWithLinkURLString:url];
        detailVC.articleTitle = title;
        detailVC.coverImageUrl = imageUrl;
        
//        PublishmentDetailViewController *detailVC = [[PublishmentDetailViewController alloc] initWithLinkURLString:url];
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    //    else if([eventName isEqualToString:kResendButtonTapEventName]){
    //    }else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
    //        [self chatVideoCellPressed:model];
    //    }
}
// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(id<TXMessageModelData>)model
{
    id <IEMFileMessageBody> body = [[model message].messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        //        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        NSLog(@"语音下载中");
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        //        [self showHint:NSLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        NSLog(@"语音下载失败");
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if ([model messageMediaType] == TXBubbleMessageMediaTypeVoice) {
        //发送已读回执
        if ([self shouldAckMessage:model.message read:YES])
        {
            [self sendHasReadResponseForMessages:@[model.message]];
        }
        if ([self shouldMarkMessageAsRead:model.message read:YES])
        {
            [self markMessagesAsRead:@[model.message]];
        }
        __weak TXParentChatViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(id<TXMessageModelData> prevAudioModel, id<TXMessageModelData> currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.messageTableView reloadData];
            }
        }];
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak TXParentChatViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:[model chatVoice].localPath completion:^(NSError *error) {
                if (!error) {
                    [weakSelf.messageReadManager stopMessageAudioModel];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.messageTableView reloadData];
                        weakSelf.isPlayingAudio = NO;
                    });
                }else{
                    NSLog(@"error:%@",error);
                }
                TXAsyncRunInMain(^{
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}
// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(id<TXMessageModelData>)model
{
    __weak TXParentChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model messageMediaType] == TXBubbleMessageMediaTypePhoto) {
        id<IEMMessageBody> messageBody = [[[model message] messageBodies] firstObject];
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                //发送已读回执
                if ([self shouldAckMessage:model.message read:YES])
                {
                    [self sendHasReadResponseForMessages:@[model.message]];
                }
                NSString *localPath = [model message] == nil ? [model imageLocalPath] : [imageBody localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
//                    self.isScrollToBottom = NO;
                    if (image)
                    {
//                        [self.messageReadManager showBrowserWithImages:@[image]];
                        TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
                        //设置图片数组
                        NSMutableArray *listArray = [NSMutableArray array];
                        NSInteger index = 0;
                        NSArray *allMessageArray = [self.msgDataSource copy];
                        for (id<TXMessageModelData> item in allMessageArray) {
                            if ([item messageMediaType] == TXBubbleMessageMediaTypePhoto) {
                                //添加进数组
                                EMMessage *photoMessage = [item message];
                                [listArray addObject:photoMessage];
                                if ([[model message].messageId isEqualToString:[photoMessage messageId]]) {
                                    index = [listArray indexOfObject:photoMessage];
                                }
                            }
                        }
                        //设置当前的index
                        [browerVc showBrowserWithImages:listArray currentIndex:index];
                        browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                        [weakSelf presentViewController:browerVc animated:YES completion:nil];
//                        [weakSelf.navigationController pushViewController:browerVc animated:YES];

                    }
                    return ;
                }
            }
            
            TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
            //设置图片数组
            NSMutableArray *listArray = [NSMutableArray array];
            NSInteger index = 0;
            NSArray *allMessageArray = [self.msgDataSource copy];
            for (id<TXMessageModelData> item in allMessageArray) {
                if ([item messageMediaType] == TXBubbleMessageMediaTypePhoto) {
                    //添加进数组
                    EMMessage *photoMessage = [item message];
                    [listArray addObject:photoMessage];
                    if ([[model message].messageId isEqualToString:[photoMessage messageId]]) {
                        index = [listArray indexOfObject:photoMessage];
                    }
                }
            }
            //设置当前的index
            [browerVc showBrowserWithImages:listArray currentIndex:index];
            browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [weakSelf presentViewController:browerVc animated:YES completion:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }
            } onQueue:nil];
        }
    }
}
//视频的bubble被点击
-(void)chatVideoCellBubblePressed:(id<TXMessageModelData>)model
{
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model messageMediaType] == TXBubbleMessageMediaTypeVideo) {
        id<IEMMessageBody> messageBody = [[[model message] messageBodies] firstObject];
        EMImageMessageBody *videoBody = (EMImageMessageBody *)messageBody;
        if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
        {
            NSString *localPath = [model message] == nil ? [model videoLocalPath] : [[[model message].messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0)
            {
                //发送已读回执
                if ([self shouldAckMessage:model.message read:YES])
                {
                    [self sendHasReadResponseForMessages:@[model.message]];
                }
                [self playVideoWithLocalPath:localPath];
                return;
            }
        }
        
        WEAKSELF
        [MBProgressHUD showHUDAddedTo:self.view title:@"视频加载中" animated:YES];
        [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
            STRONGSELF
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (!error) {
                //发送已读回执
                if ([weakSelf shouldAckMessage:model.message read:YES])
                {
                    [weakSelf sendHasReadResponseForMessages:@[model.message]];
                }
                NSString *localPath = (aMessage == nil ? [model videoLocalPath] : [[aMessage.messageBodies firstObject] localPath]);
                if (localPath && localPath.length > 0) {
                    [weakSelf playVideoWithLocalPath:localPath];
                }
            }else{
                [strongSelf showFailedHudWithTitle:@"视频加载失败"];
            }
        } onQueue:nil];
        
    }
    
}
- (void)playVideoWithLocalPath:(NSString *)localPath
{
    //    NSURL *url = [NSURL fileURLWithPath:[model videoLocalPath]];
    //    NSURL *url = [NSURL fileURLWithPath:localPath];
    TXVideoPreviewViewController *videoVc = [[TXVideoPreviewViewController alloc] initWithVideoURLString:localPath];
    videoVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:videoVc animated:YES completion:nil];
}
#pragma mark - EMCDDeviceManagerDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - IChatManagerDelegate
//会话列表信息刷新
- (void)didUpdateConversationList
{
    [self fetchMessageFromLocalDBWithIsScrollToBottom:YES];
}
//接收到发送消息的回调
-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [self.msgDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[TXMessage class]])
         {
             TXMessage *model = (TXMessage*)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 model.status = message.deliveryState;
                 *stop = YES;
             }
         }
     }];
    [self reloadChatViewAndScrollToIndexPath:nil animated:NO mustScroll:NO];
}

- (void)didReceiveHasReadResponse:(EMReceipt*)receipt
{
    [self.msgDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[TXMessage class]])
         {
             TXMessage *model = (TXMessage*)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isReadAcked = YES;
                 *stop = YES;
             }
         }
     }];
    [self reloadChatViewAndScrollToIndexPath:nil animated:NO mustScroll:NO];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageTableView reloadData];
    });
//    __weak TXParentChatViewController *weakSelf = self;
//    dispatch_async(_messageQueue, ^{
//        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
//        {
//            for (int i = 0; i < weakSelf.msgDataSource.count; i ++) {
//                id object = [weakSelf.msgDataSource objectAtIndex:i];
//                if ([object isKindOfClass:[TXMessage class]]) {
//                    TXMessage *model = (TXMessage *)object;
//                    if ([message.messageId isEqualToString:model.messageId]) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf.messageTableView beginUpdates];
//                            [weakSelf.msgDataSource replaceObjectAtIndex:i withObject:model];
//                            [weakSelf.messageTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//                            [weakSelf.messageTableView endUpdates];
//                        });
//                        break;
//                    }
//                }
//            }
//        }
//    });
}
//消息附件状态更新
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}
- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
//    NSLog(@"didFetchingMessageAttachment: %f", progress);
}
//接收到消息
-(void)didReceiveMessage:(EMMessage *)message
{
//    NSInteger unReadNumber = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
//    NSLog(@"当前未读数:%@",@(unReadNumber));
    if ([self.conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessage:message isFromSelf:NO];
        if ([self shouldAckMessage:message read:NO])
        {
            [self sendHasReadResponseForMessages:@[message]];
        }
        if ([self shouldMarkMessageAsRead:message read:NO])
        {
            [self markMessagesAsRead:@[message]];
        }
    }else{
        //更新标题
        [self updateNavigationLeftButtonView];
    }
//    DDLogDebug(@"在线message:%@", message);
}
//接收到离线消息
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if (![offlineMessages count]) {
        return;
    }
//    NSLog(@"离线非透传消息:%@",offlineMessages);
    BOOL isShouldUpdateTitle = NO;
    for (NSInteger i = 0; i < [offlineMessages count]; i++) {
        EMMessage *message = offlineMessages[i];
        if ([self.conversation.chatter isEqualToString:message.conversationChatter]) {
//            [self addMessage:message];
            if ([self shouldAckMessage:message read:NO])
            {
                [self sendHasReadResponseForMessages:@[message]];
            }
            if ([self shouldMarkMessageAsRead:message read:NO])
            {
                [self markMessagesAsRead:@[message]];
            }
        }else{
            isShouldUpdateTitle = YES;
        }
    }
    if (isShouldUpdateTitle) {
        //更新标题
        [self updateNavigationLeftButtonView];
    }
//    [self fetchMessageFromLocalDBWithIsScrollToBottom:NO];
    DDLogDebug(@"离线messages:%@", offlineMessages);
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [self.conversation.chatter isEqualToString:conversationChatter]) {
        
        WEAKSELF
        for (int i = 0; i < self.msgDataSource.count; i ++) {
            id object = [self.msgDataSource objectAtIndex:i];
            if ([object isKindOfClass:[TXMessage class]]) {
                TXMessage *currentModel = [self.msgDataSource objectAtIndex:i];
                EMMessage *currMsg = [currentModel message];
                if ([messageId isEqualToString:currMsg.messageId]) {
                    currMsg.deliveryState = eMessageDeliveryState_Failure;
                    currentModel.status = eMessageDeliveryState_Failure;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        STRONGSELF
                        if (strongSelf) {
                            [strongSelf.messageTableView beginUpdates];
                            [strongSelf.msgDataSource replaceObjectAtIndex:i withObject:currentModel];
                            [strongSelf.messageTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [strongSelf.messageTableView endUpdates];
                        }
                    });
                    
                    break;
                }
            }
        }
    }
}

- (void)didInterruptionRecordAudio
{
//    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [self.conversation markAllMessagesAsRead:YES];
    
//    [self stopAudioPlayingWithChangeCategory:YES];
}
//撤回了消息
- (void)didRevokeMessageIds:(NSArray *)messageIds
                       from:(NSString *)from
                         to:(NSString *)to
                    isGroup:(BOOL)isGroup
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

    if (revokeChatter && [revokeChatter isEqualToString:self.chatter]) {
        for (NSString *messageId in messageIds) {
            NSInteger index = NSNotFound;
            for (NSInteger i = 0; i < [self.msgDataSource count]; i++) {
                TXMessage *msg = self.msgDataSource[i];
                NSString *msgID = [msg messageId];
                if (msgID && [msgID isEqualToString:messageId]) {
                    index = i;
                    break;
                }
            }
            if (index != NSNotFound) {
                if (index < [self.msgDataSource count]) {
                    [self.msgDataSource removeObjectAtIndex:index];
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                if ([[self.messageTableView indexPathsForVisibleRows] containsObject:indexPath]) {
                    [self.messageTableView beginUpdates];
                    [self.messageTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.messageTableView endUpdates];
                }
            }
        }
    }
}
#pragma mark - TXChatTableViewControllerDataSource methods
- (NSInteger)numberOfMessages
{
    return [self.msgDataSource count];
}
- (id<TXMessageModelData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.msgDataSource count]) {
        return nil;
    }
    id<TXMessageModelData> item = self.msgDataSource[indexPath.row];
    return item;
}
//是否禁言
- (BOOL)isForbiddenSpeak
{
    return [[TXContactManager shareInstance] getGagStatusByGroupId:_chatter];
}
#pragma mark - TXChatTableViewControllerDelegate methods
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [self.msgDataSource count]) {
        return 0;
    }
    TXMessage *item = self.msgDataSource[indexPath.row];
    
    if (item.bubbleMessageType == TXBubbleMessageTypeOutgoing) {
        return item.rowHeight + 20;
    }
    
    return item.rowHeight;
}
//展示禁止发言的HUD
- (void)showForbiddenSpeakTipHUD
{
    [self showFailedHudWithTitle:@"群聊功能暂不可用"];
//    [self showAlertViewWithMessage:@"群聊功能暂不可用，请您联系本班老师。" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
}

#pragma mark - 诊断 和客服聊天用

-(void)updateReportToServer
{
    @weakify(self);
    [[TXReportManager shareInstance] updateLoggs:self complete:^(NSError *error, NSString *reportUrl) {
        @strongify(self);
        if(!error)
        {
            [self sendTextMessage:[NSString stringWithFormat:@"诊断信息已上传"]];
        }
        NSLog(@"error:%@", error);
    }];
}



@end
