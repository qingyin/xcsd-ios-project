//
//  CheckInListViewController.m
//  TXChatTeacher
//
//  Created by lyt on 15/9/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CheckInListViewController.h"
#import "CheckInDetailTableViewCell.h"
#import "CheckInTitleTableViewCell.h"
#import <TXChatClient.h>
#import <MJRefresh.h>
#import "MJRefreshBackStateFooter.h"
#import "MJRefreshAutoStateFooter.h"
#import "NSDate+TuXing.h"
#define KPARENTCELLBASETAG 0x1000
#define KHEADERVIEWBASETAG 0x2000
#define KCELLHIGHT 44.0f
#define KSECTIONHEIGHT 30.f

#define KPageNumbers  20

#define KCheckInType        @"chekcInType"
#define KCheckInChildName   @"chekcInChildName"
#define KCheckInParentType  @"chekcInParentType"
#define KCheckInTime        @"chekcInTime"
#define KCheckInStatus      @"chekcInStatus"

typedef enum
{
    CheckInType_manual, //手动补签
    CheckInType_mobile, //手机刷卡
    CheckInType_machine,//刷卡机刷卡
}CheckInType;


@interface CheckInListViewController()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_checkInList;
    NSInteger _uploadingCount;
}
@end

@implementation CheckInListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _uploadingCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"幼儿扫描记录";
    [self createCustomNavBar];
//    [self.btnRight setTitle:@"9月22日" forState:UIControlStateNormal];
    [self.btnRight setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [self.btnRight setTitleColor:kColorNavigationTitle forState:UIControlStateNormal];
    self.btnRight.hidden = NO;
    [self setupViews];
    [self setupRefresh];
    [self updateCheckInList];
    [_tableView reloadData];
    [self registerNotification];
}

-(void)setupViews
{
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = KCELLHIGHT;
    _tableView.sectionIndexColor = kColorGray;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:_tableView];
    UIView *superview = self.view;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
         __weak __typeof(&*self) weakSelf=self;  //by sck
        [self showHighlightedSheetWithTitle:nil normalItems:nil highlightedItems:@[@"重新上传"] otherItems:@[@"清除上传成功记录"] clickHandler:^(NSInteger index) {
            if (index == 1) {
                [[TXChatClient sharedInstance].checkInManager clearAllSucceedQrCheckInItems];
                [weakSelf updateCheckInList];
                [_tableView reloadData];
                [weakSelf showSuccessHudWithTitle:@"清除上传成功记录成功"];
            }
            else if(index == 0)
            {
                [[TXChatClient sharedInstance].checkInManager uploadAllQrCheckInItems];
                [weakSelf showSuccessHudWithTitle:@"重新上传成功"];
            }
        } completion:nil];
//        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"重新上传" otherButtonTitles:@"清除上传成功记录", nil];
//        [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [[TXChatClient sharedInstance].checkInManager clearAllSucceedQrCheckInItems];
//                [weakSelf updateCheckInList];
//                [_tableView reloadData];
//                [weakSelf showSuccessHudWithTitle:@"清除上传成功记录成功"];
//            }
//            else if(buttonIndex == 0)
//            {
//                [[TXChatClient sharedInstance].checkInManager uploadAllQrCheckInItems];
//                [weakSelf showSuccessHudWithTitle:@"重新上传成功"];
//            }
//        }];
    }
}

-(void)updateCheckInList
{
    _uploadingCount = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItemCount];
    NSArray *checkIns = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItems:NSIntegerMax count:KPageNumbers];
    _checkInList = [NSMutableArray arrayWithArray:checkIns];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUploadingCount) name:TX_NOTIFICATION_QR_CHECK_IN_COUNT_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUploadingFailed:) name:TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUploadingSuccess:) name:TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_SUCCEED object:nil];
    
}

-(void)unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TX_NOTIFICATION_QR_CHECK_IN_COUNT_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_FAILED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TX_NOTIFICATION_QR_CHECK_IN_UPLOAD_SUCCEED object:nil];

}

-(void)updateUploadingCount
{
    _uploadingCount = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItemCount];
    [_tableView reloadData];
}

-(void)updateUploadingSuccess:(NSNotification *)notification
{
    NSNumber *checnInIdNumber = (NSNumber *)notification.object;
    if(checnInIdNumber == nil)
    {
        return ;
    }
    TXQrCheckInItem *checkItem = [self searchCheckInById:checnInIdNumber.longLongValue];
    checkItem.status =  TXQrCheckInItemStatusUploadSucceed;
    [_tableView reloadData];
}

-(void)updateUploadingFailed:(NSNotification *)notification
{
    NSNumber *checnInIdNumber = (NSNumber *)notification.object;
    if(checnInIdNumber == nil)
    {
        return ;
    }
    TXQrCheckInItem *checkItem = [self searchCheckInById:checnInIdNumber.longLongValue];
    checkItem.status =  TXQrCheckInItemStatusUploadFailed;
    [_tableView reloadData];
}

-(TXQrCheckInItem *)searchCheckInById:(int64_t)checkInId
{
    __block TXQrCheckInItem *checkItem = nil;
    if(checkInId == 0 || [_checkInList count] == 0)
    {
        return checkItem;
    }
    
    [_checkInList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TXQrCheckInItem *item = (TXQrCheckInItem *)obj;
        if(item && item.id == checkInId)
        {
            checkItem = item;
            *stop = YES;
        }
    }];
    return checkItem;
}



#pragma mark-  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if(section == 0)
    {
        rows = 1;
    }
    else
    {
//        NSArray *array = (NSArray *)[_checkInList objectAtIndex:section];
        rows = [_checkInList count];
    }
    return rows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0)
    {
        static NSString *titleCellIdentifier = @"CheckInTitleTableViewCell";
        CheckInTitleTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
        if (titleCell == nil) {
            titleCell =[[[NSBundle mainBundle] loadNibNamed:@"CheckInTitleTableViewCell" owner:self options:nil] objectAtIndex:0];;
        }
        cell = titleCell;
    }
    else
    {
        static NSString *detailCellIdentifier = @"CheckInDetailTableViewCell";
        CheckInDetailTableViewCell *detailCell = [tableView dequeueReusableCellWithIdentifier:detailCellIdentifier];
        if (detailCell == nil) {
            detailCell =[[[NSBundle mainBundle] loadNibNamed:@"CheckInDetailTableViewCell" owner:self options:nil] objectAtIndex:0];;
        }
        TXQrCheckInItem *checkIn = [_checkInList objectAtIndex:indexPath.row];
        
        if([checkIn.targetUsername length] > 0)
        {
            [detailCell.cardNumberOrNickNameLabel setText:[NSString stringWithFormat:@"%@", checkIn.targetUsername]];
        }
        else
        {
            [detailCell.cardNumberOrNickNameLabel setText:checkIn.targetCardNumber];
        }
        [detailCell.timeLabel setText:[NSDate timeForCheckInStyle:[NSString stringWithFormat:@"%@", @(checkIn.createdOn/1000)]]];
        NSString *statusStr = nil;
        UIColor *color = nil;
        switch (checkIn.status) {
            case TXQrCheckInItemStatusUploading:
                statusStr = @"正在上传";
                color = kColorStatusYellow;
                break;
            case TXQrCheckInItemStatusUploadFailed:
                statusStr = @"上传失败";
                color = kColorStatusPink;
                break;
            case TXQrCheckInItemStatusUploadSucceed:
                statusStr = @"已上传";
                color = kColorStatusBlue;
                break;
            default:
                break;
        }
        [detailCell.statusLabel setText:statusStr];
        [detailCell.statusLabel setTextColor:color];

        cell = detailCell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLHIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat headerHight = 0;
    if(_uploadingCount > 0 && section == 0)
    {
        headerHight = KSECTIONHEIGHT;
    }
    return headerHight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UIView *headerView = nil;
    if(_uploadingCount > 0 && section == 0)
    {
        headerView = [[UIView alloc] init];
        headerView.frame = CGRectMake(0, 0, kScreenWidth, KSECTIONHEIGHT);
        headerView.backgroundColor = RGBCOLOR(255, 255, 207);
        UILabel *title = [[UILabel alloc] init];
        title.text = [NSString stringWithFormat:@"您有%@扫码签到正在上传", @(_uploadingCount)];
        title.frame = CGRectMake(0, 0, kScreenWidth, KSECTIONHEIGHT);
        title.font = kFontSubTitle;
        title.textColor = RGBCOLOR(0x44, 0xa5, 0xff);
        title.textAlignment = NSTextAlignmentCenter;
        [headerView addSubview:title];
    }
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


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
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    NSArray *checkIns = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItems:NSIntegerMax count:KPageNumbers];;
    _checkInList = [NSMutableArray arrayWithArray:checkIns];
    _uploadingCount = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItemCount];
    [_tableView reloadData];
    [_tableView.header endRefreshing];
}


- (void)footerRereshing{
    int64_t max =  NSIntegerMax;
    if([_checkInList count] > 0)
    {
        TXQrCheckInItem *checkInItem = _checkInList.lastObject;
        max = checkInItem.id;
    }
    NSArray *checkIns = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItems:max count:KPageNumbers];
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_checkInList];
    [newArray addObjectsFromArray:checkIns];
    _checkInList = newArray;
    _uploadingCount = [[TXChatClient sharedInstance].checkInManager queryQrCheckInItemCount];
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
}

@end
