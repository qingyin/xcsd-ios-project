//
//  BabyAttendanceViewController.m
//  TXChatParent
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BabyAttendanceViewController.h"
#import "TXAttendanceDayView.h"
#import "TXCalendarView.h"
#import "UIButton+EMWebCache.h"
#import "UIImage+Rotate.h"
#import <extobjc.h>
#import <NSDate+DateTools.h>
#import "TXCalendarWeekModel.h"
#import "TXCalendarDayModel.h"
#import "LeaveViewController.h"
#import "GuardianDetailViewController.h"
#import "TXCalendarManager.h"

@interface BabyAttendanceViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_contentView;//滚动条内的view;
    NSMutableArray *_attendanceInfos;
    NSDate *_showDate;
    TXCalendarView *_calendarView;
    UILabel *_showMonthLabel;
    UILabel *_presentDaysLabel;
    NSInteger _presentDays;
    UIButton *_leftMonthBtn;
    UIButton *_rightMonthBtn;
    UIButton *_askOffBtn;
}
@end

@implementation BabyAttendanceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _attendanceInfos = [NSMutableArray arrayWithCapacity:1];
        _showDate = [NSDate date];
        _presentDays = 0;
    }
    return self;
}

-(void)dealloc
{
    [_calendarView removeFromSuperview];
    _calendarView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"考勤";
    [self createCustomNavBar];
    self.view=super.view;
    [self setupViews];
    self.view.backgroundColor = kColorWhite;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        [self updateDefaultDatas];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestCurrentMonth];
        });
    });
}



-(void)setupViews
{
    @weakify(self);
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY+44, 0, 0, 0));
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorWhite];
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.width.equalTo(_scrollView);
    }];
    //创建顶部出勤日期View
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = kColorClear;
    [_contentView addSubview:topView];
    
    UIImageView *topBgImgView = [[UIImageView alloc] init];
    UIImage *attendanceBgImg = [UIImage imageNamed:@"attendance_topBgImg"];
    [topBgImgView setImage: attendanceBgImg];
    topBgImgView.contentMode = UIViewContentModeScaleAspectFit;
    [topView addSubview:topBgImgView];
    [topBgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(topView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    UILabel *topBeginLabel = [[UILabel alloc] init];
    topBeginLabel.text = @"本月出勤";
    topBeginLabel.textColor = kColorWhite;
    topBeginLabel.font = kFontLarge;
    [topView addSubview:topBeginLabel];
    [topBeginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(topView);
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(topView.mas_bottom).with.offset(-12);
    }];

    UILabel *topMidLabel = [[UILabel alloc] init];
    topMidLabel.text = @"25";
    topMidLabel.textColor = kColorWhite;
    topMidLabel.font = [UIFont systemFontOfSize:45];
    topMidLabel.textAlignment = NSTextAlignmentCenter;
    _presentDaysLabel = topMidLabel;
    [topView addSubview:topMidLabel];
    [topMidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(topBeginLabel.mas_bottom).with.offset(9);
        make.left.mas_equalTo(topBeginLabel.mas_right).with.offset(5);    
    }];
    
    UILabel *endBeginLabel = [[UILabel alloc] init];
    endBeginLabel.text = @"天";
    endBeginLabel.textColor = kColorWhite;
    endBeginLabel.font = kFontLarge;
    [topView addSubview:endBeginLabel];
    [endBeginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
        make.bottom.mas_equalTo(topBeginLabel.mas_bottom);
        make.left.mas_equalTo(topMidLabel.mas_right).with.offset(2);
    }];
    
    CGFloat hight = (attendanceBgImg.size.height*kScreenWidth)/attendanceBgImg.size.width;
    hight = floor(hight);
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_contentView.mas_top);
        make.left.and.right.mas_equalTo(contentView);
//        make.height.mas_equalTo(75*kScale);
        make.height.mas_equalTo(hight);
    }];
    //创建 月份选择view
    UIView *monthSelectedView = [[UIView alloc] init];
    [_contentView addSubview:monthSelectedView];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftMonthBtn = leftBtn;
    [leftBtn setImage:[UIImage imageNamed:@"attendance_leftNormal"] forState:UIControlStateNormal];
    [monthSelectedView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.and.bottom.mas_equalTo(monthSelectedView);
        make.width.mas_equalTo(40);
    }];
    [leftBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self requestLastMonth];
    }];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightMonthBtn = rightBtn;
    [rightBtn setImage:[UIImage imageNamed:@"attendance_rightNormal"] forState:UIControlStateNormal];
    [monthSelectedView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.top.and.bottom.mas_equalTo(monthSelectedView);
        make.width.mas_equalTo(40);
    }];
    [rightBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self requestNextMonth];
    }];
    
    UILabel *monthLabel = [[UILabel alloc] init];
    monthLabel.textColor = KColorSubTitleTxt;
    monthLabel.font = kFontLarge;
    monthLabel.text = @"";
    _showMonthLabel = monthLabel;
    [monthSelectedView addSubview:monthLabel];
    [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(monthSelectedView);
        make.centerX.mas_equalTo(monthSelectedView);
    }];
    [monthSelectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(_contentView);
        make.top.mas_equalTo(topView.mas_bottom);
        make.height.mas_equalTo(34);
    }];
    //创建 出勤显示view
    TXCalendarView *calendar = [[TXCalendarManager shareInstance] getCalendarView];
    _calendarView = calendar;
    [contentView addSubview:calendar];
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(monthSelectedView.mas_bottom);
        make.left.and.right.mas_equalTo(contentView);
        make.height.mas_greaterThanOrEqualTo(@(100));
    }];
//    [calendar hiddenWeeks];
    //创建请假view
    UIButton *askOffBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _askOffBtn = askOffBtn;
//    askOffBtn.tintColor = kColorWhite;
//    askOffBtn.titleLabel.font = kFontSuper;
//    [askOffBtn setTitle:@"trtt" forState:UIControlStateNormal];
//    askOffBtn.layer.cornerRadius = 4.0f/2;
//    askOffBtn.layer.masksToBounds = YES;
//    [askOffBtn setBackgroundImage:[self createImageWithColor:KColorAppMain] forState:UIControlStateNormal];
    [askOffBtn setBackgroundImage:[self createImageWithColor:KColorAppMainP] forState:UIControlStateHighlighted|UIControlStateSelected];
    [contentView addSubview:askOffBtn];
    [askOffBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(contentView.mas_right).with.offset(-20);
        make.left.mas_equalTo(contentView.mas_left).with.offset(20);
//        make.bottom.mas_equalTo(contentView.mas_bottom).with.offset(-30);
        make.height.mas_equalTo(40);
        make.top.greaterThanOrEqualTo(calendar.mas_bottom).with.offset(30);
        
    }];
//    [askOffBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
//        @strongify(self);
////        [self showLeaveViewController];
//    }];
    
    CGFloat minHight = self.view.frame.size.height-self.customNavigationView.maxY;
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        if(!ISSMALLIPHONE)
        {
            make.height.greaterThanOrEqualTo(@(minHight));
        }
    }];

}

-(void)updateMonthBtns
{
    NSDate *currentDate = [NSDate date];
    if(_showDate.year == currentDate.year && _showDate.month == currentDate.month)
    {
        [_rightMonthBtn setEnabled:NO];
        [_rightMonthBtn setImage:[UIImage imageNamed:@"attendance_rightDisable"] forState:UIControlStateNormal];
    }
    else
    {
        [_rightMonthBtn setImage:[UIImage imageNamed:@"attendance_rightNormal"] forState:UIControlStateNormal];
        [_rightMonthBtn setEnabled:YES];
    }
}

-(void)updateViews
{
//    [_calendarView setHidden:NO];
    [_calendarView refreshViews:_attendanceInfos];
    
    [_calendarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_calendarView.getTotalHight);
    }];
    
    [_askOffBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(_calendarView.mas_bottom).with.offset(30);
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_askOffBtn.mas_bottom).with.offset(30);
    }];
    _showMonthLabel.text = [NSString stringWithFormat:@"%@年%@月的学能作业", @(_showDate.year), @(_showDate.month)];
    _presentDaysLabel.text = [NSString stringWithFormat:@"%@", @(_presentDays)];
//    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
//    }];
}


- (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)updateDefaultDatas
{
    [self createAttendanceInfo:nil absenceDates:nil leaveDates:nil holidays:nil];

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(sender.tag == TopBarButtonRight)
    {
        GuardianDetailViewController *vc = [[GuardianDetailViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UI视图创建
////创建导航视图
//- (void)createCustomNavBar
//{
//    [super createCustomNavBar];
////    self.btnLeft.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, 60, kNavigationHeight);
//    [self.btnRight setTitle:@"刷卡记录" forState:UIControlStateNormal];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-- private

-(void)requestCurrentMonth
{
    [self requestByMonth:[self dateToLongLong:_showDate] monthChanged:0];
}
-(void)requestNextMonth
{
    [self requestByMonth:[self dateToLongLong:[_showDate dateByAddingMonths:1]] monthChanged:1];
}

-(void)requestLastMonth
{
    [self requestByMonth:[self dateToLongLong:[_showDate dateBySubtractingMonths:1]] monthChanged:-1];
}

-(int64_t)dateToLongLong:(NSDate *)date
{
    return  [date timeIntervalSince1970]*1000;
}


 -(void)requestByMonth:(int64_t)month monthChanged:(NSInteger)changedMonth
{
    @weakify(self);
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    [[TXChatClient sharedInstance].checkInManager fetchChildAttendance:month onCompleted:^(NSError *error, NSArray *presentDates, NSArray *absenceDates, NSArray *leaveDates, NSArray *restDates) {
        @strongify(self);
        [TXProgressHUD hideHUDForView:self.view animated:YES];
        if(error)
        {
            [self showFailedHudWithError:error];
        }
        else
        {
            TXAsyncRunInMain(^{
                if(changedMonth > 0)
                {
                    _showDate = [_showDate dateByAddingMonths:changedMonth];
                }
                else if(changedMonth < 0)
                {
                    _showDate = [_showDate dateBySubtractingMonths:-changedMonth];
                }
                [self createAttendanceInfo:presentDates absenceDates:absenceDates leaveDates:leaveDates holidays:restDates];
            });
        }
    }];
}


/**
 *  生成周信息数据
 *
 *  @param presentDates 出席天
 *  @param absenceDates 缺席天
 *  @param leaveDates   请假天
 */
-(void)createAttendanceInfo:(NSArray *)presentDates absenceDates:(NSArray *)absenceDates leaveDates:(NSArray *)leaveDates holidays:(NSArray *)holidays
{
    NSInteger maxDayInMonth = [BabyAttendanceViewController getDaysInMonth:_showDate.month year:_showDate.year];
    NSMutableArray *weeksInfo = [self getWeeksInfo];
    TXAsyncRunInMain(^{
        _presentDays = [presentDates count];
    });
    for(NSInteger i = 1; i <= maxDayInMonth; i++)
    {
        NSDate *currentDate = [NSDate dateWithYear:_showDate.year month:_showDate.month day:i hour:1 minute:0 second:0 ];
        TXCalendarDayModel *currentDay = [[TXCalendarDayModel alloc] init];
        currentDay.day = i;
        currentDay.weekDay = currentDate.weekday;
        currentDay.attendanceDayType = [self getDayType:currentDate presentDates:presentDates absenceDates:absenceDates leaveDates:leaveDates holidays:holidays];
        currentDay.isToday = [self isToday:currentDate];
        [self insertDayToWeeks:currentDay weekIndex:currentDate.weekOfMonth weeksInfo:weeksInfo];
    }
    @synchronized(_attendanceInfos)
    {
        _attendanceInfos = weeksInfo;
    }
    TXAsyncRunInMain(^{
        [self updateMonthBtns];
        [self updateViews];
    });
}


-(NSMutableArray *)getWeeksInfo
{
    NSMutableArray *weeksInfo = [NSMutableArray arrayWithCapacity:1];
    for(NSInteger i = 1; i <= 6; i++)
    {
        TXCalendarWeekModel *weekModel = [[TXCalendarWeekModel alloc] initWithWeekIndex:i];
        [weeksInfo addObject:weekModel];
    }
    return weeksInfo;
}

-(BOOL)isToday:(NSDate *)date
{
    NSDate *today = [NSDate date];
    if(today.year == date.year
       && today.month == date.month
       && today.day == date.day)
    {
        return YES;
    }
    return NO;
}

/**
 *  把当天信息插入到周中
 *
 *  @param dayInfo   当天信息
 *  @param weekIndex 第几周
 *  @param weeksInfo 周信息
 */
-(void)insertDayToWeeks:(TXCalendarDayModel *)dayInfo weekIndex:(NSInteger)weekIndex weeksInfo:(NSMutableArray *)weeksInfo
{
    if(!dayInfo || !weeksInfo)
    {
        return ;
    }
    TXCalendarWeekModel *currentWeekModel = nil;
    for(TXCalendarWeekModel *weekModel in weeksInfo)
    {
        if(weekModel.getWeekIndex == weekIndex)
        {
            currentWeekModel = weekModel;
            break;
        }
    }
    [currentWeekModel addDays:dayInfo];
}

/**
 *  返回 当天的状态
 *
 *  @param currentDate  当前日期
 *  @param presentDates 出席天
 *  @param absenceDates 缺席天
 *  @param leaveDates   请假天
 *
 *  @return 当天状态
 */
-(TXATTENDANCEDAYTYPE)getDayType:(NSDate *)currentDate presentDates:(NSArray *)presentDates absenceDates:(NSArray *)absenceDates leaveDates:(NSArray *)leaveDates holidays:(NSArray *)holidays
{
    TXATTENDANCEDAYTYPE dayType =  TXATTENDANCEDAYTYPE_NORMAL;
    NSInteger day = currentDate.day;
    if([presentDates containsObject:@(day)])
    {
        dayType =  TXATTENDANCEDAYTYPE_ATTENDANCE;
    }
    else if([holidays containsObject:@(day)])
    {
        dayType =  TXATTENDANCEDAYTYPE_HOLIDAY;
    }
    else if([absenceDates containsObject:@(day)])
    {
        dayType =  TXATTENDANCEDAYTYPE_ABSENT;
    }
    else if([leaveDates containsObject:@(day)])
    {
        dayType =  TXATTENDANCEDAYTYPE_LEAVE;
    }
    
    return dayType;
}






/**
 *  当月最大天数
 *
 *  @param month 月
 *  @param year  年
 *
 *  @return 当月最大天数
 */
+(NSInteger)getDaysInMonth:(NSInteger)month year:(NSInteger)year
{
    //    return 0;
    switch(month){
        case 2:{
            NSInteger nYear = year;
            if( (nYear%4 == 0) && (nYear%400) != 0 ){
                return 29;
            }else{
                return 28;
            }
            break;
        }
            //big moths
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            return 31;
            break;
            //small moths
        case 4:
        case 6:
        case 9:
        case 11:
            return 30;
            break;
        default:
            return -1;
    }
    return -1;
}


//-(void)showLeaveViewController
//{
//    LeaveViewController *leaveVC = [[LeaveViewController alloc] init];
//    [self.navigationController pushViewController:leaveVC animated:YES];
//}


@end
