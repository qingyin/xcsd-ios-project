//
//  TeacherNoticeListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TeacherNoticeListViewController.h"
#import "NoticeDetailViewController.h"
#import "NotifyTableViewCell.h"
#import "SenderNoticeDetailViewController.h"
#import "NoticeSelectGroupViewController.h"
#import <MJRefresh.h>
#import "NSDate+TuXing.h"
#import "UIImageView+EMWebCache.h"
#import "TXUser+Utils.h"
#import "SendNotificationViewController.h"
#import "TXContactManager.h"
#import "TXSystemManager.h"
#import "TXNoticeManager.h"
#import <UIImage+Utils.h>
#import <UIImageView+Utils.h>
#import "NSString+Photo.h"

#define KCELLHIGHT 70.0f;

//每一页 加载数目
#define KNOTICESPAGE 20

@interface TeacherNoticeListViewController ()<UITabBarDelegate>
{
    NSInteger _selectedIndex;
    UITabBarItem *_leftItem;
    UITabBarItem *_rightItem;
    UIView *_leftBGNormalView;
    UIView *_rightBGNormalView;
    NSArray *_msgList;
    NSMutableArray *_noticesList;
    UITabBar *_tabbar;
}
@end

@implementation TeacherNoticeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _selectedIndex = 0;
        _noticesList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

-(void)dealloc
{
    [self unregisterNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.barLineView.hidden = YES;
    // Do any additional setup after loading the view.
    [self.btnRight setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [self.btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.btnRight setHidden:YES];
    [self setupViews];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf loadNoticesList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });
    [self registerNotification];
    self.view.backgroundColor = kColorBackground;
    [_tableView.header beginRefreshing];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[TXNoticeManager shareInstance] updateNoticeStatus:YES];
    [_tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[TXNoticeManager shareInstance] updateNoticeStatus:NO];
}


-(void)setupViews
{
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    
    UITabBar *tabbar = [[UITabBar alloc] init];
    UITabBarItem *leftItem = nil;
    if(IOS7_OR_LATER)
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"收件箱" image:nil selectedImage:nil];
    }
    else
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"收件箱" image:nil tag:0];
    }
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorSubTitleTxt, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateNormal];
    
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorAppMain, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [leftItem setTitlePositionAdjustment:UIOffsetMake(0, -9)];
    _leftItem = leftItem;
    
    
    UITabBarItem *rightItem = nil;
    if(IOS7_OR_LATER)
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"发件箱" image:nil selectedImage:nil];
    }
    else
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"发件箱" image:nil tag:0];
    }
    
    
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       KColorSubTitleTxt, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       KColorAppMain, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [rightItem setTitlePositionAdjustment:UIOffsetMake(0, -9)];
    _rightItem = rightItem;
    NSArray *tabBarItemArray = [[NSArray alloc] initWithObjects: leftItem, rightItem,nil];
    [tabbar setItems: tabBarItemArray];
    CGFloat tabbarHight = 40.0f;
//    [tabbar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kScreenWidth/2, 0, kLineHeight, tabbarHight)]];
    [tabbar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)]];
    [tabbar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, tabbarHight - kLineHeight, kScreenWidth, kLineHeight)]];
    
    [tabbar setBackgroundImage:[UIImageView createImageWithColor:kColorWhite]];
    [[UITabBar appearance] setShadowImage:[UIImageView createImageWithColor:kColorWhite]];
    tabbar.delegate = self;
    [self.view addSubview:tabbar];
    _tabbar = tabbar;    
    
    [tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.centerX.mas_equalTo(superview);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, tabbarHight));
    }];
    
    [tabbar setSelectedItem:_leftItem];
    
    _leftBGNormalView = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth/2, tabbarHight- kLineHeight)];
    _leftBGNormalView.backgroundColor = RGBCOLOR(0xf4, 0xf4, 0xf4);
    _leftBGNormalView.userInteractionEnabled = YES;
    [tabbar addSubview:_leftBGNormalView];
    [tabbar sendSubviewToBack:_leftBGNormalView];
    [_leftBGNormalView setHidden:YES];
    
    _rightBGNormalView = [[UIView alloc] initLineWithFrame:CGRectMake(kScreenWidth/2, 0, kScreenWidth/2, tabbarHight - kLineHeight)];
    _rightBGNormalView.backgroundColor = RGBCOLOR(0xf4, 0xf4, 0xf4);
    _rightBGNormalView.userInteractionEnabled = YES;
    [tabbar addSubview:_rightBGNormalView];
    [tabbar sendSubviewToBack:_rightBGNormalView];
    
    
    _tableView.backgroundColor =  [UIColor clearColor];
    CGFloat navHight = weakSelf.customNavigationView.maxY;
    _tableView.rowHeight = KCELLHIGHT;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(navHight+tabbarHight, 0, 0, 0));
    }];
    
    [self addEmptyDataImage:YES showMessage:@"没有通知信息"];
    
}

-(void)createCustomNavBar
{
    [super createCustomNavBar];
    CGFloat segmentWidth = 60;
    
//        _btnRight = [[CustomButton alloc] initWithFrame:CGRectMake(_customNavigationView.width_ - segmentWidth, _customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight)];
    self.btnRight.frame = CGRectMake(self.customNavigationView.width_ - segmentWidth, self.customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight);
    // 右按钮
    CustomButton *newNotices = [[CustomButton alloc] initWithFrame:CGRectMake(self.btnRight.minX - segmentWidth, self.customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight)];
    newNotices.showBackArrow = NO;
    newNotices.tag = TopBarButtonRight;
    newNotices.adjustsImageWhenHighlighted = NO;
    newNotices.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    newNotices.titleLabel.font = kFontMiddle;
    newNotices.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft);
    newNotices.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0,2);
    newNotices.exclusiveTouch = YES;
    [newNotices addTarget:self action:@selector(showSendNotification) forControlEvents:UIControlEventTouchUpInside];
    [newNotices setTitleColor:kColorNavigationTitle forState:UIControlStateNormal];
    [newNotices setTitleColor:kColorNavigationTitleDisable forState:UIControlStateDisabled];
    [newNotices setImage:[UIImage imageNamed:@"newNotice"] forState:UIControlStateNormal];
    [self.customNavigationView addSubview:newNotices];
}


-(void)isClearNotices
{
    
    NSString *titles = [self isInbox]?@"清空收件箱":@"清空发件箱";
    __weak __typeof(&*self) weakSelf=self;  //by sck
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:titles otherButtonTitles:nil, nil];
//    [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        if (!buttonIndex) {
//            [weakSelf clearNotices];
//        }
//    }];
    [self showHighlightedSheetWithTitle:nil normalItems:nil highlightedItems:@[titles] otherItems:nil clickHandler:^(NSInteger index) {
        if (!index) {
            [weakSelf clearNotices];
        }
    } completion:nil];
}

//清空刷卡
-(void)clearNotices
{
    int64_t noticeId = 0;
    if(_noticesList && [_noticesList count] > 0)
    {
        TXNotice *notice = (TXNotice *)_noticesList.firstObject;
        if(notice)
        {
            noticeId = notice.noticeId;
        }
    }
    else
    {
        return ;
    }
    if(noticeId <= 0)
    {
        return;
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] clearNotice:noticeId isInbox:[self isInbox] onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(error)
        {
            [weakSelf showFailedHudWithError:error];
        }
        else
        {
            _noticesList = [NSMutableArray arrayWithCapacity:5];
            [weakSelf autoUpdateNoDataStatus];
            [_tableView reloadData];
            if([self isInbox])
            {
                NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
                if(unreadCountDic)
                {
                    [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_NOTICE];
                }
            }
        }
    }];
}


-(void)autoUpdateNoDataStatus
{
    [self updateEmptyDataImageStatus:[_noticesList count] > 0?NO:YES];
    [self updateBackgroundColor];
}

//点击图片后处理
-(void)ImageViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    [super ImageViewTapEvent:recognizer];
    [self showSendNotification];
}


//是否是收件箱
-(BOOL)isInbox
{
    return _selectedIndex == 0;
}


-(void)loadNoticesList
{
    NSError *error = nil;
    NSArray *localNotices = [[TXChatClient sharedInstance] getNotices:LLONG_MAX count:KNOTICESPAGE isInbox:[self isInbox] error:&error];
    if(error)
    {
        DDLogDebug(@"error:%@", error);
    }
    else
    {
        if(_noticesList != nil)
        {
            @synchronized(_noticesList)
            {
                _noticesList = [NSMutableArray arrayWithArray:localNotices];
            }
            [self autoUpdateNoDataStatus];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
//        [self showSendNotification];
        [self isClearNotices];
    }
}
-(void)showSelectGroup
{
    NoticeSelectGroupViewController *selectGroup = [[NoticeSelectGroupViewController alloc] init];
    [self.navigationController pushViewController:selectGroup animated:YES];
}
-(void)showSendNotification
{
    NSArray *defaultArray = [[TXContactManager shareInstance] defaultDepartForSendNotice];
    SendNotificationViewController *sendNotification = [[SendNotificationViewController alloc] initWithSelectedDeparts:defaultArray];
    [self.navigationController pushViewController:sendNotification animated:YES];
}

-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcvNewNotification:) name:NOTIFY_RCV_NOTICES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcvSendNotification:) name:NOTIFY_SEND_NOTICES object:nil];
}
-(void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_RCV_NOTICES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_SEND_NOTICES object:nil];
}

-(void)rcvNewNotification:(NSNotification *)notification
{
    if(![self isInbox])
    {
        return;
    }
    
//    NSArray *notices = notification.object;
//    if(notices != nil && [notices count] > 0)
//    {
//        TXAsyncRunInMain(^{
//            @synchronized(_noticesList)
//            {
////                [_noticesList removeAllObjects];
////                [_noticesList addObjectsFromArray:notices];
//                _noticesList = [NSMutableArray arrayWithArray:notices];
//            }
//            [_tableView reloadData];
//        });
//    }
//    else
//    {
        [self autoUpdateNewNotices];
//    }
}


-(void)rcvSendNotification:(NSNotification *)notification
{
    [_tabbar setSelectedItem:_rightItem];
    [self tabBar:_tabbar didSelectItem:_rightItem];
}

-(void)updateBackgroundColor
{
    if([_noticesList count] > 0)
    {
        self.view.backgroundColor = kColorBackground;
        _tableView.backgroundColor = self.view.backgroundColor;
    }
    else
    {
        self.view.backgroundColor = kColorBackground;
        _tableView.backgroundColor = self.view.backgroundColor;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_noticesList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotifyTableViewCell";
//    DLog(@"section:%d, rows:%d", indexPath.section, indexPath.row);
    UITableViewCell *cell = nil;
    NotifyTableViewCell *notifyCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (notifyCell == nil) {
        notifyCell = [[[NSBundle mainBundle] loadNibNamed:@"NotifyTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    if(indexPath.row >= [_noticesList count])
    {
        return notifyCell;
    }
    TXNotice *notice = [_noticesList objectAtIndex:indexPath.row];
    if([self isInbox])
    {

        if(notice.senderAvatar != nil && [notice.senderAvatar length] > 0)
        {
            [notifyCell.fromHeader TX_setImageWithURL:[NSURL URLWithString:[notice.senderAvatar getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"attendance_defaultHeader"]];
        }
        [notifyCell.toUserLabel setText:KCONVERTSTRVALUE(notice.senderName)];
        if(notice.isRead)
        {
            [notifyCell.unreadImage setHidden:YES];
        }
        else
        {
            [notifyCell.unreadImage setHidden:NO];
        }
        if(indexPath.row == [_noticesList count] -1)
        {
            [notifyCell.seperatorLine setHidden:YES];
        }
    }
    else
    {
        if(notice.senderAvatar != nil && [notice.senderAvatar length] > 0)
        {
            [notifyCell.fromHeader TX_setImageWithURL:[NSURL URLWithString:[notice.senderAvatar getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"attendance_defaultHeader"]];
        }
        NSString *fromUserNickname = notice.senderName;
        [notifyCell.toUserLabel setText:KCONVERTSTRVALUE(fromUserNickname)];
        [notifyCell.unreadImage setHidden:YES];
        if(indexPath.row == [_noticesList count] -1)
        {
            [notifyCell.seperatorLine setHidden:YES];
        }
    }
    [notifyCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(notice.sentOn/1000)]]];
    [notifyCell.messageLabel setText:notice.content];
    notifyCell.backgroundColor = kColorWhite;
    cell = notifyCell;
    return cell;
}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXNotice *notice = [_noticesList objectAtIndex:indexPath.row];
    if([self isInbox])
    {
//        notice.isRead = YES;
        [self showNotifyDetail:notice];
    }
    else
    {
        [self showSenderNotifyDetail:notice];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [_tableView reloadData];
}


-(void)showNotifyDetail:(TXNotice *)currentNotice
{
    NoticeDetailViewController *NoticeDetail = [[NoticeDetailViewController alloc] initWithNotice:currentNotice];
    [self.navigationController pushViewController:NoticeDetail animated:YES];
}
-(void)showSenderNotifyDetail:(TXNotice *)notice
{
    SenderNoticeDetailViewController *senderNoticeDetail = [[SenderNoticeDetailViewController alloc] initWithNotice:notice];
    [self.navigationController pushViewController:senderNoticeDetail animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 1;
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section   // custom view for footer. will be adjusted to default or specified footer height
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
    
}

#pragma mark-  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item // called when a new view is selected by the user (but not programatically)
{
    if(item == _leftItem)
    {
        if(_selectedIndex != 0)
        {
            _selectedIndex = 0;
            [_leftBGNormalView setHidden:YES];
            [_rightBGNormalView setHidden:NO];
        }
    }
    else if (item == _rightItem)
    {
        if(_selectedIndex != 1)
        {
            _selectedIndex = 1;
            [_leftBGNormalView setHidden:NO];
            [_rightBGNormalView setHidden:YES];
        }
    }
    [self loadNoticesList];
    TXAsyncRunInMain(^{
        [_tableView reloadData];
    });
    [self autoUpdateNewNotices];
}

#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewNoticesRereshing];
    });
}
- (void)footerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{

    int64_t beginNoticeId = 0;
    if(_noticesList != nil && [_noticesList count] > 0)
    {
        TXNotice *beginNotice = _noticesList.lastObject;
        beginNoticeId = beginNotice.noticeId;
    }
    DDLogDebug(@"fetchNotices");
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchNotices:[self isInbox] maxNoticeId:beginNoticeId  onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        if([self isInbox] != isInbox)
        {
            return ;
        }
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            [weakSelf updateNoticesAfterFooterReresh:txNotices];
            [_tableView.footer setHidden:!hasMore];
        }
        [_tableView.footer endRefreshing];
        [self autoUpdateNoDataStatus];
    }];

}



-(void)updateNoticesAfterFooterReresh:(NSArray *)notices
{

    @synchronized(_noticesList)
    {
        if(notices != nil && [notices count] > 0)
        {
            [_noticesList addObjectsFromArray:notices];
        }
    }
    [_tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger sectionCount = [self.tableView numberOfSections];
        if (sectionCount) {
            
            NSUInteger rowCount = [self.tableView numberOfRowsInSection:0];
            if (rowCount) {
                
                NSUInteger ii[2] = {0, rowCount - 1};
                NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                [self.tableView scrollToRowAtIndexPath:indexPath
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    });

}


- (void)fetchNewNoticesRereshing{
    DDLogDebug(@"fetchNotices");
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchNotices:[self isInbox] maxNoticeId:LLONG_MAX onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        if([self isInbox] != isInbox)
        {
            if(_tableView.header.isRefreshing)
            {
                [_tableView.header endRefreshing];
            }
            return ;
        }
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
        }
        else
        {
            if(lastOneHasChanged && [self isInbox])
            {
                [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
            }
            [weakSelf updateNoticesAfterHeaderRefresh:txNotices];
            if(!hasMore)
            {
                [_tableView.footer setHidden:YES];
            }
        }
        [_tableView.header endRefreshing];
        [self autoUpdateNoDataStatus];
    }];
}

- (void)updateNoticesAfterHeaderRefresh:(NSArray *)notices
{
    @synchronized(_noticesList)
    {
//        [_noticesList removeAllObjects];
//        [_noticesList addObjectsFromArray:notices];
        _noticesList = [NSMutableArray arrayWithArray:notices];
    }
    [_tableView reloadData];
    [_tableView scrollsToTop];
}

-(void)autoUpdateNewNotices
{
    DDLogDebug(@"fetchNotices");
    [[TXChatClient sharedInstance] fetchNotices:[self isInbox] maxNoticeId:LLONG_MAX onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        if(isInbox != [self isInbox])
        {
            return ;
        }
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            if(lastOneHasChanged && [self isInbox])
            {
                [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
            }
            @synchronized(_noticesList)
            {
//                [_noticesList removeAllObjects];
//                [_noticesList addObjectsFromArray:txNotices];
                _noticesList = [NSMutableArray arrayWithArray:txNotices];
            }
            TXAsyncRunInMain(^{
                [_tableView reloadData];
            });
            [_tableView.footer setHidden:!hasMore];
        }
        [self autoUpdateNoDataStatus];
    }];
}



@end
