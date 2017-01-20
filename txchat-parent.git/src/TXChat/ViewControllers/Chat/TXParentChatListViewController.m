//
//  TXParentChatListViewController.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXParentChatListViewController.h"
#import "TXChatNotifyConversation.h"
#import "TXChatSwipeCardConversation.h"
#import "TXChatEaseMobConversation.h"
#import "TXChatWXYConversation.h"
#import "TXParentChatViewController.h"
#import "ClassListViewController.h"
#import "ParentNoticeListViewController.h"
#import "GuardianDetailViewController.h"
#import "TXEaseMobHelper.h"
#import "TXNoticeManager.h"
#import <Reachability.h>
#import "TXCacheManage.h"
#import "WXYListViewController.h"
#import "IdentityViewController.h"
#import "TXSystemManager.h"
#import "TXChatGardenSubConversation.h"
#import "TXChatAttendanceConversation.h"
#import "AttendanceViewController.h"
#import "LeaveListViewController.h"
#import "XCSDHomeWorkNotice.h"
#import "HomeWorkListViewController.h"
#import "XCDSDHomeWorkNoticeManager.h"
#import "NSDateFormatter+TuXing.h"
#import "NSDate+TuXing.h"

@interface TXParentChatListViewController ()
<TXChatListDataSource,
TXChatListDelegate,IChatManagerDelegate>
{
    BOOL _isCanAddNotifyData;
    BOOL _isCanAddSwipeCardData;
    BOOL _isCanAddGardenPostData;
    BOOL _isHasAttendanceData;
    BOOL _isCanAddhomeworkNoticeData;
}
@property (nonatomic,strong) NSMutableArray *conversationList;
@property (nonatomic) BOOL headerCounterRequesting;
@property (nonatomic) BOOL headerDepartmentRequesting;

@end

@implementation TXParentChatListViewController

- (void)dealloc{
    [[TXEaseMobHelper sharedHelper] removeEaseMobRefreshObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view.
    _isCanAddNotifyData = ![[[TXSystemManager sharedManager] chatListDataForKey:kChatListNotifyDeleteFlag] boolValue];
    _isCanAddSwipeCardData = ![[[TXSystemManager sharedManager] chatListDataForKey:kChatListSwipeCardDeleteFlag] boolValue];
    _isCanAddGardenPostData = ![[[TXSystemManager sharedManager] chatListDataForKey:kChatListGardenPostDeleteFlag] boolValue];
    _isHasAttendanceData = [[[TXSystemManager sharedManager] chatListDataForKey:kChatListHasAttendanceFlag] boolValue];
    _isCanAddhomeworkNoticeData=![[[TXSystemManager sharedManager] chatListDataForKey:kChatListHomeWorkDeleteFlag] boolValue];
    //教师端添加联系人入口
    if (![TXSystemManager sharedManager].isParentApp) {
        [self.btnRight setImage:[UIImage imageNamed:@"contactIcon"] forState:UIControlStateNormal];
        [self.btnRight addTarget:self action:@selector(onClickTopBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.dataSource = self;
    self.delegate = self;
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChatListNotifyDataSource) name:NOTIFY_RCV_NOTICES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChatListHomeWorkDataSource) name:NOTIFY_RCV_HOMEWORKS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChatListSwipeCardDataSource) name:NOTIFY_RCV_CHECKIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEaseMobReLoginNotification:) name:EaseMobStartLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChatListWXYPostDataSource) name:ChatListFetchNewWXYPostNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGardenSubPostDataSource) name:ChatListRefreshGardenPostNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChatListHomeWorkDataSource) name:HomeWorkFetchNewPostNotification object:nil];// add by mey
    
    //将环信的会话从本地读取
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    //注册环信相关信息回调监听
    [[TXEaseMobHelper sharedHelper] addEaseMobRefreshObserver:self selector:@selector(refreshEaseMobLoginStatus:) type:TXEaseMobRefreshLoginStatusType];
    [[TXEaseMobHelper sharedHelper] addEaseMobRefreshObserver:self selector:@selector(refreshEaseMobChatDataSource) type:TXEaseMobRefreshChatListType];
    [[TXEaseMobHelper sharedHelper] addEaseMobRefreshObserver:self selector:@selector(updateNetworkStateViewVisible:) type:TXEaseMobRefreshNetworkChangeType];
    //注册红点事件
    WEAKSELF
    [self subscribeCountType:TXClientCountType_Checkin refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (newValue > 0) {
            //有新的刷卡，刷新界面
            STRONGSELF
            if (strongSelf) {
                [strongSelf refreshChatListSwipeCardDataSource];
            }
        }
    }];
    //订阅请假消息事件
    [self subscribeCountType:TXClientCountType_Approve refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
        if (oldValue != newValue) {
            if (newValue > 0) {
                //更新时间和数据
                STRONGSELF
                NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                [[TXSystemManager sharedManager] saveChatListData:@(currentTime) forKey:kChatListLastAttendanceTime];
                [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListHasAttendanceFlag];
                if (strongSelf) {
                    [strongSelf refreshAttendanceDataSource];
                }
            }else{
                //用户已看过,红点应该消失，此时刷新界面
                STRONGSELF
                NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
                [[TXSystemManager sharedManager] saveChatListData:@(currentTime) forKey:kChatListLastAttendanceTime];
                if (strongSelf) {
                    [strongSelf refreshAttendanceDataSource];
                }
            }
        }
    } invokeNow:YES];
    //判断网络是否连接
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    [self updateNetworkStateViewVisible:@(!reach.isReachable)];
    //设置标题字符串
    self.titleStr = @"收取中...";
    self.navigationBarViewType = NavigationBarLoadingViewType;
    
    
    [self subscribeMultipleCountTypes:nil refreshBlock:^(NSArray *values) {
        
        [self refreshEaseMobChatDataSource];
        
    } invokeNow:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //刷新列表
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //移除空的会话
        [[TXEaseMobHelper sharedHelper] removeEmptyConversationsFromDB];
        //读取最新数据
        [self fetchUserConversationsList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadChatList];
        });
    });
}
//刷新环信登录状态
- (void)refreshEaseMobLoginStatus:(NSNumber *)isSuccess
{
    BOOL successValue = [isSuccess boolValue];
    if (successValue) {
        self.titleStr = @"消息";
//        self.navigationBarViewType = NavigationBarTitleViewType;
    }else{
        self.titleStr = @"未连接";
//        self.navigationBarViewType = NavigationBarLoadingViewType;
    }
    self.navigationBarViewType = NavigationBarTitleViewType;
}
//设置网络状态是否显示
- (void)updateNetworkStateViewVisible:(NSNumber *)isVisible
{
    [super updateNetworkStateViewVisible:isVisible];
    //设置标题
    BOOL isConnectToServer = ![isVisible boolValue];
    if (isConnectToServer) {
        BOOL isLoggined = [[EaseMob sharedInstance].chatManager isLoggedIn];
        if (isLoggined) {
            self.title = @"消息";
            self.navigationBarViewType = NavigationBarTitleViewType;
        }else{
            self.titleStr = @"收取中...";
            self.navigationBarViewType = NavigationBarLoadingViewType;
        }
    }else{
        self.titleStr = @"未连接";
        self.navigationBarViewType = NavigationBarTitleViewType;
    }
}
//接收到重新登录环信的推送
- (void)receiveEaseMobReLoginNotification:(NSNotification *)notification
{
    //设置标题字符串
    self.titleStr = @"收取中...";
    self.navigationBarViewType = NavigationBarLoadingViewType;
}
//增加 联系人界面
- (void)onClickTopBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonRight) {
        //联系人按钮
        ClassListViewController *classList = [[ClassListViewController alloc] init];
        [self.navigationController pushViewController:classList animated:YES];
    }
}

#pragma mark - 获取会话列表数据
- (TXChatConversation *)lastPostConversationWithIsGarden:(BOOL)isGarden
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser) {
        return nil;
    }
    NSDictionary *articleDict;
    TXPost *post = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:isGarden ? currentUser.gardenId : 0 error:nil];
    if (!post) {
        //本地没有微学园数据
        if (isGarden) {
            return nil;
        }
        articleDict = @{@"lastMsg": @"", @"unreadNumbe":@(0)};
    }else{
        //本地数据库有微学园数据
        NSDictionary *profileDict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
        
//        if (![[profileDict allKeys] containsObject:TX_PROFILE_KEY_LEARN_GARDEN_CLICKED] || !profileDict) {
//            articleDict = @{@"unreadNumbe":@(1),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
//        }
        if ([[profileDict allKeys] containsObject:TX_PROFILE_KEY_LEARN_GARDEN_CLICKED] && profileDict) {
            
            int64_t isClick;
            isClick = [profileDict[TX_PROFILE_KEY_LEARN_GARDEN_CLICKED] longLongValue];
            
            if (isClick == 0) {
                articleDict = @{@"unreadNumbe":@(1),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
            }else{
                articleDict = @{@"unreadNumbe":@(0),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
            }
        }else{
            
            articleDict = @{@"unreadNumbe":@(0),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
            [[TXChatClient sharedInstance] setUserProfileValue:1 forKey:TX_PROFILE_KEY_LEARN_GARDEN_CLICKED];
        }
//
//        BOOL isHasClickData = NO;
//        if (isGarden) {
//            if (profileDict && [[profileDict allKeys] containsObject:TX_PROFILE_KEY_GARDEN_OFFICIAL_ACCOUNT_CLICKED]) {
//                isHasClickData = YES;
//            }
//        }else{
//            if (profileDict && [[profileDict allKeys] containsObject:TX_PROFILE_KEY_LEARN_GARDEN_CLICKED]) {
//                isHasClickData = YES;
//            }
//        }
//        if (isHasClickData) {
//            int64_t isClick;
//            if (isGarden) {
//                isClick = [profileDict[TX_PROFILE_KEY_GARDEN_OFFICIAL_ACCOUNT_CLICKED] longLongValue];
//            }else{
//                isClick = [profileDict[TX_PROFILE_KEY_LEARN_GARDEN_CLICKED] longLongValue];
//            }
//            if (isClick == 0) {
//                //有新的微学园消息未阅读
//                articleDict = @{@"unreadNumbe":@(1),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
//            }else{
//                //当前的所有微学园消息已阅读
//                articleDict = @{@"unreadNumbe":@(0),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
//            }
//        }else{
//            articleDict = @{@"unreadNumbe":@(0),@"lastMsg":post.title,@"time":@(post.createdOn / 1000)};
//        }
    }
//    if (isGarden) {
//        TXChatGardenSubConversation *conversation = [[TXChatGardenSubConversation alloc] initWithConversationAttributes:articleDict];
//        return conversation;
//    }
    TXChatWXYConversation *articleConversation = [[TXChatWXYConversation alloc] initWithConversationAttributes:articleDict];
    return articleConversation;
}
//获取请假消息
- (TXChatAttendanceConversation *)lastAttendanceConversation
{
    BOOL isHasNewAttendance = NO;
    NSString *lastMsg = @"宝贝的请假老师知道啦";
    NSDictionary *restDict = [self countValueForType:TXClientCountType_Approve];
    NSInteger restNewValue = [[restDict valueForKey:TXClientCountNewValueKey] integerValue];
    if (restNewValue > 0) {
        //有新的请假
        isHasNewAttendance = YES;
    }
    NSNumber *currentTime = [[TXSystemManager sharedManager] chatListDataForKey:kChatListLastAttendanceTime];
    NSDictionary *attendanceDict = @{@"lastMsg": lastMsg,@"time": [NSString stringWithFormat:@"%@", currentTime], @"unreadNumbe":isHasNewAttendance ? @1 : @0};
    TXChatAttendanceConversation *conversation = [[TXChatAttendanceConversation alloc] initWithConversationAttributes:attendanceDict];
    return conversation;
}
- (BOOL)fetchUserConversationsList
{
    @synchronized(self.conversationList){
        NSMutableArray *sortArray = [NSMutableArray array];
        //添加通知信息
        TXChatNotifyConversation *notifyConversation = [[TXNoticeManager shareInstance] getLastNotice];
        if (notifyConversation != nil && _isCanAddNotifyData) {
            [sortArray addObject:notifyConversation];
        }
    
        //添加刷卡信息
        TXChatSwipeCardConversation *cardConversation = [[TXCacheManage shareInstance] getLastCheckin];
        if (cardConversation != nil && _isCanAddSwipeCardData) {
            [sortArray addObject:cardConversation];
        }
        //添加微学园信息   (理解孩子)
        TXChatWXYConversation *articleConversation = (TXChatWXYConversation *)[self lastPostConversationWithIsGarden:NO];
        if (articleConversation) {
            [sortArray addObject:articleConversation];
        }
        
       //添加作业通知        
        XCSDHomeWorkNotice *homeWork = [[XCDSDHomeWorkNoticeManager shareInstance] getHomeWorlLastHomeWorks];
        if(homeWork!=nil&&_isCanAddhomeworkNoticeData){
             [sortArray addObject:homeWork];
        }
       
        
        //添加园公众号
//        if (_isCanAddGardenPostData) {
//            TXChatGardenSubConversation *gardenConversation = (TXChatGardenSubConversation *)[self lastPostConversationWithIsGarden:YES];
//            if (gardenConversation) {
//                [sortArray addObject:gardenConversation];
//            }
//        }
        TXChatGardenSubConversation *gardenConversation = (TXChatGardenSubConversation *)[self lastPostConversationWithIsGarden:YES];
        if (gardenConversation) {
            [sortArray addObject:gardenConversation];
        }
        //添加请假消息
        if (_isHasAttendanceData) {
            TXChatAttendanceConversation *attConv = [self lastAttendanceConversation];
            if (attConv) {
                [sortArray addObject:attConv];
            }
        }
        //将环信的会话从本地读取
        [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
        NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
        NSMutableArray *chatConversations = [NSMutableArray array];
        for (NSInteger i = 0; i < [conversations count]; i++) {
            EMConversation *emConversation = conversations[i];
            EMMessage *latestMsg = [emConversation latestMessage];
            if (latestMsg) {
                TXChatEaseMobConversation *easemobConversation = [[TXChatEaseMobConversation alloc] initWithEMConversation:emConversation];
                [sortArray addObject:easemobConversation];
                [chatConversations addObject:emConversation];
            }
        }
        //判断家长端的群添加
        if ([TXSystemManager sharedManager].isParentApp) {
            NSArray *departs = [[TXChatClient sharedInstance] getAllDepartments:nil];
            [departs enumerateObjectsUsingBlock:^(TXDepartment *obj, NSUInteger idx, BOOL *stop) {
                NSString *groupId = obj.groupId;
                BOOL isExist = NO;
                for (EMConversation *conversation in chatConversations) {
                    if ([conversation.chatter isEqualToString:groupId]) {
                        isExist = YES;
                        break;
                    }
                }
                if (!isExist) {
                    TXChatEaseMobConversation *easemobConversation = [[TXChatEaseMobConversation alloc] initWithGroupId:groupId];
                    [sortArray addObject:easemobConversation];
                }
            }];
        }
        
//        XCSDHomeWorkNotice *test = [XCSDHomeWorkNotice alloc];
//        [sortArray addObject:test];
        
        NSArray *retSort = [sortArray sortedArrayUsingComparator:^(id<TXChatConversationData> obj1, id<TXChatConversationData> obj2){
            long long timeStamp1 = [obj1 timeStamp];
            long long timeStamp2 = [obj2 timeStamp];
            if(timeStamp1 > timeStamp2) {
                return(NSComparisonResult)NSOrderedAscending;
            }else {
                return(NSComparisonResult)NSOrderedDescending;
            }
        }];
        
        self.conversationList = [NSMutableArray arrayWithArray:retSort];
        return YES;
    }
}
//刷新环信聊天数据
-(void)refreshEaseMobChatDataSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//刷新消息通知列表
- (void)refreshChatListNotifyDataSource
{
    //允许添加通知到列表中
    NSNumber *lastNotifyId = [[TXSystemManager sharedManager] chatListDataForKey:kChatListLastNotifyId];
    if (!lastNotifyId) {
        _isCanAddNotifyData = YES;
        [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListNotifyDeleteFlag];
    }else {
        int64_t notifyId = [lastNotifyId longLongValue];
        TXNotice *lastNotice = [[TXChatClient sharedInstance] getLastNotice:nil];
        if (lastNotice && lastNotice.noticeId != notifyId) {
            _isCanAddNotifyData = YES;
            [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListNotifyDeleteFlag];
        }else {
            _isCanAddNotifyData = NO;
            [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListNotifyDeleteFlag];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}

//刷新 homework 通知列表
- (void)refreshChatListHomeWorkDataSource
{
    //允许添加作业到列表中
    NSNumber *lastHomeWorkId = [[TXSystemManager sharedManager] chatListDataForKey:kChatListLastHomeWorkId];
    if (!lastHomeWorkId) {
        _isCanAddhomeworkNoticeData = YES;
        [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListHomeWorkDeleteFlag];
    }else {
        int64_t homeWorkId = [lastHomeWorkId longLongValue];
        XCSDHomeWork *lastHomeWork = [[TXChatClient sharedInstance] getLastHomework:nil];
        if (lastHomeWork && lastHomeWork.HomeWorkId != homeWorkId) {
            _isCanAddhomeworkNoticeData = YES;
            [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListHomeWorkDeleteFlag];
        }else {
            _isCanAddhomeworkNoticeData = NO;
            [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListHomeWorkDeleteFlag];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}

//刷新刷卡信息
- (void)refreshChatListSwipeCardDataSource
{
    //允许添加刷卡到列表中
    NSNumber *lastCheckInId = [[TXSystemManager sharedManager] chatListDataForKey:kChatListLastSwipeCardId];
    if (!lastCheckInId) {
        _isCanAddSwipeCardData = YES;
        [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListSwipeCardDeleteFlag];
    }else {
        int64_t checkinId = [lastCheckInId longLongValue];
        TXCheckIn *checkin = [[TXChatClient sharedInstance] getLastCheckIn:nil];
        if (lastCheckInId && checkin && checkin.checkInId != checkinId) {
            _isCanAddSwipeCardData = YES;
            [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListSwipeCardDeleteFlag];
        }else {
            _isCanAddSwipeCardData = NO;
            [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListSwipeCardDeleteFlag];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//刷新微学园信息
- (void)refreshChatListWXYPostDataSource
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//刷新园公众号信息
- (void)refreshGardenSubPostDataSource
{
    //允许添加园公众号到列表中
    NSNumber *postNumber = [[TXSystemManager sharedManager] chatListDataForKey:kChatListLastGardenPostId];
    if (!postNumber) {
        _isCanAddGardenPostData = YES;
        [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListGardenPostDeleteFlag];
    }else {
        TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
        if (!currentUser) {
            return;
        }
        int64_t postId = [postNumber longLongValue];
        TXPost *lastPost = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:currentUser.gardenId error:nil];
        if (lastPost && lastPost.postId != postId) {
            _isCanAddGardenPostData = YES;
            [[TXSystemManager sharedManager] saveChatListData:@(NO) forKey:kChatListGardenPostDeleteFlag];
        }else {
            _isCanAddGardenPostData = NO;
            [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListGardenPostDeleteFlag];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//刷新考勤数据
- (void)refreshAttendanceDataSource
{
    //允许添加考勤到列表中
    NSNumber *flagNumber = [[TXSystemManager sharedManager] chatListDataForKey:kChatListHasAttendanceFlag];
    if (!flagNumber) {
        _isHasAttendanceData = NO;
    }else {
        _isHasAttendanceData = [flagNumber boolValue];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//移除特定类型数据
- (BOOL)removeListDataWithClassType:(Class)class
{
    @synchronized(self.conversationList){
        NSArray *list = [_conversationList copy];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSet];
        [list enumerateObjectsUsingBlock:^(TXChatConversation *obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:class]) {
                [indexs addIndex:idx];
            }
        }];
        if ([indexs count] > 0) {
            [_conversationList removeObjectsAtIndexes:indexs];
        }
        return YES;
    }
}
//从列表页移除通知
- (void)removeNotifyDataFromList
{
    _isCanAddNotifyData = NO;
    [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListNotifyDeleteFlag];
    TXNotice *lastNotice = [[TXChatClient sharedInstance] getLastNotice:nil];
    if (lastNotice) {
        [[TXSystemManager sharedManager] saveChatListData:@(lastNotice.noticeId) forKey:kChatListLastNotifyId];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRemove = [self removeListDataWithClassType:[TXChatNotifyConversation class]];
        if (isRemove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
/**
 *bay gaoju
 */
//从列表页移除作业列表
- (void)removeHomeWorkDataFromList
{
    _isCanAddhomeworkNoticeData = NO;
    [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListHomeWorkDeleteFlag];
    XCSDHomeWork *lastHomeWork= [[TXChatClient sharedInstance] getLastHomework:nil];
    if (lastHomeWork) {
        [[TXSystemManager sharedManager] saveChatListData:@(lastHomeWork.HomeWorkId) forKey:kChatListLastHomeWorkId];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRemove = [self removeListDataWithClassType:[XCSDHomeWorkNotice class]];
        if (isRemove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//从列表页移除刷卡
- (void)removeSwipeCardDataFromList
{
    _isCanAddSwipeCardData = NO;
    [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListSwipeCardDeleteFlag];
    TXCheckIn *checkin = [[TXChatClient sharedInstance] getLastCheckIn:nil];
    if (checkin) {
        [[TXSystemManager sharedManager] saveChatListData:@(checkin.checkInId) forKey:kChatListLastSwipeCardId];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRemove = [self removeListDataWithClassType:[TXChatSwipeCardConversation class]];
        if (isRemove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//从列表页移除幼儿园公众号
- (void)removeGardenPostDataFromList
{
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!user) {
        return;
    }
    _isCanAddGardenPostData = NO;
    [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListGardenPostDeleteFlag];
    TXPost *post = [[TXChatClient sharedInstance].postManager queryLastPost:TXPBPostTypeLerngarden gardenId:user.gardenId error:nil];
    if (post) {
        [[TXSystemManager sharedManager] saveChatListData:@(post.postId) forKey:kChatListLastGardenPostId];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRemove = [self removeListDataWithClassType:[TXChatGardenSubConversation class]];
        if (isRemove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
//从列表页移除考勤数据
- (void)removeAttendanceDataFromList
{
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!user) {
        return;
    }
    _isHasAttendanceData = NO;
    [[TXSystemManager sharedManager] saveChatListData:@(YES) forKey:kChatListHasAttendanceFlag];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isRemove = [self removeListDataWithClassType:[TXChatAttendanceConversation class]];
        if (isRemove) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
            });
        }
    });
}
#pragma mark - 下拉刷新
- (void)triggleHeaderRefreshing
{
    //拉取counter接口
    if (!self.headerCounterRequesting) {
        self.headerCounterRequesting = YES;
        WEAKSELF
        [[TXChatClient sharedInstance] fetchCounters:^(NSError *error, NSMutableDictionary *countersDictionary) {
            STRONGSELF
            strongSelf.headerCounterRequesting = NO;
        }];
    }
    //本地没有部门时拉取部门
    if (!self.headerDepartmentRequesting) {
        self.headerDepartmentRequesting = YES;
        WEAKSELF
        [[TXChatClient sharedInstance] fetchDepartmentsIfNone:^(NSError *error) {
            STRONGSELF
            strongSelf.headerDepartmentRequesting = NO;
        }];
    }
    //继承父类方法
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isReturn = [self fetchUserConversationsList];
        if (isReturn) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadChatList];
                [self endHeaderRefreshing];
            });
        }
    });
}
#pragma mark - TXChatListDataSource methods
- (NSInteger)numberOfRowsInChatConversations
{
    return [_conversationList count];
}
- (id<TXChatConversationData>)conversationDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_conversationList count]) {
        id<TXChatConversationData> item = _conversationList[indexPath.row];
        return item;
    }
    return nil;
}
- (BOOL)canEditChatConversationsRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_conversationList count]) {
        id<TXChatConversationData> item = _conversationList[indexPath.row];
        if ([item isKindOfClass:[TXChatWXYConversation class]]) {
            //微学园不可删
            return NO;
        }else if ([item isKindOfClass:[TXChatGardenSubConversation class]]) {
            //园公众号不可删
            return NO;
        }else if ([item isKindOfClass:[TXChatEaseMobConversation class]]) {
            //如果是家长端的群不可删
            if ([TXSystemManager sharedManager].isParentApp) {
                TXChatEaseMobConversation *emItem = (TXChatEaseMobConversation *)item;
                if (emItem.emConversation.conversationType == eConversationTypeGroupChat) {
                    //群聊不可删
                    return NO;
                }
            }
            return YES;
        }
        return YES;
    }
    return NO;
}
- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forChatConversationsRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row < [_conversationList count]) {
            id<TXChatConversationData> item = _conversationList[indexPath.row];
            if ([item isKindOfClass:[TXChatEaseMobConversation class]]) {
                //如果是环信聊天，删除本地数据
                TXChatEaseMobConversation *conversation = (TXChatEaseMobConversation *)item;
                [[TXEaseMobHelper sharedHelper] removeConversationByChatter:conversation.emConversation.chatter deleteMessage:NO];
                //刷新
                [self refreshEaseMobChatDataSource];
            }else if ([item isKindOfClass:[TXChatNotifyConversation class]]) {
                //如果是通知，只从当前列表页删除不显示，不清空数据
                [self removeNotifyDataFromList];
            }else if ([item isKindOfClass:[TXChatSwipeCardConversation class]]) {
                //如果是刷卡，只从当前列表页删除不显示，不清空数据
                [self removeSwipeCardDataFromList];
            }else if ([item isKindOfClass:[XCSDHomeWorkNotice class]]) {
                //如果是作业，只从当前列表页删除不显示，不清空数据
                [self removeHomeWorkDataFromList];
            }
            else if ([item isKindOfClass:[TXChatGardenSubConversation class]]) {
                //幼儿园公众号
                [self removeGardenPostDataFromList];
            }else if ([item isKindOfClass:[TXChatAttendanceConversation class]]) {
                //考勤
                [self removeAttendanceDataFromList];
            }
        }
    }
}
#pragma mark - TXChatListDelegate methods
- (NSString *)titleForDeleteConfirmationButtonForChatConversationsRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)didSelectChatConversationAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [_conversationList count]) {
        NSString *mobLogString = @"";
        id<TXChatConversationData> item = _conversationList[indexPath.row];
        if ([item isKindOfClass:[TXChatEaseMobConversation class]]) {
            mobLogString = @"点击消息列表页的聊天";
            //环信聊天cell   （三年二班）
            TXChatEaseMobConversation *converation = (TXChatEaseMobConversation *)item;
            BOOL isGroup = NO;
            if (converation.emConversation.conversationType == eConversationTypeGroupChat) {
                isGroup = YES;
            }
            TXParentChatViewController *chatVc = [[TXParentChatViewController alloc] initWithChatter:converation.emConversation.chatter isGroup:isGroup];
            chatVc.titleStr = converation.displayName;
            [self.navigationController pushViewController:chatVc animated:YES];
        }else if ([item isKindOfClass:[TXChatNotifyConversation class]]) {
            mobLogString = @"点击消息列表页的通知";
            //通知cell  （通知）
            ParentNoticeListViewController *parentNotifyList = [[ParentNoticeListViewController alloc] init];
            parentNotifyList.bid = TX_PROFILE_KEY_OPTION_NOTICE;
            parentNotifyList.isMessage = YES;
            [self.navigationController pushViewController:parentNotifyList animated:YES];
        }else if ([item isKindOfClass:[TXChatSwipeCardConversation class]]) {
            mobLogString = @"点击消息列表页的刷卡";
            //刷卡cell
            GuardianDetailViewController *detailVC = [[GuardianDetailViewController alloc] init];
            [self.navigationController pushViewController:detailVC animated:YES];
        }else if ([item isKindOfClass:[TXChatWXYConversation class]]) {
            mobLogString = @"点击消息列表页的微学园";
            //微学园cell    （理解孩子）
            WXYListViewController *wxyListVc = [[WXYListViewController alloc] init];
            wxyListVc.bid = @"understandchild";
            wxyListVc.isMessage = YES;
            [self.navigationController pushViewController:wxyListVc animated:YES];
        }else if ([item isKindOfClass:[TXChatGardenSubConversation class]]) {
            mobLogString = @"点击消息列表页的园公众号";
            //理解孩子cell
            WXYListViewController *wxyListVc = [[WXYListViewController alloc] init];
            wxyListVc.isGardenSubscription = YES;
            [self.navigationController pushViewController:wxyListVc animated:YES];
        }else if ([item isKindOfClass:[TXChatAttendanceConversation class]]) {
            mobLogString = @"点击消息列表页的请假消息";
            //园公众号cell
            LeaveListViewController *vc = [[LeaveListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if([item isKindOfClass:[XCSDHomeWorkNotice class]]){
            // 作业
            HomeWorkListViewController *vc=[[HomeWorkListViewController alloc]init];
            vc.bid = TX_PROFILE_KEY_OPTION_HOMEWORK;
            vc.isMessage = YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        //友盟统计
        [MobClick event:@"msg_clickCell" label:mobLogString];
    }
}
@end
