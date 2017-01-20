//
//  LeaveListViewController.m
//  TXChatParent
//
//  Created by lyt on 15/11/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "LeaveListViewController.h"
#import "MJTXRefreshNormalHeader.h"
#import <MJRefresh.h>
#import "LeaveDetailTableViewCell.h"
#import "NSDate+TuXing.h"
#import <CNPPopupController.h>
#import "UIImageView+EMWebCache.h"
#import <NSDate+DateTools.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CGContext.h>
#import "BabyAttendanceViewController.h"

#define KPARENTCELLBASETAG 0x1000
#define KHEADERVIEWBASETAG 0x2000
#define KCELLHIGHT (80.0f)
#define KBabyViewHight 30.0f*kScale
#define KSECTIONHEIGHT (12.0f*kScale)
#define KRightMargin 0.0f

@interface LeaveListViewController ()<UITableViewDataSource,UITableViewDelegate,CNPPopupControllerDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_leaveList;
    BOOL _isRequestForLeaveSuccess;
}
@property (nonatomic, strong) CNPPopupController *popupController;
@end

@implementation LeaveListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _leaveList = [NSMutableArray arrayWithCapacity:5];
        _isRequestForLeaveSuccess = NO;
    }
    return self;
}


-(id)initWithLeaveResult:(BOOL)isSuccess
{
    self = [super init];
    if(self)
    {
        _isRequestForLeaveSuccess = isSuccess;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"请假记录";
    [self createCustomNavBar];
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.sectionIndexColor = kColorGray;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:_tableView];
    
    
    UIView *superview = self.view;
    WEAKSELF
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).with.insets(UIEdgeInsetsMake(weakSelf.customNavigationView.maxY, 0, 0, 0));
    }];
    
    [self setupRefresh];
    [self resetLeavesUnreadState];
    [_tableView.header beginRefreshing];
    [self addEmptyDataImage:NO showMessage:@"没有请假记录"];
    [self updateEmptyDataImageStatus:NO];
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
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        if(!_isRequestForLeaveSuccess)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIViewController *viewController = [self getBabyAttendanceViews];
            if(viewController)
            {
                [self.navigationController popToViewController:viewController animated:YES];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}

-(UIViewController *)getBabyAttendanceViews
{
    __block BabyAttendanceViewController *attendanceViewController = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([[obj class] isSubclassOfClass:[BabyAttendanceViewController class]])
        {
            *stop = YES;
            attendanceViewController = (BabyAttendanceViewController *)obj;
        }
    }];
    return attendanceViewController;
}

-(void)resetLeavesUnreadState
{
    NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
    if(unreadCountDic)
    {
        NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_APPROVE];
        if([countValue integerValue] > 0)
        {
            [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_APPROVE];
        }
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _leaveList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row >= [_leaveList count])
    {
        return nil;
    }
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier = @"LeaveDetailTableViewCell";
    LeaveDetailTableViewCell *leaveCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (leaveCell == nil) {
        leaveCell = [[[NSBundle mainBundle] loadNibNamed:@"LeaveDetailTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    TXPBLeave *leave = [_leaveList objectAtIndex:indexPath.row];
    
    leaveCell.resolvedStatus = leave.status;
    leaveCell.leaveReasonLabel.text = leave.reason;
    NSDate *createTime = [NSDate dateWithTimeIntervalInMilliSecondSince1970:leave.createdOn/1000];
    leaveCell.leaveTimeLabel.text = [createTime formattedDateToLeaveDescription];
    leaveCell.leaveType = leave.leaveType;
    leaveCell.leaveCountLabel.text = [NSString stringWithFormat:@"%@天", @(leave.days)];
    leaveCell.selectionStyle = UITableViewCellSelectionStyleNone;
    [leaveCell.headerImageView TX_setImageWithURL:[NSURL URLWithString:[leave.userAvatar getFormatPhotoUrl:40 hight:40]]  placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    cell = leaveCell;
    return cell;
}

#pragma mark-  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return KCELLHIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{

    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TXPBLeave *leave = [_leaveList objectAtIndex:indexPath.row];
    if(leave)
    {
        [self showLeaveDetail:leave];
    }
}


-(void)showLeaveDetail:(TXPBLeave *)leave
{
    @weakify(self);
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if(user == nil)
    {
        return;
    }
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = kColorWhite;
    
    CGFloat width = kScreenWidth - 70.0f;
    CGFloat hight = 341.0f;
    CGFloat titleHight = 21.0f;
    CGFloat rightMargin = 20.0f;
    
    contentView.frame = CGRectMake(0, 0, width, hight);
    
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImg = [UIImage imageNamed:@"attendance_close"];
    [closeBtn setImage:closeImg forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(width-8 - closeImg.size.width, 8, closeImg.size.width, closeImg.size.height);
    [closeBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
         [self.popupController dismissPopupControllerAnimated:YES];
        self.popupController = nil;
    }];
    [contentView addSubview:closeBtn];
    
    UIImageView *headerView = [[UIImageView alloc] init];
    CGFloat headerImageViewWidth = 50.0f;
    [headerView TX_setImageWithURL:[NSURL URLWithString:[leave.userAvatar getFormatPhotoUrl:headerImageViewWidth hight:headerImageViewWidth]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    headerView.layer.cornerRadius = 8.0f/2.0f;
    headerView.layer.masksToBounds = YES;
    headerView.frame = CGRectMake(20, 20, headerImageViewWidth, headerImageViewWidth);
    [contentView addSubview:headerView];
    
    UILabel *nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.text = leave.userName;
    nickNameLabel.textColor = KColorSubTitleTxt;
    nickNameLabel.font = kFontSubTitle;
    nickNameLabel.frame = CGRectMake(headerView.maxX + 9, 22, 150, 25);
    [contentView addSubview:nickNameLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    NSDate *leaveDate = [NSDate dateWithTimeIntervalSince1970:leave.createdOn/1000];
    timeLabel.text = [NSString stringWithFormat:@"%04ld-%ld-%ld  %ld:%ld", (long)leaveDate.year, (long)leaveDate.month, (long)leaveDate.day, (long)leaveDate.hour, (long)leaveDate.minute];
    timeLabel.font = kFontSmall;
    timeLabel.textColor = RGBCOLOR(0x88, 0x88, 0x88);
    timeLabel.frame = CGRectMake(nickNameLabel.minX, nickNameLabel.maxY-2, 150, 25);
    [contentView addSubview:timeLabel];
    
    UIImageView *imageView1 = [[UIImageView alloc] init];
    imageView1.frame = CGRectMake(headerView.minX+headerView.width_/2, headerView.maxY + 5, 1, 21+5);
    imageView1.image = [LeaveListViewController createDottedLineView:imageView1];
    [contentView addSubview:imageView1];
    
    UIScrollView *scroller = [[UIScrollView alloc] init];
    scroller.frame = CGRectMake(0, headerView.maxY+31, width, 200);
    [contentView addSubview:scroller];
    
    
    UILabel *reasonTitle = [[UILabel alloc] init];
    reasonTitle.text = @"原因:";
    reasonTitle.font  = kFontSubTitle;
    reasonTitle.textColor = KColorSubTitleTxt;
    CGFloat reasonTitleWidth = 34.f;
    reasonTitle.frame = CGRectMake(headerView.minX+headerView.width_/2-reasonTitleWidth/2, 0, reasonTitleWidth, titleHight);
    [scroller addSubview:reasonTitle];
    
    UILabel *reasonLabel = [[UILabel alloc] init];
    reasonLabel.text = leave.reason;
    reasonLabel.font  = kFontSubTitle;
    reasonLabel.textColor = KColorSubTitleTxt;
    reasonLabel.frame = CGRectMake(reasonTitle.maxX + 20, reasonTitle.minY, width - (reasonTitle.maxX + 20) - rightMargin, 100);
    reasonLabel.numberOfLines = 0;
    [reasonLabel sizeToFit];
    [scroller addSubview:reasonLabel];
    if(reasonLabel.height_ < titleHight)
    {
        reasonLabel.height_ = titleHight;
    }
    
    CGFloat beginY = 0;
    if(leave.reason && [leave.reason length] > 0)
    {
        beginY = reasonLabel.maxY+15.0f;
    }
    else
    {
        beginY = reasonTitle.maxY+15.0f;
    }
    
    UILabel *daysTitle = [[UILabel alloc] init];
    daysTitle.text = @"天数:";
    daysTitle.font  = kFontSubTitle;
    daysTitle.textColor = KColorSubTitleTxt;
    CGFloat daysTitleWidth = 34.f;
    daysTitle.frame = CGRectMake(headerView.minX+headerView.width_/2-daysTitleWidth/2, beginY, daysTitleWidth, titleHight);
    [scroller addSubview:daysTitle];
    
    UILabel *daysLabel = [[UILabel alloc] init];
    daysLabel.text = [NSString stringWithFormat:@"%@天", @(leave.days)];
    daysLabel.font  = kFontSubTitle;
    daysLabel.textColor = KColorSubTitleTxt;
    daysLabel.frame = CGRectMake(reasonTitle.maxX + 20, daysTitle.minY, 100, titleHight);
    [scroller addSubview:daysLabel];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
    imageView2.frame = CGRectMake(headerView.minX+headerView.width_/2, reasonTitle.maxY + 5, 1, daysTitle.minY - 7- reasonTitle.maxY);
    imageView2.image = [LeaveListViewController createDottedLineView:imageView2];
    [scroller addSubview:imageView2];
    
    UILabel *dateTitle = [[UILabel alloc] init];
    dateTitle.text = @"日期:";
    dateTitle.font  = kFontSubTitle;
    dateTitle.textColor = KColorSubTitleTxt;
    CGFloat dateTitleWidth = 34.f;
    dateTitle.frame = CGRectMake(headerView.minX+headerView.width_/2-dateTitleWidth/2, daysTitle.maxY+15, dateTitleWidth, titleHight);
    [scroller addSubview:dateTitle];
    
    UILabel *datesLabel = [[UILabel alloc] init];
    
    NSMutableString *datesStr = [NSMutableString stringWithCapacity:1];
    for(NSInteger i = 0; i < leave.dates.count; i++)
    {
        NSNumber *currentDateValue = (NSNumber *)(leave.dates[i]);
        NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentDateValue.longLongValue/1000];
        [datesStr appendFormat:@"%@月%@日",@(currentDate.month), @(currentDate.day)];
        if(i != leave.dates.count-1)
        {
            [datesStr appendFormat:@","];
        }
    }
    
    datesLabel.text = datesStr;
    datesLabel.font  = kFontSubTitle;
    datesLabel.textColor = KColorSubTitleTxt;
    datesLabel.frame = CGRectMake(dateTitle.maxX + 20, dateTitle.minY, width-(dateTitle.maxX + 20) -rightMargin, 21);
    datesLabel.numberOfLines = 0;
    [datesLabel sizeToFit];
    [scroller addSubview:datesLabel];
    if(datesLabel.height_ < titleHight)
    {
        datesLabel.height_ = titleHight;
    }
    
    UIImageView *imageView3 = [[UIImageView alloc] init];
    imageView3.frame = CGRectMake(headerView.minX+headerView.width_/2, daysTitle.maxY + 5, 1, dateTitle.minY - 10- daysTitle.maxY);
    imageView3.image = [LeaveListViewController createDottedLineView:imageView3];
    [scroller addSubview:imageView3];
    
    UILabel *statusTitle = [[UILabel alloc] init];
    statusTitle.text = @"状态:";
    statusTitle.font  = kFontSubTitle;
    statusTitle.textColor = KColorSubTitleTxt;
    CGFloat statusTitleWidth = 34.f;
    statusTitle.frame = CGRectMake(headerView.minX+headerView.width_/2-statusTitleWidth/2, datesLabel.maxY+15, statusTitleWidth, titleHight);
    [scroller addSubview:statusTitle];
    
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.text = (leave.status == TXPBLeaveStatusApplied)?@"未处理": @"老师已确认";
    statusLabel.font  = kFontSubTitle;
    statusLabel.textColor = KColorSubTitleTxt;
    statusLabel.frame = CGRectMake(reasonTitle.maxX + 20, statusTitle.minY, 140, titleHight);
    [scroller addSubview:statusLabel];
    
    UIImageView *imageView4 = [[UIImageView alloc] init];
    imageView4.frame = CGRectMake(headerView.minX+headerView.width_/2, dateTitle.maxY + 5, 1, statusTitle.minY - 10- dateTitle.maxY);
    imageView4.image = [LeaveListViewController createDottedLineView:imageView4];
    [scroller addSubview:imageView4];
    
    if(leave.reply && [leave.reply length] > 0)
    {
    
        UILabel *replyTitle = [[UILabel alloc] init];
        replyTitle.text = @"备注:";
        replyTitle.font  = kFontSubTitle;
        replyTitle.textColor = KColorSubTitleTxt;
        CGFloat replyTitleWidth = 34.f;
        replyTitle.frame = CGRectMake(headerView.minX+headerView.width_/2-replyTitleWidth/2, statusTitle.maxY+15, replyTitleWidth, titleHight);
        [scroller addSubview:replyTitle];
        
        UILabel *replyLabel = [[UILabel alloc] init];
        replyLabel.text = leave.reply;
        replyLabel.font  = kFontSubTitle;
        replyLabel.textColor = KColorSubTitleTxt;
        replyLabel.frame = CGRectMake(replyTitle.maxX + 20, replyTitle.minY, width - (replyTitle.maxX + 20) - rightMargin, 100);
        replyLabel.numberOfLines = 0;
        [replyLabel sizeToFit];
        [scroller addSubview:replyLabel];
        if(replyLabel.height_ < titleHight)
        {
            replyLabel.height_ = titleHight;
        }
        
        UIImageView *imageView5 = [[UIImageView alloc] init];
        imageView5.frame = CGRectMake(headerView.minX+headerView.width_/2, statusTitle.maxY + 5, 1, replyTitle.minY - 10- statusTitle.maxY);
        imageView5.image = [LeaveListViewController createDottedLineView:imageView5];
        [scroller addSubview:imageView5];
        
        contentView.frame = CGRectMake(0, 0, width, scroller.maxY );
        scroller.contentSize = CGSizeMake(width, replyLabel.maxY+20 );
        
    }
    else
    {
        contentView.frame = CGRectMake(0, 0, width, scroller.maxY);
        scroller.contentSize = CGSizeMake(width, statusLabel.maxY+20 );
    }
    scroller.showsVerticalScrollIndicator = YES;
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[contentView]];
    CNPPopupTheme *customTheme = [CNPPopupTheme defaultTheme];
    customTheme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    customTheme.backgroundColor = [UIColor clearColor];
    customTheme.contentVerticalPadding = 0.0f;
    customTheme.maxPopupWidth = width;
    self.popupController.theme = customTheme;
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTab:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.cancelsTouchesInView = NO;
    contentView.userInteractionEnabled = YES;
    [contentView addGestureRecognizer:tap];
}
-(void)dismissTab:(UITapGestureRecognizer*)recognizer
{
    [self.popupController dismissPopupControllerAnimated:YES];
    self.popupController = nil;
}


+ (UIImage *)createDottedLineView:(UIImageView *)imgView{
    UIGraphicsBeginImageContext(imgView.frame.size);   //开始画线
    [imgView.image drawInRect:CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
//    CGFloat lengths[] = {1,100,1,100};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, kColorLine.CGColor);
    CGFloat lengths1[] = {1,2};
    CGContextSetLineDash(line, 0, lengths1, 2);
    CGContextMoveToPoint(line, 0.0, 0);
    CGContextAddLineToPoint(line, 0.0, imgView.height_);
    CGContextStrokePath(line);
    CGContextStrokePath(line);
    
    return  UIGraphicsGetImageFromCurrentImageContext();
}


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
        [weakSelf fetchNewLeavesRereshing];
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
    int64_t beginLeaveId = 0;
    if(_leaveList != nil && [_leaveList count] > 0)
    {
        TXPBLeave *beginLeave = _leaveList.lastObject;
        beginLeaveId = beginLeave.id;
    }
    TXUser *current = [[TXChatClient sharedInstance] getCurrentUser:nil];
    @weakify(self);
    [[TXChatClient sharedInstance].checkInManager fetchLeaves:beginLeaveId userId:current.childUserId onCompleted:^(NSError *error, NSArray *leaves, BOOL hasMore) {
        @strongify(self);
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
            [self updateLeavesAfterFooterReresh:leaves];
            [_tableView.footer setHidden:!hasMore];
        }
        [self updateDefaultImgStatus];
    }];
}



-(void)updateLeavesAfterFooterReresh:(NSArray *)leaves
{
    @synchronized(_leaveList)
    {
        if(leaves != nil && [leaves count] > 0)
        {
            [_leaveList addObjectsFromArray:leaves];
        }
    }
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
    
}


- (void)fetchNewLeavesRereshing{
    @weakify(self);
    TXUser *current = [[TXChatClient sharedInstance] getCurrentUser:nil];
    [[TXChatClient sharedInstance].checkInManager fetchLeaves:LONG_MAX userId:current.childUserId onCompleted:^(NSError *error, NSArray *leaves, BOOL hasMore)
    {
        @strongify(self);
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
            [self updateLeavesAfterHeaderRefresh:leaves];
            [_tableView.footer setHidden:!hasMore];
        }
        [self updateDefaultImgStatus];
    }];
}

- (void)updateLeavesAfterHeaderRefresh:(NSArray *)leaves
{
    @synchronized(_leaveList)
    {
        if(leaves != nil && [leaves count] > 0)
        {
            _leaveList = [NSMutableArray arrayWithArray:leaves];
        }
    }
    [_tableView.header endRefreshing];
    [_tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView scrollsToTop];
    });
}

#pragma mark - CNPPopupController Delegate
- (void)popupControllerDidDismiss:(CNPPopupController *)controller
{
    NSLog(@"Dismissed with button");
    self.popupController = nil;
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}

#pragma mark-- 无数据时 默认图片

-(void)updateDefaultImgStatus
{
    [self updateEmptyDataImageStatus:_leaveList.count > 0? NO:YES];
}

@end

