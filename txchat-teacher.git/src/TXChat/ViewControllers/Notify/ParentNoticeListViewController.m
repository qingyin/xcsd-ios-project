//
//  BabyListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ParentNoticeListViewController.h"
#import <Masonry.h>
#import "NotifyTableViewCell.h"
#import "NoticeDetailViewController.h"
#import <TXChatClient.h>
#import <TXNotice.h>
#import "UIImageView+EMWebCache.h"
#import <MJRefresh.h>
#import "NSDate+TuXing.h"
#import "TXUser+Utils.h"
#import "TXSystemManager.h"
#import "TXNoticeManager.h"
#import "NSString+Photo.h"
//通知cell的高度
#define KNOTICECELLHIGHT 60

//每一页 加载数目
#define KNOTICESPAGE 20

@interface ParentNoticeListViewController ()
{
    NSMutableArray *_notifyList;
}
@end

@implementation ParentNoticeListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        _notifyList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    UIView *superview = self.view;
    _tableView.backgroundColor = kColorBackground;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.bottom.mas_equalTo(superview);
    }];
    [self createNotifyList];
    self.view.backgroundColor = kColorBackground;
    [self registerNotification];
}

-(void)updateTableConstraints
{

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self unregisterNotification];
}

-(void)createNotifyList
{
    NSError *error = nil;
    NSArray *notices = [[TXChatClient sharedInstance] getNotices:LLONG_MAX count:KNOTICESPAGE+1 error:&error];
    if(error)
    {
        DDLogDebug(@"error");
    }
    else
    {
        if([notices count] > 0)
        {
            @synchronized(_notifyList)
            {
                if([notices count] > KNOTICESPAGE)
                {
                    NSRange range = {0, KNOTICESPAGE};
                    [_notifyList addObjectsFromArray:[notices subarrayWithRange:range]];
                }
                else
                {
                    [_notifyList addObjectsFromArray:notices];
                }
            }
        }
        TXAsyncRunInMain(^{
            [_tableView reloadData];
//            NSDictionary *dict = [self countValueForType:TXClientCountType_Notice];
//            NSInteger countValue = [dict[TXClientCountNewValueKey] integerValue];
//            if (countValue > 0 || [_notifyList count] == 0) {
                [_tableView.header beginRefreshing];
//            }
        });
    }
    [self updateNoDataStatus:[_notifyList count] > 0?NO:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[TXNoticeManager shareInstance] updateNoticeStatus:YES];
    [_tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[TXNoticeManager shareInstance] updateNoticeStatus:NO];
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

-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rcvNewNotification:) name:NOTIFY_RCV_NOTICES object:nil];
}
-(void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_RCV_NOTICES object:nil];
}

-(void)rcvNewNotification:(NSNotification *)notification
{
    
    NSArray *notices = notification.object;
    if(notices != nil && [notices count] > 0)
    {
        @synchronized(_notifyList)
        {
            [_notifyList addObjectsFromArray:notices];
        }
        
        
    }
}


#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_notifyList count];
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
    TXNotice *notice = [_notifyList objectAtIndex:indexPath.row];
    if(notice.senderAvatar != nil && [notice.senderAvatar length] > 0)
    {
        [notifyCell.fromHeader TX_setImageWithURL:[NSURL URLWithString:[notice.senderAvatar getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    }
    [notifyCell.toUserLabel setText:notice.senderName];
    [notifyCell.messageLabel setText:notice.content];
    [notifyCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(notice.sentOn/1000)]]];
    if(notice.isRead)
    {
        [notifyCell.unreadImage setHidden:YES];
    }
    else
    {
        [notifyCell.unreadImage setHidden:NO];
    }
    
    if(indexPath.row == [_notifyList count] -1)
    {
        [notifyCell.seperatorLine setHidden:YES];
    }
    notifyCell.backgroundColor = kColorWhite;
    notifyCell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell = notifyCell;
    return cell;
}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    TXNotice *notice = [_notifyList objectAtIndex:indexPath.row];
//    notice.isRead = YES;
    [self showNotifyDetail:notice];
}


-(void)showNotifyDetail:(TXNotice *)notice
{
    NoticeDetailViewController *NoticeDetail = [[NoticeDetailViewController alloc] initWithNotice:notice];
    [self.navigationController pushViewController:NoticeDetail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KNOTICECELLHIGHT;
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
    if(_notifyList != nil && [_notifyList count] > 0)
    {
        TXNotice *beginNotice = _notifyList.lastObject;
        beginNoticeId = beginNotice.noticeId;
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchNotices:YES maxNoticeId:beginNoticeId onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.footer endRefreshing];
            });
        }
        else
        {
            [weakSelf updateNoticesAfterFooterReresh:txNotices];
            [_tableView.footer setHidden:!hasMore];
        }
        [self updateNoDataStatus:[_notifyList count] > 0?NO:YES];
    }];
}



-(void)updateNoticesAfterFooterReresh:(NSArray *)notices
{
    @synchronized(_notifyList)
    {
        if(notices != nil && [notices count] > 0)
        {
            [_notifyList addObjectsFromArray:notices];
        }
    }
    [self updateTableConstraints];
    [_tableView reloadData];
    [_tableView.footer endRefreshing];

}


- (void)fetchNewNoticesRereshing{
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchNotices:YES maxNoticeId:LLONG_MAX onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {        
            if(error)
            {
                DDLogDebug(@"error:%@", error);
                [self showFailedHudWithError:error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView.header endRefreshing];
                });
            }
            else
            {
                if(lastOneHasChanged)
                {
                    [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
                }
                [weakSelf updateNoticesAfterHeaderRefresh:txNotices];
            }
            [self updateNoDataStatus:[_notifyList count] > 0?NO:YES];
        }];
}

- (void)updateNoticesAfterHeaderRefresh:(NSArray *)notices
{
    @synchronized(_notifyList)
    {
        [_notifyList removeAllObjects];
        if(notices != nil && [notices count] > 0)
        {
//            [_notifyList removeAllObjects];
//            [_notifyList addObjectsFromArray:notices];
            _notifyList = [NSMutableArray arrayWithArray:notices];
        }
    }
    [_tableView.header endRefreshing];
    [self updateTableConstraints];
    [_tableView reloadData];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView scrollsToTop];
    });
}


@end
