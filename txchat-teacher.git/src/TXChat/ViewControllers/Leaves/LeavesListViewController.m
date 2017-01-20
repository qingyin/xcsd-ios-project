//
//  LeavesListViewController.m
//  TXChatTeacher
//
//  Created by Cloud on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "LeavesListViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "LeavesTableViewCell.h"
#import <MJRefresh.h>
#import "STPopup.h"
#import "LeaveDetailViewController.h"

@interface LeavesListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
}

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation LeavesListViewController

- (void)viewDidLoad {
    self.titleStr = @"请假记录";
    [super viewDidLoad];
    [self createCustomNavBar];
    
    self.listArr = [NSMutableArray array];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, kScreenWidth, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    _listTableView.delegate = self;
    _listTableView.backgroundColor = kColorBackground;
    _listTableView.dataSource = self;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    [self setupRefresh];
    
    [_listTableView registerClass:[LeavesTableViewCell class] forCellReuseIdentifier:@"CellIdentifier"];
    
    [_listTableView.header beginRefreshing];
    [self addEmptyDataImage:NO showMessage:@"没有请假记录"];
    [self updateEmptyDataImageStatus:NO];
    
    // Do any additional setup after loading the view.
    [self resetLeavesUnreadState];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader =[MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _listTableView.header = gifHeader;

    _listTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
}

//下拉刷新
- (void)headerRereshing{
    [self fetchLeaves:NO];
}

- (void)footerRereshing{
    [self fetchLeaves:YES];
}

- (void)fetchLeaves:(BOOL)isFooter{
    _isRefresh = YES;
    TXPBLeave *leave = nil;
    if (_listArr.count && isFooter) {
        leave = [_listArr lastObject];
    }
    DDLogDebug(@"fetchLeaves");
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
//    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    [[TXChatClient sharedInstance].checkInManager fetchLeaves:leave?leave.id:LLONG_MAX userId:0 onCompleted:^(NSError *error, NSArray *leaves, BOOL hasMore) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        [tmpObject.listTableView.footer endRefreshing];
        [tmpObject.listTableView.header endRefreshing];
        if (error) {
            tmpObject.listTableView.footer.hidden = YES;
            [tmpObject.listTableView.footer noticeNoMoreData];
            [tmpObject showFailedHudWithError:error];
        }else{
            if (!isFooter) {
                [_listArr removeAllObjects];
            }
            NSMutableArray *arr = [NSMutableArray array];
            [leaves enumerateObjectsUsingBlock:^(TXPBLeave *leave, NSUInteger idx, BOOL *stop) {
                leave.isCompleted = (leave.status == TXPBLeaveStatusApplied)?[NSNumber numberWithBool:NO]:[NSNumber numberWithBool:YES];
                [arr addObject:leave];
            }];
            [tmpObject.listArr addObjectsFromArray:arr];
            [tmpObject.listTableView reloadData];
            if (!hasMore) {
                tmpObject.listTableView.footer.hidden = YES;
                [tmpObject.listTableView.footer noticeNoMoreData];
            }else{
                tmpObject.listTableView.footer.hidden = NO;
                [tmpObject.listTableView.footer resetNoMoreData];
            }
        }
        tmpObject.isRefresh = NO;
        [tmpObject updateDefaultImgStatus];
    }];
}



- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(void)resetLeavesUnreadState
{
    NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
    if(unreadCountDic)
    {
        NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_REST];
        if([countValue integerValue] > 0)
        {
            [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_REST];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)tmpObject = self;
    return [tableView fd_heightForCellWithIdentifier:@"CellIdentifier" cacheByIndexPath:indexPath configuration:^(LeavesTableViewCell *cell) {
        cell.leave = tmpObject.listArr[indexPath.row];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    LeavesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.leave = _listArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LeaveDetailViewController *avc = [[LeaveDetailViewController alloc] initWithLeave:_listArr[indexPath.row]];
    avc.listVC = self;
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:avc];
    popupController.cornerRadius = 4;
    popupController.navigationBarHidden = YES;
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [popupController presentInViewController:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)updateDefaultImgStatus
{
    [self updateEmptyDataImageStatus:_listArr.count > 0? NO:YES];
}

@end
