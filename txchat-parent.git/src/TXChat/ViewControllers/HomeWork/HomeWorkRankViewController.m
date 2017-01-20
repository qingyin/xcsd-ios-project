//
//  HomeWorkRankViewController.m
//  TXChatParent
//
//  Created by gaoju on 16/3/18.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkRankViewController.h"
#import "HomeWorkRecordCell.h"
#import "HomeWorkListViewController.h"
#import "UIButton+EMWebCache.h"
#import "UIImage+Rotate.h"
#import <extobjc.h>
#import <NSDate+DateTools.h>
#import "GuardianDetailViewController.h"
#import <MJRefresh.h>
#import "BabyAttendanceViewController.h"

#import "XCSDAttendanceDayView.h"
#import "XCSDCalendarView.h"
#import "XCSDCalendarWeekModel.h"
#import "XCSDCalendarDayModel.h"
#import "XCSDCalendarManager.h"


#import <UIImageView+Utils.h>
#import "AttendanceUICollectionViewCell.h"
#import "UIImageView+EMWebCache.h"
#import <NSString+Photo.h>
#import "NSDate+TuXing.h"
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>

@interface HomeWorkRankViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{  UIScrollView *_scrollView;
    UIView *_contentView;//滚动条内的view;
    NSMutableArray *_attendanceInfos;
    NSDate *_showDate;
    XCSDCalendarView *_calendarView;
    UILabel *_showMonthLabel;
    UILabel *_finishedDaysLabel;
    NSInteger _finishedDays;
    UIButton *_leftMonthBtn;
    UIButton *_rightMonthBtn;
    UIButton *_askOffBtn;
    TXUser *user ;
    
    DropdownView *_dropDownView;
    UIButton *_selectedBtn;
    UIImageView *_arrowImgView;
    NSMutableArray *_finishedArray;// 完成
    NSMutableArray *_unfinishedArray;//未完成
    NSDate *_currentDate;//当前显示日期
    BOOL _isHoliday;

    NSInteger _currentIndex;
    int _hotQuestionPage;
    int _newQuestionPage;
    struct {
        unsigned int hotHasFetched:1;
        unsigned int newHasFetched:1;
        unsigned int hotTopRefresh:1;
        unsigned int newTopRefresh:1;
    }__block _flags ;
}
@property (nonatomic,strong) UISegmentedControl *segmentedControl;
@property (nonatomic,strong) UIScrollView *contentScrollView;
@property (nonatomic,strong) UIView *attendanceView;
@property (nonatomic,strong) UITableView *recordTableView;
@property (nonatomic,strong) NSMutableArray *hotestQuestions;
@property (nonatomic,strong) NSMutableArray *rankList;
@property (nonatomic,strong) UIActivityIndicatorView *hotestLoadingIndicatorView;
@property (nonatomic,strong) UIActivityIndicatorView *newestLoadingIndicatorView;

@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, assign) int64_t departmentId;
@end

@implementation HomeWorkRankViewController
-(id)init
{
    self = [super init];
    if(self)
    {
        _rankList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavBar];
    [self createSegmentBtn];
    [self setupRankView];
    [self setupRefreshView];
    [_recordTableView.header beginRefreshing];
    // 设置默认选中的index
    [self setCurrentSelectedIndex:0];
  //  [self UserSelecteder];
    user= [[TXChatClient sharedInstance] getCurrentUser:nil];
    [self addEmptyDataImage:[UIImage imageNamed:@"noedit_default_icon"] showMessage:@"没有学能作业信息"];
    [self updateEmptyDataImageStatus:[UIImage imageNamed:@"noedit_default_icon"]];
    
}


- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)createSegmentBtn{
    //添加切换Segment
    self.segmentedControl=[[UISegmentedControl alloc] initWithItems:@[@"学能作业排名",@"学能作业考勤"]];
    self.segmentedControl.frame=CGRectMake(0, self.customNavigationView.maxY, self.view.width_, 44);
    self.segmentedControl.tintColor=RGBCOLOR(70, 190, 240);
    [self.segmentedControl addTarget:self action:@selector(onSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl];
}
- (void)onSegmentControlValueChanged:(UISegmentedControl *)control
{
   [self setCurrentSelectedIndex:control.selectedSegmentIndex];
}
#pragma mark - 数据请求和更新
//设置当前选中的index
- (void)setCurrentSelectedIndex:(NSInteger)index
{
    //设置contentOffset
    [self.contentScrollView setContentOffset:CGPointMake(_contentScrollView.width_ * index, 0) animated:YES];
    //设置segmentControl的选中
    if (index != self.segmentedControl.selectedSegmentIndex) {
        [self.segmentedControl setSelectedSegmentIndex:index];
    }
    //获取数据
    _currentIndex = index;
    if (_currentIndex == 0 && !_flags.newHasFetched) {
       // [_recordTableView.header beginRefreshing];
    }else if (_currentIndex == 1 && !_flags.hotHasFetched) {
       // [_hotestTableView.header beginRefreshing];
    }
}
#pragma mark ---------创建作业排名和作业考勤页面 ---------

- (void)setupRankView
{
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.maxY, self.view.width_, self.view.height_ - self.segmentedControl.maxY)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.alwaysBounceVertical=NO;
    self.contentScrollView.alwaysBounceHorizontal=NO;
    self.contentScrollView.scrollEnabled=NO;
    [self.view addSubview:self.contentScrollView];
    self.automaticallyAdjustsScrollViewInsets=NO;
    //添加 学能作业排名列表
    self.recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _contentScrollView.width_, _contentScrollView.height_) style:UITableViewStylePlain];
    self.recordTableView.backgroundColor = [UIColor clearColor];
    self.recordTableView.delegate = self;
    self.recordTableView.dataSource = self;
    self.recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentScrollView addSubview:self.recordTableView];
    
    //添加学能考勤
    self.attendanceView = [[UIView alloc] initWithFrame:CGRectMake(_contentScrollView.width_, 0, _contentScrollView.width_, _contentScrollView.height_)];
    self.attendanceView.backgroundColor = [UIColor clearColor];
    [self.contentScrollView addSubview:self.attendanceView];
    //设置contentSize
    [self.contentScrollView setContentSize:CGSizeMake(_contentScrollView.width_ * 2, _contentScrollView.height_)];
    
    //添加考勤月历UI
    [self setupViews];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rankList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HomeWorkRecordCell";
    UITableViewCell *cell = nil;
    HomeWorkRecordCell *notifyCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!notifyCell ) {
        notifyCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeWorkRecordCell" owner:self options:nil] objectAtIndex:0];
    }
    notifyCell.selectionStyle=UITableViewCellSelectionStyleNone;
    notifyCell.backgroundColor = kColorWhite;
    if(indexPath.row >= [_rankList count])
    {
        return notifyCell;
    }
    
        XCSDHomeWorkRank *homeWorkRank = [_rankList objectAtIndex:indexPath.row];
        
        [notifyCell.userNameLabel setText:homeWorkRank.name];
       NSString *  scoreStr=[NSString stringWithFormat:@"%d",homeWorkRank.score];
        [notifyCell.scoreLabel setText:[scoreStr stringByAppendingString:[NSString stringWithFormat:@"分"]]];
        //[notifyCell.stateImage sd_setImageWithURL:[NSURL URLWithString:notice.avatar]];
    
      [notifyCell.stateImage TX_setImageWithURL:[NSURL URLWithString:[ homeWorkRank.avatar getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    cell = notifyCell;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

//集成刷新控件
- (void)setupRefreshView
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    MJTXRefreshGifHeader *gifHeader = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _recordTableView.header = gifHeader;
    _recordTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _recordTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
}
#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing
{ if (_currentIndex == 0) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fatchNewHomeWorksRereshing];
      });
   }
}

-(void)fatchNewHomeWorksRereshing{
    _flags.hotTopRefresh = YES;
    TXUser *Puser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    user= [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryUserByUserId:Puser.userId error:nil];
    [[TXChatClient sharedInstance] RankHomeWorksChildUserId:user.userId onCompleted:^(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged)  {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_recordTableView.header endRefreshing];
            });
            [self updateEmptyDataImageStatus:[_rankList count] > 0?NO:YES];
        }
        else
        {
            [self updateRankListAfterHeaderRefresh:rankList];
             [self updateEmptyDataImageStatus:[_rankList count] > 0?NO:YES];
             [_recordTableView.footer setHidden:!hasMore];
        }
        }];
}
- (void)updateRankListAfterHeaderRefresh:(NSArray *)rankList{
    @synchronized (_rankList){
        [_rankList removeAllObjects];
        if (rankList!=nil &&[rankList count]>0) {
            _rankList=[NSMutableArray arrayWithArray:rankList];
        }
    }
    [_recordTableView.header endRefreshing];
    [self updateViewConstraints];
    [_recordTableView reloadData];
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recordTableView scrollsToTop];
    });

}

- (void)footerRereshing
{
    if (_currentIndex == 1) {
        [_recordTableView.footer endRefreshing];
       // XCSDHomeWorkRank *question = [_rankList lastObject];
        //[self fetchQuestionListDataWithMaxId:question.id];
    }else{
        [_recordTableView.footer endRefreshing];
        //_flags.newTopRefresh = NO;
        //XCSDHomeWorkRank *question = [_rankList lastObject];
        //[self fetchQuestionListDataWithMaxId:question.id];
    }
}


#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _contentScrollView) {
        CGRect visibleBounds = scrollView.bounds;
        NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
        if (index < 0) index = 0;
        if (index > 1) index = 1;
        //设置当前滑动到第几页
        [self setCurrentSelectedIndex:index];
    }
}


#pragma mark －－－－－－－学能考勤－－－－－－－－

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _attendanceInfos = [NSMutableArray arrayWithCapacity:1];
        _showDate = [NSDate date];
        _finishedDays = 0;
        _finishedArray = [NSMutableArray arrayWithCapacity:1];
       _unfinishedArray = [NSMutableArray arrayWithCapacity:1];
        _currentDate = [NSDate date];

    }
    return self;
}
-(void)dealloc
{
    [_calendarView removeFromSuperview];
    _calendarView = nil;
}
#pragma mark -------- 考勤月历---------

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
    [_attendanceView addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_attendanceView);
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
    
    //创建 月份选择view
    UIView *monthSelectedView = [[UIView alloc] init];
    [_contentView addSubview:monthSelectedView];
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftMonthBtn = leftBtn;
    [leftBtn setImage:[UIImage imageNamed:@"attendance_leftNormal"] forState:UIControlStateNormal];
    [leftBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        @strongify(self);
        [self requestLastMonth];
    }];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightMonthBtn = rightBtn;
    [rightBtn setImage:[UIImage imageNamed:@"attendance_rightNormal"] forState:UIControlStateNormal];
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
    XCSDCalendarView *calendar = [[XCSDCalendarManager shareInstance] getCalendarView];
    _calendarView = calendar;
    [contentView addSubview:calendar];
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(monthSelectedView.mas_bottom);
        make.left.and.right.mas_equalTo(contentView);
        make.height.mas_greaterThanOrEqualTo(@(100));
    }];
    //    [calendar hiddenWeeks];
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
  
    
//    [_calendarView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(_calendarView.getTotalHight);
//    }];
//    
//    [_askOffBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.greaterThanOrEqualTo(_calendarView.mas_bottom).with.offset(30);
//    }];
    
//    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(_askOffBtn.mas_bottom).with.offset(30);
//    }];
      [_calendarView refreshViews:_attendanceInfos];
    _showMonthLabel.text = [NSString stringWithFormat:@"%@年%@月的学能作业", @(_showDate.year), @(_showDate.month)];
    _finishedDaysLabel.text = [NSString stringWithFormat:@"%@", @(_finishedDays)];
  //  [self.view layoutIfNeeded];
    
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
    [self createAttendanceInfo:nil absenceDates:nil ];
    
}

#pragma mark-- private

-(void)requestCurrentMonth
{
    [self requestByChildUserId:[self dateToLongLong:_showDate] monthChanged:0];
}
-(void)requestNextMonth
{
    [self requestByChildUserId:[self dateToLongLong:[_showDate dateByAddingMonths:1]] monthChanged:1];
}

-(void)requestLastMonth
{
    [self requestByChildUserId:[self dateToLongLong:[_showDate dateBySubtractingMonths:1]] monthChanged:-1];
}

-(int64_t)dateToLongLong:(NSDate *)date
{
    return  [date timeIntervalSince1970]*1000;
}


-(void)requestByChildUserId:(int64_t)childUserId monthChanged:(NSInteger)changedMonth
{
    @weakify(self);
    // [TXProgressHUD showHUDAddedTo:self.view withMessage:@""]; finishedDates, unfinishedDates  2293604
    TXUser *Puser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    TXPBChild *pbChild = Puser.childUserIdAndRelationsList[0];

    [[TXChatClient sharedInstance].xcsdHomeWorkManager fetchChildAttendance:pbChild.userId onCompleted:^(NSError *error, NSArray *finishedDates, NSArray *unfinishedDates) {
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
                [self createAttendanceInfo:finishedDates absenceDates:unfinishedDates];
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
-(void)createAttendanceInfo:(NSArray *)finishedDates absenceDates:(NSArray *) unfinishedDates
{
    NSInteger maxDayInMonth = [BabyAttendanceViewController getDaysInMonth:_showDate.month year:_showDate.year];
    NSMutableArray *weeksInfo = [self getWeeksInfo];
    TXAsyncRunInMain(^{
        _finishedDays = [finishedDates count];
    });
    for(NSInteger i = 1; i <= maxDayInMonth; i++)
    {
        NSDate *currentDate = [NSDate dateWithYear:_showDate.year month:_showDate.month day:i hour:1 minute:0 second:0 ];
        XCSDCalendarDayModel *currentDay = [[XCSDCalendarDayModel alloc] init];
        currentDay.day = i;
        currentDay.weekDay = currentDate.weekday;
        currentDay.attendanceDayType = [self getDayType:currentDate presentDates:finishedDates absenceDates:unfinishedDates ];
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
        XCSDCalendarWeekModel *weekModel = [[XCSDCalendarWeekModel alloc] initWithWeekIndex:i];
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
-(void)insertDayToWeeks:(XCSDCalendarDayModel *)dayInfo weekIndex:(NSInteger)weekIndex weeksInfo:(NSMutableArray *)weeksInfo
{
    if(!dayInfo || !weeksInfo)
    {
        return ;
    }
    XCSDCalendarWeekModel *currentWeekModel = nil;
    for(XCSDCalendarWeekModel *weekModel in weeksInfo)
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
 *  @param presentDates 出席天／未完成
 *  @param absenceDates 缺席天／已完成
 *  @param leaveDates   请假天
 *
 *  @return 当天状态
 */
-(XCSDATTENDANCEDAYTYPE)getDayType:(NSDate *)currentDate presentDates:(NSArray *)presentDates absenceDates:(NSArray *)absenceDates
{
    XCSDATTENDANCEDAYTYPE dayType =  XCSDATTENDANCEDAYTYPE_NORMAL;
    NSInteger day = currentDate.day;
    
    if([presentDates containsObject:@(day)])
    {//完成作业日期
        dayType =  XCSDATTENDANCEDAYTYPE_ATTENDANCE;
    }
    else if([absenceDates containsObject:@(day)])
    {//未完成作业日期
        dayType =  XCSDATTENDANCEDAYTYPE_ABSENT;
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



#pragma mark －－－－－－用户选择－－－－－－－－


- (void)createCustomNavBar
{
    [super createCustomNavBar];
    self.titleStr=self.childName;
    //[self selestUser];
}

-(void)selestUser{

    self.groupList = [NSMutableArray arrayWithCapacity:1];
    NSArray *departments = [[TXChatClient sharedInstance] getAllDepartments:nil];
    NSMutableArray *showTitles= [NSMutableArray arrayWithCapacity:1];
    for(TXDepartment *index in departments)
    {
        if(![index.name isEqualToString:@"老师"])
        {
            [self.groupList addObject:index];
            [showTitles addObject:index.name];
        }
    }

    if(self.groupList.count > 0)
    {
        TXDepartment *depart = self.groupList[0];
        self.departmentId = depart.departmentId;
        //只有一个组不显示筛选框
        self.titleStr = depart.name;
        self.titleLb.text = self.titleStr;
        if (_groupList.count == 1) {
            return;
        }
    }
    
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.adjustsImageWhenHighlighted = NO;
    _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
    [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavigationView addSubview:_selectedBtn];
    [self.customNavigationView bringSubviewToFront:self.btnLeft];
    [self.customNavigationView bringSubviewToFront:self.btnRight];
    DropdownView *dropDwon = [[DropdownView alloc] init];
    _dropDownView = dropDwon;
     @weakify(self);
    [dropDwon showInView:self.view andListArr:showTitles andDropdownBlock:^(int index) {
        @strongify(self);
        if(index == -1)
        {
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            return;
        }
        else
        {
            TXDepartment *depart = self.groupList[index];
            NSLog(@"name:%@", depart.name);
            self.titleStr = depart.name;
            self.titleLb.text = self.titleStr;
            self.departmentId = depart.departmentId;
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
        }
        //[self updateDataFromServer:_currentDate];
    }];
    
    _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [self.customNavigationView addSubview:_arrowImgView];
}

- (void)showDropDownView
{
    [_dropDownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
    
}
//-(void)updateDataFromServer:(NSDate *)currentDate
//{
//    @weakify(self);
//    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    [[TXChatClient sharedInstance].checkInManager fetchDepartmentAttendance:self.departmentId date:[_currentDate dateToLongLong] onCompleted:^(NSError *error, NSArray *presentUsers, NSArray *absenceUsers, NSArray *leaveUsers, BOOL isRestDay) {
//        _isHoliday = isRestDay;
//        @strongify(self);
//        [TXProgressHUD hideHUDForView:self.view animated:YES];
//        if(error)
//        {
//            [self showFailedHudWithError:error];
//        }
//        else
//        {
//            @synchronized(_presentArray)
//            {
//                _presentArray = [NSMutableArray arrayWithArray:presentUsers];
//            }
//            @synchronized(_absentArray)
//            {
//                _absentArray = [NSMutableArray arrayWithArray:absenceUsers];
//            }
//                       [self updateViews];
//            [_recordTableView reloadData];
//        }
//    }];
//}


@end
