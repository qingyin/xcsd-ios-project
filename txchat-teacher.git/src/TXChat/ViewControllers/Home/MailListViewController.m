//
//  KindergartenLeaderMailListViewController.m
//  TXChat
//
//  Created by lyt on 15-6-30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MailListViewController.h"
#import "TMedicineTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "SendMailViewController.h"
#import "MailDetailViewController.h"
#import <TXChatClient.h>
#import <MJRefresh.h>
//cell的高度
#define KCELLHIGHT 60

//每一页 加载数目
#define KNOTICESPAGE 20
@interface MailListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_mailList;
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    BOOL _isHasEntered;
}
@end

@implementation MailListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _mailList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

-(void)dealloc
{
    [self removeNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"园长信箱";
    [self createCustomNavBar];
    [self.btnRight setHidden:YES];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).with.offset(self.customNavigationView.maxY);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];
    
    [self addEmptyDataImage:NO showMessage:@"没有反馈信息"];
    [self updateEmptyDataImageStatus:NO];
    
    [self setupRefresh];
    [self loadMailsFromLocal];
//    [_tableView.header beginRefreshing];
    [self registerNotification];
    
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
        [self sendMailVC];
    }
}

-(void)sendMailVC
{
    SendMailViewController *sendMailVC = [[SendMailViewController alloc] init];
    [self.navigationController pushViewController:sendMailVC animated:YES];
}

-(void)updateMailList
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance] fetchGardenMails:LLONG_MAX onCompleted:^(NSError *error, NSArray *txGardenMails, BOOL hasMore) {
        [_tableView.header endRefreshing];
        if(error)
        {
            [self showFailedHudWithError:error];
            DDLogDebug(@"error:%@", error);
        }
        else{
            @synchronized(_mailList)
            {
//                [_mailList removeAllObjects];
//                [_mailList addObjectsFromArray:txGardenMails];
                _mailList = [NSMutableArray arrayWithArray:txGardenMails];
            }

            [_tableView.footer setHidden:!hasMore];
            TXAsyncRunInMain(^{
                [_tableView reloadData];
            });
        }
    }];
    [weakSelf updateEmptyDataImageStatus:[_mailList count] > 0?NO:YES];
}

-(void)loadMailsFromLocal
{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    NSError *error = nil;
    NSArray *mails = [[TXChatClient sharedInstance] getGardenMails:LLONG_MAX count:KNOTICESPAGE+1 error:&error];
    if(error)
    {
        [self showFailedHudWithError:error];
        DDLogDebug(@"error:%@", error);
    }
    else
    {
        @synchronized(_mailList)
        {
            [_mailList removeAllObjects];
            if([mails count] > KNOTICESPAGE)
            {
                NSRange range = {0, KNOTICESPAGE};
                [_mailList addObjectsFromArray:[mails subarrayWithRange:range]];
            }
            else
            {
                [_mailList addObjectsFromArray:mails];
            }
        }
//        if([mails count] <= KNOTICESPAGE)
//        {
//            [_tableView.footer setHidden:YES];
//        }
        TXAsyncRunInMain(^{
            [_tableView reloadData];
//            NSDictionary *dict = [self countValueForType:TXClientCountType_Mail];
//            NSInteger countValue = [dict[TXClientCountNewValueKey] integerValue];
//            NSInteger oldValue = [dict[TXClientCountOldValueKey] integerValue];
//            if (countValue > oldValue || [_mailList count] == 0) {
                [_tableView.header beginRefreshing];
//            }
        });
    }
    [weakSelf updateEmptyDataImageStatus:[_mailList count] > 0?NO:YES];
}


//NOTIFY_UPDATE_MAILS

-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailsUpdate:) name:NOTIFY_UPDATE_MAILS object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_UPDATE_MAILS object:nil];
}

-(void)mailsUpdate:(NSNotification *)notification
{
    [self updateMailList];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:!_isHasEntered];
    if (!_isHasEntered) {
        _isHasEntered = YES;
    }
    [_tableView reloadData];
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

//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    //    [self setTitle:MJRefreshAutoFooterIdleText forState:MJRefreshStateIdle];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
}

#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_mailList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TMedicineTableViewCell";
//    DLog(@"section:%d, rows:%d", indexPath.section, indexPath.row);
    UITableViewCell *cell = nil;
    TMedicineTableViewCell *mailCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (mailCell == nil) {
        mailCell = [[[NSBundle mainBundle] loadNibNamed:@"TMedicineTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXGardenMail *mail = [_mailList objectAtIndex:indexPath.row];
    if(mail.isAnonymous)
    {
        [mailCell.headerImageview setImage:[UIImage imageNamed:@"userDefaultIcon"]];
    }
    else
    {
        [mailCell.headerImageview TX_setImageWithURL:[NSURL URLWithString:[mail.fromUserAvatarUrl getFormatPhotoUrl:40 hight:40]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    }
    [mailCell.fromLabel setText:mail.fromUsername];
    [mailCell.contentLabel setText:mail.content];
    [mailCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(mail.createdOn/1000)]]];
    [mailCell.unreadImageView setHidden:mail.isRead];
    if(indexPath.row == [_mailList count] -1)
    {
        [mailCell.seperatorLine setHidden:YES];
    }
    else
    {
        [mailCell.seperatorLine setHidden:NO];
    }
    cell = mailCell;

    return cell;
}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(editingStyle == UITableViewCellEditingStyleDelete)
//    {
//       if(indexPath.row < [_mailList count])
//       {
//           [_mailList removeObjectAtIndex:indexPath.row];
//           TXAsyncRunInMain(^{
//               [tableView reloadData];
//           });
//       }
//    }
//}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TXGardenMail *mail = [_mailList objectAtIndex:indexPath.row];
    MailDetailViewController *mailDetail = [[MailDetailViewController alloc] initWithMail:mail];
    [self.navigationController pushViewController:mailDetail animated:YES];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLHIGHT;
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
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0)
//{
//    return @"删除";
//}
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewMailsRereshing];
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
    int64_t beginMailId = 0;
    if(_mailList != nil && [_mailList count] > 0)
    {
        TXGardenMail *beginMail = _mailList.lastObject;
        beginMailId = beginMail.gardenMailId;
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance]  fetchGardenMails:beginMailId onCompleted:^(NSError *error, NSArray *txGardenMails, BOOL hasMore) {
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
            [weakSelf updateMailsAfterFooterReresh:txGardenMails];
            [_tableView.footer setHidden:!hasMore];
        }
        [weakSelf updateEmptyDataImageStatus:[_mailList count] > 0?NO:YES];
    }];
}



-(void)updateMailsAfterFooterReresh:(NSArray *)mails
{
    @synchronized(_mailList)
    {
        if(mails != nil && [mails count] > 0)
        {
            [_mailList addObjectsFromArray:mails];
        }
    }
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
    
}


- (void)fetchNewMailsRereshing{
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [[TXChatClient sharedInstance]  fetchGardenMails:LLONG_MAX onCompleted:^(NSError *error, NSArray *txGardenMails, BOOL hasMore) {
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
            [weakSelf updateMailsAfterHeaderRefresh:txGardenMails];
            [_tableView.footer setHidden:!hasMore];
        }
        [weakSelf updateEmptyDataImageStatus:[_mailList count] > 0?NO:YES];
    }];
}

- (void)updateMailsAfterHeaderRefresh:(NSArray *)mails
{
    @synchronized(_mailList)
    {
        [_mailList removeAllObjects];
        if(mails != nil && [mails count] > 0)
        {
//            [_mailList removeAllObjects];
//            [_mailList addObjectsFromArray:mails];
            _mailList = [NSMutableArray arrayWithArray:mails];
        }
    }
    [_tableView.header endRefreshing];
    [_tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView scrollsToTop];
    });
}


//点击图片后处理
-(void)ImageViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    [self sendMailVC];
}


@end
