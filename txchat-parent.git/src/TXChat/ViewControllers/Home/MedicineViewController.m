//
//  MedicineViewController.m
//  TXChat
//
//  Created by lyt on 15-6-26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MedicineViewController.h"
#import "MedicineTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "MedicineDetailViewController.h"
#import "SendMedicineViewController.h"
#import <MJRefresh.h>
#import "MJTXRefreshNormalHeader.h"
//cell的高度
#define KCELLHIGHT 60

//每一页 加载数目
#define KNOTICESPAGE 20

@interface MedicineViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_medicineList;
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
}
@end

@implementation MedicineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _medicineList = [NSMutableArray arrayWithCapacity:5];
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
    self.titleStr = @"喂药";
    [self createCustomNavBar];
    [self.btnRight setImage:[UIImage imageNamed:@"medicine_pubulishNewIcon"] forState:UIControlStateNormal];
    
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
    [self addEmptyDataImage:YES showMessage:@"点击向班级老师发送给孩子喂药内容"];
    [self updateEmptyDataImageStatus:NO];

    [self setupRefresh];
    [self loadMailsFromLocal];
    [self registerNotification];
    self.view.backgroundColor = kColorWhite;
}

-(void)updateMedicineList
{
    DDLogDebug(@"fetchFeedMedicineTasks");
    WEAKSELF
    [[TXChatClient sharedInstance] fetchFeedMedicineTasks:LLONG_MAX onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
       if(error)
       {
           [self showFailedHudWithError:error];
           DDLogDebug(@"error:%@", error);
       }
       else
       {
           @synchronized(_medicineList)
           {
//               [_medicineList removeAllObjects];
//               [_medicineList addObjectsFromArray:txCheckIns];
               _medicineList = [NSMutableArray arrayWithArray:txCheckIns];
           }
           [_tableView.footer setHidden:!hasMore];
           dispatch_async(dispatch_get_main_queue(), ^{
               [_tableView reloadData];
           });
       }
        [weakSelf updateEmptyDataImageStatus:[_medicineList count] > 0?NO:YES];
        [weakSelf updateBackgroundColor];
    }];
}

-(void)updateBackgroundColor
{
    if([_medicineList count] > 0)
    {
        self.view.backgroundColor = kColorBackground;
        [_tableView setBackgroundColor:self.view.backgroundColor];
    }
    else
    {
        self.view.backgroundColor = kColorWhite;
        [_tableView setBackgroundColor:self.view.backgroundColor];
    }
}

-(void)loadMailsFromLocal
{
    NSError *error = nil;
    NSArray *medicines = [[TXChatClient sharedInstance] getFeedMedicineTasks:LLONG_MAX count:KNOTICESPAGE+1 error:&error];
    if(error)
    {
        [self showFailedHudWithError:error];
        DDLogDebug(@"error:%@", error);
    }
    else
    {
        @synchronized(_medicineList)
        {
            [_medicineList removeAllObjects];
            if([medicines count] > KNOTICESPAGE)
            {
                NSRange range = {0, KNOTICESPAGE};
                [_medicineList addObjectsFromArray:[medicines subarrayWithRange:range]];
            }
            else
            {
                [_medicineList addObjectsFromArray:medicines];
            }
        }
        TXAsyncRunInMain(^{
            [_tableView reloadData];
//            NSDictionary *dict = [self countValueForType:TXClientCountType_Medicine];
//            NSInteger countValue = [dict[TXClientCountNewValueKey] integerValue];
//            NSInteger oldValue = [dict[TXClientCountOldValueKey] integerValue];
//            if (countValue > oldValue || [_medicineList count] == 0) {
                [_tableView.header beginRefreshing];
//            }
        });
    }
    [self updateEmptyDataImageStatus:[_medicineList count] > 0?NO:YES];
    [self updateBackgroundColor];
}


- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];        
    }
    else
    {
        [self sendMedicineVC];
    }
}

-(void)sendMedicineVC
{
    SendMedicineViewController *sendMedicineVC = [[SendMedicineViewController alloc] init];
    [self.navigationController pushViewController:sendMedicineVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
    [_tableView reloadData];
}


-(void)registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(medicineUpdate:) name:NOTIFY_UPDATE_MEDICINES object:nil];
}

-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_UPDATE_MEDICINES object:nil];
}

-(void)medicineUpdate:(NSNotification *)notification
{
    [self updateMedicineList];
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
    return [_medicineList count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MedicineTableViewCell";
    DLog(@"section:%ld, rows:%ld", (long)indexPath.section, (long)indexPath.row);
    UITableViewCell *cell = nil;
    MedicineTableViewCell *medicineCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (medicineCell == nil) {
        medicineCell = [[[NSBundle mainBundle] loadNibNamed:@"MedicineTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXFeedMedicineTask *medicine = [_medicineList objectAtIndex:indexPath.row];
    [medicineCell.headerImageview setImage:[UIImage imageNamed:@"medicine_showIcon"]];
    [medicineCell.contentLabel setText:medicine.content];
    [medicineCell.unreadImageView setHidden:medicine.isRead];
    if(indexPath.row == [_medicineList count] -1)
    {
        [medicineCell.seperatorLine setHidden:YES];
    }
    cell = medicineCell;
    return cell;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        if(indexPath.row < [_medicineList count])
//        {
//            [_medicineList removeObjectAtIndex:indexPath.row];
//            TXAsyncRunInMain(^{
//                [tableView reloadData];
//            });
//        }
//    }
//}

#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXFeedMedicineTask *medicine = [_medicineList objectAtIndex:indexPath.row];
    MedicineDetailViewController *medicineDetailVC = [[MedicineDetailViewController alloc] initWithMedicine:medicine];
    [self.navigationController pushViewController:medicineDetailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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

//集成刷新控件
- (void)setupRefresh
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
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


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewMedicinesRereshing];
    });
}
- (void)footerRereshing{
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{
    int64_t beginMedicineId = 0;
    if(_medicineList != nil && [_medicineList count] > 0)
    {
        TXFeedMedicineTask *beginMedicine = _medicineList.lastObject;
        beginMedicineId = beginMedicine.feedMedicineTaskId;
    }
    DDLogDebug(@"fetchFeedMedicineTasks");
    WEAKSELF
    [[TXChatClient sharedInstance]  fetchFeedMedicineTasks:beginMedicineId onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
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
            [weakSelf updateMedicinesAfterFooterReresh:txCheckIns];
            [_tableView.footer setHidden:!hasMore];
        }
        [weakSelf updateEmptyDataImageStatus:[_medicineList count] > 0?NO:YES];
        [weakSelf updateBackgroundColor];
    }];
}



-(void)updateMedicinesAfterFooterReresh:(NSArray *)medicines
{
    @synchronized(_medicineList)
    {
        if(medicines != nil && [medicines count] > 0)
        {
            [_medicineList addObjectsFromArray:medicines];
        }
    }
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
    
}


- (void)fetchNewMedicinesRereshing{
    DDLogDebug(@"fetchFeedMedicineTasks");
    WEAKSELF
    [[TXChatClient sharedInstance]  fetchFeedMedicineTasks:LLONG_MAX onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
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
            [weakSelf updateMedicinesAfterHeaderRefresh:txCheckIns];
            [_tableView.footer setHidden:!hasMore];
        }
        [weakSelf updateEmptyDataImageStatus:[_medicineList count] > 0?NO:YES];
        [weakSelf updateBackgroundColor];
    }];
}

- (void)updateMedicinesAfterHeaderRefresh:(NSArray *)medicines
{
    @synchronized(_medicineList)
    {
        if(medicines != nil && [medicines count] > 0)
        {
//            [_medicineList removeAllObjects];
//            [_medicineList addObjectsFromArray:medicines];
            _medicineList = [NSMutableArray arrayWithArray:medicines];
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
    [self sendMedicineVC];
}


@end
