//
//  HomeWorkListViewController.m
//  TXChatParent
//
//  Created by yi.meng on 16/2/18.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkListViewController.h"
#import "HomeWorkDetailViewController.h"
#import "HomeWorkTableViewCell.h"
#import <MJRefresh.h>
#import "NSDate+TuXing.h"
#import "UIImageView+EMWebCache.h"
#import "TXUser+Utils.h"
#import "SendNotificationViewController.h"
#import "TXContactManager.h"
#import "TXSystemManager.h"
#import <UIImage+Utils.h>
#import <UIImageView+Utils.h>
#import "NSString+Photo.h"
#import "HomeWorkDetailsViewController.h"
#import "HomeWorkIsDidViewController.h"
#import "HomeWorkRankViewController.h"
#import "XCDSDHomeWorkNoticeManager.h"
#import "HomeworkDetailTwoViewController.h"



//通知cell的高度
#define KNOTICECELLHIGHT 70

//每一页 加载数目
#define KNOTICESPAGE 20

@interface HomeWorkListViewController ()<UITabBarDelegate,UITableViewDataSource>
{
    NSMutableArray *_homeWorkList;
    XCSDHomeWork *homeWork;
}

@property (nonatomic, assign) NSInteger selectedIdx;
@property (nonatomic, assign) BOOL isStart;
@end

@implementation HomeWorkListViewController

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
        _homeWorkList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createCustomNavBar];
    self.titleStr = @"作业";
    
    UIView *superview = self.view;
    _tableView.backgroundColor = kColorBackground;
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    __weak typeof(self) weakSelf = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(weakSelf.customNavigationView.maxY);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.bottom.mas_equalTo(superview);
    }];
    [self createHomeWorkList];
    self.view.backgroundColor = kColorBackground;
    [self addEmptyDataImage:NO showMessage:@"没有学能作业信息"];
    [self updateEmptyDataImageStatus:NO];
    
    UIView *lineView=[[UIView alloc]init];
    [superview addSubview:lineView];
    lineView.backgroundColor=kColorLine;
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.size.mas_equalTo(CGSizeMake(superview.bounds.size.width, .1));
    }];
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnRight setImage:[UIImage imageNamed:@"btn_reporCard"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonRight) {
        [self isHomeworkRankViewController];
    }
    
}

-(void)isHomeworkRankViewController{
    HomeWorkRankViewController *RankVc=[[HomeWorkRankViewController alloc]init];
    RankVc.childName =homeWork.targetName;
    [self.navigationController pushViewController:RankVc animated:YES];
    
}

-(void)createHomeWorkList
{
    NSError *error = nil;
    NSArray *homeWorks = [[TXChatClient sharedInstance]  getHomeWork:LLONG_MAX count:KNOTICESPAGE+1 error:&error];
    if(error)
    {
        DDLogDebug(@"error");
    }
    else
    {
        if([homeWorks count] > 0)
        {
            @synchronized(_homeWorkList)
            {
                if([homeWorks count] > KNOTICESPAGE)
                {
                    NSRange range = {0, KNOTICESPAGE};
                  [_homeWorkList addObjectsFromArray:[homeWorks subarrayWithRange:range]];
                }
                else
                {
                    [_homeWorkList addObjectsFromArray:homeWorks];
                }
            }
        }
        TXAsyncRunInMain(^{
            [_tableView reloadData];
//                        NSDictionary *dict = [self countValueForType:TXClientCountType_Notice];
//                        NSInteger countValue = [dict[TXClientCountNewValueKey] integerValue];
//                        if (countValue > 0 || [_homeWorkList count] == 0) {
            [_tableView.header beginRefreshing];
//                       }
        });
    }
    [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [[XCDSDHomeWorkNoticeManager shareInstance] updateHomeWorksStatus:YES];

    if (self.isStart) {
        NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:1];
//        [self fetchNewhomeWorksRereshingWithHUD:YES];
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
        [[TXChatClient sharedInstance] fetchHomeWorks:YES maxHomeWorkId:LONG_LONG_MAX onCompleted:^(NSError *error, NSArray *xcsdHomeWork, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
            [TXProgressHUD hideHUDForView:self.view animated:NO];
            
            for (NSInteger i = 0; i < xcsdHomeWork.count; ++i) {
                XCSDHomeWork *homework = xcsdHomeWork[i];
                XCSDHomeWork *localHomework = _homeWorkList[i];
                if (homework.id > localHomework.id) {
                    [tmpArr addObject:homework];
                }else{
                    _homeWorkList[i] = homework;
                }
            }
            
            NSArray *localTmp = _homeWorkList.copy;
            _homeWorkList = [NSMutableArray arrayWithArray:tmpArr.copy];
            [_homeWorkList addObjectsFromArray:localTmp];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedIdx inSection:0]] withRowAnimation:0];
        }];
    }else{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedIdx inSection:0]] withRowAnimation:0];
    }
    
    self.isStart = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   
    [[XCDSDHomeWorkNoticeManager shareInstance] updateHomeWorksStatus:NO];
}


#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _homeWorkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HomeWorkTableViewCell";
    UITableViewCell *cell = nil;
    HomeWorkTableViewCell *homeWorkCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (homeWorkCell == nil) {
        homeWorkCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeWorkTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
   

    if(indexPath.row >= [_homeWorkList count])
    {
        return homeWorkCell;
    }
    homeWork = [_homeWorkList objectAtIndex:indexPath.row];
    if(homeWork.senderAvatar != nil && [homeWork.senderAvatar length] > 0)
    {
        [homeWorkCell.fromHeader TX_setImageWithURL:[NSURL URLWithString:[homeWork.senderAvatar getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    }
    [homeWorkCell.toUserLabel setText:[ homeWork.senderName stringByAppendingString:@" 布置"]];
    [homeWorkCell.messageLabel setText:homeWork.title];
    [homeWorkCell.userLabel setText:homeWork.targetName];
    [homeWorkCell.timeLabel setText:[NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(homeWork.sendTime/1000)]]];
    
    if(homeWork.hasRead==1)
    {
        [homeWorkCell.unreadImage setHidden:YES];
    }
    else
    {
        [homeWorkCell.unreadImage setHidden:NO];
      
    }

    if(homeWork.status==0)
    {
        [homeWorkCell.stateImage setImage:[UIImage imageNamed:@"02_Todo"]];
    }
    else
    {
        [homeWorkCell.stateImage setImage:[UIImage imageNamed:@"01_haveTodo"]];
    }
    
    if(indexPath.row == [_homeWorkList count] -1)
    {
        [homeWorkCell.seperatorLine setHidden:YES];
    }
    homeWorkCell.backgroundColor = kColorWhite;
    cell = homeWorkCell;
    return cell;
}

//cell左滑可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCSDHomeWork *homeWorks = [_homeWorkList objectAtIndex:indexPath.row];
    [[TXChatClient sharedInstance] DeletehomeworId:homeWorks.HomeWorkId onCompleted:^(NSError *error) {}];
    
    [self dealWithUnreadCountWithHomework:homeWorks];
   
    // 从数据源中删除
    [_homeWorkList removeObjectAtIndex:indexPath.row];
    // 从列表中删除
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_tableView reloadData];
}

#pragma mark-  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIdx = indexPath.row;
    
    XCSDHomeWork *homeWorks = [_homeWorkList objectAtIndex:indexPath.row];
   // notice.hasRead = 0;
    //[self showNotifyDetail:homeWorks];
    [self dealWithUnreadCountWithHomework:homeWorks];
    
    HomeworkDetailTwoViewController *homeworkDetailVC = [[HomeworkDetailTwoViewController alloc] init].setHomework(homeWorks);
    @weakify(self);
    homeworkDetailVC.didStartHomework = ^(BOOL isStart){
        @strongify(self);
        self.isStart = isStart;
        
    };
    
    [self.navigationController pushViewController:homeworkDetailVC animated:YES];
}

- (void)dealWithUnreadCountWithHomework:(XCSDHomeWork *)homeWorks {
    
    if (!homeWorks.hasRead) {
        
        [[TXChatClient sharedInstance] ReadhomeworkId:homeWorks.HomeWorkId onCompleted:^(NSError *error) {
            if(!error)
            {
                homeWorks.hasRead = YES;
                NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
                if(unreadCountDic)
                {
                    NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_HOMEWORK];
                    if([countValue integerValue] > 0)
                    {
                        [[TXChatClient sharedInstance] setCountersDictionaryValue:[countValue intValue]  - 1 forKey:TX_COUNT_HOMEWORK];
                    }
                }
            }
        }];
    }
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
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewhomeWorksRereshingWithHUD:NO];
    });
}
- (void)footerRereshing{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{
    int64_t beginhomeWorkId = 0;
    if(_homeWorkList != nil && [_homeWorkList count] > 0)
    {
        XCSDHomeWork *beginhomeWork = _homeWorkList.lastObject;
        beginhomeWorkId = beginhomeWork.HomeWorkId;
    }
    DDLogDebug(@"fetchNotices");
    __weak typeof(self) weakSelf = self;
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance] fetchHomeWorks:YES maxHomeWorkId:beginhomeWorkId onCompleted:^(NSError *error, NSArray *xcsdHomeWorks, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        [TXProgressHUD hideHUDForView:self.view animated:NO];
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.footer endRefreshing];
            });
            [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
        }
        else
        {
            TXAsyncRunInMain(^{
                [weakSelf updateNoticesAfterFooterReresh:xcsdHomeWorks];
                if(!hasMore)
                {
                    [_tableView.footer setHidden:YES];
                }
                [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
            });
            
            [_tableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
    }];
}



-(void)updateNoticesAfterFooterReresh:(NSArray *)homeWorks
{
    @synchronized(_homeWorkList)
    {
        if(homeWorks != nil && [homeWorks count] > 0)
        {
            [_homeWorkList addObjectsFromArray:homeWorks];
        }
    }
    
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
    
}

- (void)fetchNewhomeWorksRereshingWithHUD:(BOOL) withHUD{
    
    DDLogDebug(@"fetchNewhomeWorks");
    __weak typeof(self) weakSelf = self;
    if (withHUD) {
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    }
    [[TXChatClient sharedInstance] fetchHomeWorks:YES maxHomeWorkId:LLONG_MAX onCompleted:^(NSError *error, NSArray *xcsdHomeWorks, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        
        if (withHUD) {
            [TXProgressHUD hideHUDForView:self.view animated:NO];
        }
        
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView.header endRefreshing];
            });
            [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
        }
        else
        {
            TXAsyncRunInMain(^{
                [weakSelf updatehomeWorksAfterHeaderRefresh:xcsdHomeWorks];
                [self updateEmptyDataImageStatus:[_homeWorkList count] > 0?NO:YES];
            });
            //bay gaoju  消息提示震动的修改
            //            if(lastOneHasChanged)
            //            {
            //                [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
            //            }
        }
        
    }];
}

- (void)updatehomeWorksAfterHeaderRefresh:(NSArray *)homeWorks
{
    @synchronized(_homeWorkList)
    {
        if(homeWorks != nil && [homeWorks count] > 0)
        {
                   //    [_homeWorkList removeAllObjects];
                   //   [_homeWorkList addObjectsFromArray:homeWorks];
            _homeWorkList = [NSMutableArray arrayWithArray:homeWorks];
        }
    }
    
    [_tableView reloadData];
    [_tableView scrollsToTop];
    [_tableView.header endRefreshing];
    
}



@end
