//
//  TXChatViewController.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatViewController.h"
#import "TXMessageTableViewCellOutgoing.h"
#import "TXMessageTableViewCellIncoming.h"
#import "TXChatSendHelper.h"
#import "TXMessageInputView.h"
#import <MJRefresh.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIImage+Utils.h>
#import "ELCAlbumPickerController.h"
#import "ELCImagePickerController.h"
#import "AppDelegate.h"
#import "NSString+MessageInputView.h"
#import "EMCDDeviceManager+Microphone.h"
#import "NSObject+EXTParams.h"
#import "TXSystemManager.h"
#import "VideoRecordViewController.h"

@interface TXChatViewController ()
<UITableViewDelegate,
UITableViewDataSource,
XHMessageInputViewDelegate,
TXMessageTableViewCellDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
ELCImagePickerControllerDelegate,
TXVideoRecordViewControllerDelegate,
TXImagePickerControllerDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_revokeMenuItem;
//    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
}
//记录旧的textView contentSize Heigth
//@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
//判断是否用户手指滚动
//@property (nonatomic, assign) BOOL isUserScrolling;

@end

@implementation TXChatViewController

#pragma mark - Life Cycle
- (void)dealloc
{
    _dataSource = nil;
    _delegate = nil;
    self.messageTableView.delegate = nil;
    self.messageTableView.dataSource = nil;
    _msgInputView.associatedScrollView = nil;
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //默认聊天的用户都是存在的
        _existChatUser = YES;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        //默认聊天的用户都是存在的
        _existChatUser = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 设置关联的scrollView
    self.msgInputView.associatedScrollView = self.messageTableView;
    //tabbar效果
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //结束编辑
    [self.msgInputView endEdit];
}
//初始化
- (void)setup
{
    self.view.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //创建自定义导航标题
    [self createCustomNavBar];
    //加载聊天tableview视图
    [self setupMessageTableView];
    //添加工具栏视图
    [self setupChatToolBarView];
    //添加下拉加载更多功能
    [self setupPullDownRefreshView];
}

#pragma mark - UI视图
//创建聊天列表视图
- (void)setupMessageTableView
{
    _messageTableView = [[TXMessageTableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY) style:UITableViewStylePlain];
    _messageTableView.backgroundColor = [UIColor clearColor];
    _messageTableView.dataSource = self;
    _messageTableView.delegate = self;
    _messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_messageTableView];
    //添加点击手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTapGestureHandled:)];
    tapGesture.numberOfTapsRequired = 1;
    [_messageTableView addGestureRecognizer:tapGesture];
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onMessageBubbleLongPressGestureHandled:)];
    longPress.minimumPressDuration = .5f;
    [longPress requireGestureRecognizerToFail:tapGesture];
    [_messageTableView addGestureRecognizer:longPress];
}
//创建聊天工具栏视图
- (void)setupChatToolBarView
{
    // 设置Message TableView 的bottom edg
    [self setTableViewInsetsWithBottomValue:kChatToolBarHeight];
    //创建输入框组件
    _msgInputView = [[TXMessageInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - kChatToolBarHeight, CGRectGetWidth(self.view.frame), kChatToolBarHeight)];
    _msgInputView.delegate = self;
    _msgInputView.isVoiceSupport = YES;
    _msgInputView.isMultiMediaSupport = YES;
    _msgInputView.shouldLimitInputCharacterCount = NO;
    _msgInputView.associatedScrollView = self.messageTableView;
    _msgInputView.contentViewController = self;
    _msgInputView.shouldLimitInputCharacterCount = YES;
    _msgInputView.maxInputCharacterCount = 500;
    [_msgInputView setupView];
    [self.view addSubview:_msgInputView];
    [self.view bringSubviewToFront:_msgInputView];
}
//集成刷新控件
- (void)setupPullDownRefreshView
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _messageTableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject triggleMessageHeaderRefreshing];
    }];
}
#pragma mark - 手势
//单击手势
- (void)onSingleTapGestureHandled:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"点击了");
        [self.msgInputView endEdit];
    }
}
//长按手势
- (void)onMessageBubbleLongPressGestureHandled:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [_dataSource numberOfMessages] > 0) {
//        NSLog(@"长按了");
        CGPoint location = [recognizer locationInView:_messageTableView];
        NSIndexPath * indexPath = [_messageTableView indexPathForRowAtPoint:location];
        id<TXMessageModelData> item = [_dataSource messageForRowAtIndexPath:indexPath];
        if (![item isTimeMessage] && ![item isTipMessage]) {
//            if ([item messageMediaType] == TXBubbleMessageMediaTypeText) {
//                
//            }
            TXMessageTableViewCell *cell = (TXMessageTableViewCell *)[_messageTableView cellForRowAtIndexPath:indexPath];
            CGPoint convertPoint = [_messageTableView convertPoint:location toView:cell];
            BOOL isContainPoint = CGRectContainsPoint(cell.bubbleView.frame, convertPoint);
            if (isContainPoint) {
                //                NSLog(@"包含该点击位置");
                [cell becomeFirstResponder];
                _longPressIndexPath = indexPath;
                [self showMenuView:cell.bubbleView andIndexPath:indexPath messageData:item];
//                //修改背景色
//                cell.bubbleView.backgroundColor = [UIColor grayColor];
            }
        }
    }
}
//弹出菜单视图
- (void)showMenuView:(UIView *)showInView
        andIndexPath:(NSIndexPath *)indexPath
         messageData:(id<TXMessageModelData>)data
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (_revokeMenuItem == nil) {
        _revokeMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeMessageMenuActionHandled:)];
    }
//    if (_deleteMenuItem == nil) {
//        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
//    }
    if ([data bubbleMessageType] == TXBubbleMessageTypeIncoming) {
        if ([TXSystemManager sharedManager].isParentApp) {
            if ([data messageMediaType] != TXBubbleMessageMediaTypeText) {
                return;
            }
            [_menuController setMenuItems:@[_copyMenuItem]];
        }else {
            BOOL isGroup = [data isGroupChat];
            TXUser *msgUser = [[TXChatClient sharedInstance] getUserByUserId:[[data userId] longLongValue] error:nil];
            TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
            if (msgUser && isGroup && (msgUser.userType == TXPBUserTypeParent || (currentUser && (currentUser.positionId == 1 || currentUser.positionId == 2)))) {
                /*发消息的用户是家长,有权限删除该消息*/
                /*园长有权限删除其他用户发的消息,1是园长，2是副园长*/
                //关联消息data
                [_revokeMenuItem setTXExtParams:data forKey:@"msgData"];
                if ([data messageMediaType] != TXBubbleMessageMediaTypeText) {
                    [_menuController setMenuItems:@[_revokeMenuItem]];
                }else{
                    [_menuController setMenuItems:@[_copyMenuItem,_revokeMenuItem]];
                }
            }else{
                if ([data messageMediaType] != TXBubbleMessageMediaTypeText) {
                    return;
                }
                //无权限删除该消息
                [_menuController setMenuItems:@[_copyMenuItem]];
            }
        }
    }else{
        //关联消息data
        [_revokeMenuItem setTXExtParams:data forKey:@"msgData"];
        if ([data messageMediaType] != TXBubbleMessageMediaTypeText) {
            [_menuController setMenuItems:@[_revokeMenuItem]];
        }else{
            [_menuController setMenuItems:@[_copyMenuItem,_revokeMenuItem]];
        }
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}
//复制内容
- (void)copyMenuAction:(UIMenuItem *)item
{
    if (_longPressIndexPath.row > 0) {
        id<TXMessageModelData> item = [_dataSource messageForRowAtIndexPath:_longPressIndexPath];
        if ([item messageMediaType] == TXBubbleMessageMediaTypeText) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [item text];
        }
    }
    _longPressIndexPath = nil;
}
//撤回消息
- (void)revokeMessageMenuActionHandled:(UIMenuItem *)item
{
    id msgData = [_revokeMenuItem extParamForKey:@"msgData"];
    if ([msgData conformsToProtocol:@protocol(TXMessageModelData)]) {
        //消息本体
        id<TXMessageModelData> msg = msgData;
        [self handleRevokeMessage:msg];
    }
}
//- (void)deleteMenuAction:(UIMenuItem *)item
//{
//    NSLog(@"删除cell");
//}
#pragma mark - 下拉刷新功能
//下拉加载更多功能
- (void)triggleMessageHeaderRefreshing
{
    
}
//结束下拉加载刷新
- (void)endMessageHeaderRefreshing
{
    [_messageTableView.header endRefreshing];
}
//隐藏头部的刷新控件
- (void)hideMessageHeaderRefreshingView
{
    [_messageTableView.header setHidden:YES];
}
#pragma mark - 发消息
- (NSDictionary *)messageExtUserInfo
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSAssert(currentUser, @"用户为空");
    NSDictionary *extDict;
    if ([self.conversation.chatter isEqualToString:KTXCustomerChatter]) {
        extDict = @{@"name" : currentUser.nickname,
                    @"weichat" : @{
                            @"visitor" : @{@"trueName" : currentUser.nickname,
                                           @"userNickname" : currentUser.nickname,
                                           @"phone" : currentUser.mobilePhoneNumber},
                            },
                    };
    }else {
        extDict = @{@"name": currentUser.nickname};
    }
    return extDict;
}
//过滤qq表情开头的\x14等字符
- (NSString *)filterString:(NSString *)str
{
    NSString *aText = str;
    NSString *xmlInvalidPattern = @"[\\x00-\\x08\\x0b\\x0c\\x0e-\\x1f]";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:xmlInvalidPattern options:NSRegularExpressionCaseInsensitive error:&error ];
    
    NSArray* matches = [regex matchesInString:aText options:NSMatchingReportCompletion range:NSMakeRange(0, [aText length])];
    
    NSString *charactersInString = @"";
    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [match range];
        NSString *subStr = [aText substringWithRange:matchRange];
        if ([charactersInString rangeOfString:subStr].location == NSNotFound) {
            charactersInString = [charactersInString stringByAppendingString:subStr];
        }
    }
    if (charactersInString.length > 0) {
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:charactersInString];
        aText = [[aText componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString:@""];
    }
    return aText;
}
- (void)sendTextMessage:(NSString *)textMessage
{
    NSString *text = [self filterString:textMessage];
    EMMessage *tempMessage = [TXChatSendHelper sendTextMessageWithString:text toUsername:_conversation.chatter isChatGroup:_isGroup requireEncryption:NO ext:[self messageExtUserInfo]];
//    EMMessage *tempMessage = [TXChatSendHelper sendTextMessageWithString:textMessage toUsername:_conversation.chatter isChatGroup:_isGroup requireEncryption:NO ext:[self messageExtUserInfo]];
    [self addMessage:tempMessage];
    //友盟统计
    if ([NSString stringContainsEmoji:text]) {
    [MobClick event:@"chat_sendMsg" label:self.isGroup ? @"在群里发送了包含表情的消息" : @"单聊中发送了包含表情的消息"];
    }else{
        [MobClick event:@"chat_sendMsg" label:self.isGroup ? @"在群里发送纯文本的消息" : @"单聊中发送了纯文本的消息"];
    }
}
- (void)sendImageMessage:(UIImage *)image
{
    EMMessage *tempMessage = [TXChatSendHelper sendImageMessageWithImage:image toUsername:_conversation.chatter isChatGroup:_isGroup requireEncryption:NO ext:[self messageExtUserInfo]];
    [self addMessage:tempMessage];
    //友盟统计
    [MobClick event:@"chat_sendMsg" label:self.isGroup ? @"在群里发送了图片消息" : @"单聊中发送了图片消息"];
}
- (void)sendVoiceMessage:(EMChatVoice *)voice
{
    EMMessage *tempMessage = [TXChatSendHelper sendVoice:voice toUsername:_conversation.chatter isChatGroup:_isGroup requireEncryption:NO ext:[self messageExtUserInfo]];
    [self addMessage:tempMessage];
    //友盟统计
    [MobClick event:@"chat_sendMsg" label:self.isGroup ? @"在群里发送了语音消息" : @"单聊中发送了语音消息"];
}
- (void)sendVideoMessage:(EMChatVideo *)video
{
    EMMessage *tempMessage = [TXChatSendHelper sendVideo:video toUsername:_conversation.chatter isChatGroup:_isGroup requireEncryption:NO ext:[self messageExtUserInfo]];
    [self addMessage:tempMessage];
    //友盟统计
    [MobClick event:@"chat_sendMsg" label:self.isGroup ? @"在群里发送了视频消息" : @"单聊中发送了视频消息"];
}
#pragma mark - public
-(void)addMessage:(EMMessage *)message
{
    //添加消息并发送时子类继承
}
- (void)reloadChatViewAndScrollToIndexPath:(NSIndexPath *)indexPath
                                  animated:(BOOL)animated
                                mustScroll:(BOOL)mustScroll
{
    [_messageTableView reloadData];
    //如果传递了indexpath就滚动该位置,否则只刷新
    if (indexPath && indexPath.row < [self.dataSource numberOfMessages]) {
        CGFloat invisibleHeight = _messageTableView.contentSize.height - _messageTableView.contentOffset.y - _messageTableView.bounds.size.height;
        //如果已经滑过的高度小于3/4屏幕，就滚动到最底部
        if (mustScroll) {
            [_messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:animated ?  UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:animated];
        }else{
            if (animated) {
                if (invisibleHeight <= _messageTableView.bounds.size.height * 3 / 4) {
                    [_messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
                }
            }else{
                [_messageTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
        }
    }
}
- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
//    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
//    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
//    {
//        return NO;
//    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (BOOL)shouldMarkMessageAsRead:(EMMessage *)message read:(BOOL)read
{
//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
//    {
//        return NO;
//    }
    
//    id<IEMMessageBody> body = [message.messageBodies firstObject];
//    if (body.messageBodyType == eMessageBodyType_Voice &&
//        !read)
//    {
//        return NO;
//    }

    return YES;
}
//点击头像的回调方法
- (void)clickAvatarWithUserId:(NSString *)userId
{
    
}
#pragma mark - TXMessageEmotionViewDelegate methods
//发送文本
- (void)didSendTextAction:(NSString *)text {
    //判断是否是空消息
    NSString *trimString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    if ([_dataSource isForbiddenSpeak]) {
        //被禁止发言
        [_delegate showForbiddenSpeakTipHUD];
    }else{
        if ([trimString length] == 0) {
            //Alert提醒不能输入空白消息
            [self showFailedHudWithTitle:@"不能发送空白消息"];
        }else{
            //发送文字
            [self sendTextMessage:text];
//            //清空已发送文本
//            self.msgInputView.inputTextView.text = @"";
        }
    }
}
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if ([_dataSource isForbiddenSpeak]) {
        [_delegate showForbiddenSpeakTipHUD];
    }else{
        if (text.length > 0) {
            [self sendTextMessage:text];
//            //清空已发送文本
//            self.msgInputView.inputTextView.text = @"";
        }
    }
}
//点击了多媒体按钮
- (void)clickMoreMenuButtonWithType:(TXMessageMoreMenuType)type
{
    if ([_dataSource isForbiddenSpeak]) {
        [_delegate showForbiddenSpeakTipHUD];
        return;
    }
    switch (type) {
        case TXMessageMoreMenuTypePhoto: {
            //照片
            [[TXSystemManager sharedManager] requestPhotoPermissionWithBlock:^(BOOL photoGranted) {
                if (photoGranted) {
                    //已授权相册访问
                    [self showImagePickerController];
                }else{
                    //未授权相册访问
                    [self showPhotoPermissionDeniedAlert];
                }
            }];
            break;
        }
        case TXMessageMoreMenuTypeTakePicture: {
            //拍照
            [[TXSystemManager sharedManager] requestCameraPermissionWithBlock:^(BOOL cameraGranted) {
                TXAsyncRunInMain(^{
                    if (cameraGranted) {
                        //已授权
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.allowsEditing = NO;
                        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
                        imagePicker.delegate = self;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                    }else{
                        //未授权
                        [self showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:YES];
                    }
                });
            }];
            
            break;
        }
        case TXMessageMoreMenuTypeTakeVideo: {
            //视频
            [[TXSystemManager sharedManager] requestCameraAndMicrophonePermissionWithBlock:^(BOOL cameraGranted, BOOL microphoneGranted) {
                TXAsyncRunInMain(^{
                    if (cameraGranted && microphoneGranted) {
                        //已授权
                        VideoRecordViewController *recordVc = [[VideoRecordViewController alloc] init];
                        recordVc.delegate = self;
                        recordVc.showType = TXVideoRecordVCShowType_Present;
                        [self presentViewController:recordVc animated:YES completion:nil];
                    }else{
                        //未授权
                        [self showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:microphoneGranted];
                    }
                });
            }];
        }
            break;
        default: {
            break;
        }
    }
}
//判断是否允许访问麦克风
- (BOOL)checkIsMicrophoneAvailable
{
    if (![[EMCDDeviceManager sharedInstance] emCheckMicrophoneAvailability]) {
        ButtonItem *setItem = [ButtonItem itemWithLabel:@"去设置" andTextColor:kColorBlack action:^{
            NSLog(@"打开设置");
            TXAsyncRunInMain(^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            });
        }];
        [self showAlertViewWithMessage:@"没有权限访问您的麦克风,请到“设置-隐私-麦克风”里把“乐学堂”的开关打开即可" andButtonItems:setItem, nil];
        return NO;
    }
    return YES;
}
//是否允许录音
- (BOOL)canStartRecordVoiceAction
{
    if ([_dataSource isForbiddenSpeak]) {
        [_delegate showForbiddenSpeakTipHUD];
        return NO;
    }
    return YES;
}
//结束语音录制并发送
- (void)finishVoiceRecordWithFile:(NSString *)filePath displayName:(NSString *)displayName duration:(NSInteger)duration
{
    //判断时间是否太短
    if (duration < 1) {
        [self showFailedHudWithTitle:@"说话时间太短"];
        return;
    }
    EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:filePath displayName:displayName];
    voice.duration = duration;
    [self sendVoiceMessage:voice];
}
//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow
{
    [self setTableViewInsetsWithBottomValue:bottom];
    if (isShow) {
        [self scrollToBottomAnimated:NO];
    }
}
#pragma mark - Scroll Message TableView Helper Method
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.messageTableView.contentInset = insets;
    self.messageTableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger rows = [self.dataSource numberOfMessages];
    NSArray *visibleRows = [self.messageTableView indexPathsForVisibleRows];
    if (rows > 0 && visibleRows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}
#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.msgInputView associatedScrollViewWillBeginDragging];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource numberOfMessages];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TXMessageModelData> item = [_dataSource messageForRowAtIndexPath:indexPath];
    if ([item bubbleMessageType] == TXBubbleMessageTypeOutgoing) {
        static NSString *outgoingCellIdentifier = @"outgoingCellIdentifier";
        TXMessageTableViewCellOutgoing *cell = [tableView dequeueReusableCellWithIdentifier:outgoingCellIdentifier];
        if (!cell) {
            cell = [[TXMessageTableViewCellOutgoing alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:outgoingCellIdentifier width:CGRectGetWidth(tableView.frame)];
            cell.cellDelegate = self;
            cell.isGroup = self.isGroup;
        }
        cell.indexPath = indexPath;
        cell.messageData = item;
        return cell;
    }
    static NSString *incomingCellIdentifier = @"incomingCellIdentifier";
    TXMessageTableViewCellIncoming *cell = [tableView dequeueReusableCellWithIdentifier:incomingCellIdentifier];
    if (!cell) {
        cell = [[TXMessageTableViewCellIncoming alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:incomingCellIdentifier width:CGRectGetWidth(tableView.frame)];
        cell.cellDelegate = self;
        cell.isGroup = self.isGroup;
    }
    cell.indexPath = indexPath;
    cell.messageData = item;
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegate heightForRowAtIndexPath:indexPath];
}
#pragma mark - TXMessageTableViewCellDelegate methods
- (void)onAvatarImageTappedWithMessageData:(id<TXMessageModelData>)data
{
    NSString *userId = [data userId];
    [self clickAvatarWithUserId:userId];
}
#pragma mark - TXVideoRecordViewControllerDelegate
- (void)recordFinishedWithVideoURL:(NSURL *)url
{
    EMChatVideo *video = [[EMChatVideo alloc] initWithFile:[url relativePath] displayName:@"video.mp4"];
    [self sendVideoMessage:video];
}
#pragma mark - TXImagePickerControllerDelegate methods
- (void)imagePickerController:(TXImagePickerController *)picker didFinishPickingImages:(NSArray *)imageArray
{
    if (imageArray.count) {
        for (UIImage *image in imageArray) {
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kChatMsgImageWidthPixelSize];
            UIImage *processImage = [UIImage scaleImage:image scale:scale];
            [self sendImageMessage:processImage];
        }
    }
    [super didFinishImagePicker:picker];
}
#pragma mark - UIImagePickerControllerDelegate
// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    //处理图片
    CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kChatMsgImageWidthPixelSize];
    UIImage *retImage = [UIImage scaleImage:image scale:scale];
    [self sendImageMessage:retImage];
    //dismiss拍照控制器
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - ELCImagePickerControllerDelegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)infos
{
    if (infos.count) {
        [infos enumerateObjectsUsingBlock:^(NSDictionary *info, NSUInteger idx, BOOL *stop) {
            UIImage *image = info[UIImagePickerControllerOriginalImage];
            CGFloat scale = [UIImage scaleForPickImage:image maxWidthPixelSize:kChatMsgImageWidthPixelSize];
            image = [UIImage scaleImage:image scale:scale];
            [self sendImageMessage:image];
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)elcImagePickerController:(ELCImagePickerController *)picker didSelcetedNumber:(NSInteger)number
{
    if (number > 8) {
        AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
        [appdelegate.window showAlertViewWithMessage:@"最多只能上传9张图片" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
        return NO;
    }
    return YES;
}

@end
