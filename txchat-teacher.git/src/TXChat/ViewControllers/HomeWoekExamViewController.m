//
//  HomeWoekExamViewController.m
//  TXChatTeacher
//
//  Created by gaoju on 16/4/12.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWoekExamViewController.h"
#import "HomeWorkRecordCell.h"
#import "HomeWorkTestViewController.h"

#import "UIButton+EMWebCache.h"
#import "UIImage+Rotate.h"
#import <extobjc.h>
#import <NSDate+DateTools.h>
#import "GuardianDetailViewController.h"
#import <MJRefresh.h>
#import "BabyAttendanceViewController.h"

#import "NSDate+TuXing.h"
#import "DropdownView.h"
#import <UIImageView+TXSDImage.h>
#import "HomeworkResultController.h"
#import "HomeworkExplainController.h"

#define kSelectArrWithIdx _currentIndex == 0 ? _recordList : _attendanceList

@interface HomeWoekExamViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>{
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
    
    
    
    
    DropdownView *_dropDownView;
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    UIImageView *_arrowImgView;
    NSMutableArray *_finishedArray;// 完成
    NSMutableArray *_unfinishedArray;//未完成
    NSDate *_currentDate;//当前显示日期
    BOOL _isHoliday;
    TXUser *user ;
    
    
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
@property (nonatomic,weak) UISegmentedControl *segmentedControl;
@property (nonatomic,weak) UIScrollView *contentScrollView;
@property (nonatomic,weak) UITableView *attendanceTableView;
@property (nonatomic,weak) UITableView *recordTableView;
@property (nonatomic,strong) NSMutableArray *hotestQuestions;
//@property (nonatomic,strong) NSMutableArray *rankList;
@property (nonatomic,weak) UIActivityIndicatorView *hotestLoadingIndicatorView;
@property (nonatomic,weak) UIActivityIndicatorView *newestLoadingIndicatorView;

@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, assign) int64_t departmentId;

@property (nonatomic, strong) NSArray *titlesArr;
@property (nonatomic,strong) NSMutableArray *classNames;
@property (nonatomic,strong) NSMutableArray *departmentIds;

@property (nonatomic, strong) DropdownView *dropdownView;


@property (nonatomic,strong) NSMutableArray *attendanceList;
@property (nonatomic,strong) NSMutableArray *recordList;
@end

@implementation HomeWoekExamViewController

//-(id)init
//{
//    self = [super init];
//    if(self)
//    {
//        _rankList = [NSMutableArray arrayWithCapacity:5];
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavBar];
    [self createSegmentBtn];
    [self setupRankView];
    [self setupRefreshView];
    [self setupRefreshHomeWorkView];
    [self addEmptyDataImage:NO showMessage:@"该班级暂无学生"];
//    [_recordTableView.header beginRefreshing];
//    [_attendanceTableView.header beginRefreshing];
	
    // 设置默认选中的index
    [self setCurrentSelectedIndex:0];
    // [self UserSelecteder];
    user= [[TXChatClient sharedInstance] getCurrentUser:nil];
    
    // TXUser *Puser=[[TXChatClient sharedInstance] getCurrentUser:nil];
    self.titlesArr = [NSArray array];
    self.departmentIds=[NSMutableArray array];
    self.classNames=[NSMutableArray array];
    //    self.titlesArr=@[Puser.className,@"4785"];
    self.titlesArr = [[TXChatClient sharedInstance] getAllDepartments:nil];
	if(self.titlesArr != NULL){
		[_recordTableView.header beginRefreshing];
		[_attendanceTableView.header beginRefreshing];
	}
    for (TXDepartment *class in self.titlesArr) {
        if (class.departmentType==TXPBDepartmentTypeClazz) {
            [self.classNames addObject:class.name];
            //NSLog(@"------------%lld",class.departmentId);
            [self.departmentIds addObject:[NSString stringWithFormat:@"%lld",class.departmentId]];
            // NSLog(@"------------%@",self.departmentIds);
        }
    }
    if (self.classNames!=nil&&[self.classNames count]>0) {
        self.titleStr = _classNames[0];
        if (_classNames.count == 1) {
            //只有一个组不显示筛选框
            self.titleStr = _classNames[0];
            self.titleLb.text = self.titleStr;
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
    self.titleLb.font = kFontMiddle;
    //         self.titleLb.text = _titlesArr[_selectedIndex];
    
    
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [self.customNavigationView addSubview:_arrowImgView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    DropdownView *dropdownView = [[DropdownView alloc] init];
    self.dropdownView = dropdownView;
    
    @weakify(self);
    [_dropdownView showInView:self.view andListArr:self.classNames andDropdownBlock:^(int index) {
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
            _selectedIndex = index;
            self.titleStr = _classNames[_selectedIndex];
            self.titleLb.text = self.titleStr;
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            TXAsyncRun(^{
                
                TXAsyncRunInMain(^{
                    // [self fatchHomeWorksRereshing];
                    //[self fatchNewHomeWorksRereshing];
                    [_recordTableView.header beginRefreshing];
                    [_attendanceTableView.header beginRefreshing];
                    
                    [self.recordTableView reloadData];
                    [self.attendanceTableView reloadData];
                    [TXProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
        }
    }];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.dropdownView = nil;
}
- (void)createCustomNavBar{
    
    [super createCustomNavBar];
    
    [self.btnRight setTitle:@"权威解释" forState:UIControlStateNormal];
    [self.btnRight setTitleColor:ColorNavigationTitle forState:UIControlStateNormal];
}
#pragma mark - DROPDOWN VIEW
- (void)showDropDownView
{
    [_dropdownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
}

- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        HomeworkExplainController *explainVC = [[HomeworkExplainController alloc] init];
        [self.navigationController pushViewController:explainVC animated:YES];
    }
}

-(void)createSegmentBtn{
    
    UILabel *briefLabel=[[UILabel alloc]initClearColorWithFrame:CGRectMake(15, self.customNavigationView.maxY-10, self.customNavigationView.width_-30, 100)];
    briefLabel.numberOfLines=0;
    briefLabel.font=kFontMiddle;
    [briefLabel setTextColor:KColorNewSubTitleTxt];
    [self.view addSubview:briefLabel];
    briefLabel.text=@"学能总成绩（0-60分）为学生在作业和学能测试中的综合表现，反应学生的学习能力水平，系统会根据学生的学能成绩来定制学生的作业。";
    
    //添加切换Segment
    UISegmentedControl *segmentedConrol = [[UISegmentedControl alloc] initWithItems:@[@"学能总成绩排名",@"学能作业排名"]];
    self.segmentedControl = segmentedConrol;
    self.segmentedControl.frame=CGRectMake(0, briefLabel.maxY, self.view.width_, 44);
    self.segmentedControl.tintColor=ColorNavigationTitle;
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
    if (_currentIndex == 0 ) {
        [_recordTableView.header beginRefreshing];
    }else if (_currentIndex == 1 ) {
        [_attendanceTableView.header beginRefreshing];
    }
}
#pragma mark ---------创建作业排名和作业考勤页面 ---------

- (void)setupRankView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.segmentedControl.maxY, self.view.width_, self.view.height_ - self.segmentedControl.maxY)];
    self.contentScrollView = scrollView;
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.alwaysBounceVertical=NO;
    self.contentScrollView.alwaysBounceHorizontal=NO;
    self.contentScrollView.scrollEnabled=NO;
    [self.view addSubview:self.contentScrollView];
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    //添加 学能商数排名
    UITableView *recordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _contentScrollView.width_, _contentScrollView.height_) style:UITableViewStylePlain];
    self.recordTableView = recordTableView;
    self.recordTableView.backgroundColor = [UIColor clearColor];
    self.recordTableView.delegate = self;
    self.recordTableView.dataSource = self;
    self.recordTableView.tag=100;
    self.recordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentScrollView addSubview:self.recordTableView];
    
    //添加学能作业排名(本月)
    UITableView *attendanceTableView = [[UITableView alloc] initWithFrame:CGRectMake(_contentScrollView.width_, 0, _contentScrollView.width_, _contentScrollView.height_) style:UITableViewStylePlain];
    self.attendanceTableView = attendanceTableView;
    self.attendanceTableView.backgroundColor = [UIColor clearColor];
    self.attendanceTableView.delegate = self;
    self.attendanceTableView.dataSource = self;
    self.attendanceTableView.tag=101;
    self.attendanceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentScrollView addSubview:self.attendanceTableView];
    //设置contentSize
    [self.contentScrollView setContentSize:CGSizeMake(_contentScrollView.width_ * 2, _contentScrollView.height_)];
    
    [self addEmptyDataImage:NO showMessage:@"没有学能作业信息"];
    // [self updateEmptyDataImageStatus:[UIImage imageNamed:@"noedit_default_icon"]];
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [kSelectArrWithIdx count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HomeWorkRecordCell";
    UITableViewCell *cell = nil;
    HomeWorkRecordCell *recordCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!recordCell ) {
        recordCell = [[[NSBundle mainBundle] loadNibNamed:@"HomeWorkRecordCell" owner:self options:nil] objectAtIndex:0];
    }
    recordCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    //notifyCell.selectionStyle=UITableViewCellSelectionStyleNone;
    recordCell.backgroundColor = kColorWhite;
    if(indexPath.row >= [kSelectArrWithIdx count])
    {
        return recordCell;
    }
    
    XCSDHomeWorkRank *homeWorkRank = [kSelectArrWithIdx objectAtIndex:indexPath.row];
    
    [recordCell.userNameLabel setText:homeWorkRank.name];
    NSString *  scoreStr=[NSString stringWithFormat:@"%d",homeWorkRank.score];
    [recordCell.scoreLabel setText:[scoreStr stringByAppendingString:[NSString stringWithFormat:@"分"]]];
    //[recordCell.stateImage sd_setImageWithURL:[NSURL URLWithString:notice.avatar]];
    
    [recordCell.stateImage TX_setImageWithURL:[NSURL URLWithString:[ homeWorkRank.avatar getFormatPhotoUrl:40.0f hight:40.0f]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    cell = recordCell;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //消除cell选择痕迹
    //[self performSelector:@selector(deselect) withObject:nil afterDelay:0.5f];
    HomeworkResultController *vc = [[HomeworkResultController alloc] init];
    
    if (tableView.tag==100) {
        [self.recordTableView deselectRowAtIndexPath:[self.recordTableView indexPathForSelectedRow] animated:YES];
        XCSDHomeWorkRank *homeWorkRank = [_recordList objectAtIndex:indexPath.row];
        vc.childName = homeWorkRank.name;
        vc.childId = homeWorkRank.userId;
        
    }else if (tableView.tag==101){
        [self.attendanceTableView deselectRowAtIndexPath:[self.attendanceTableView indexPathForSelectedRow] animated:YES];
        
        XCSDHomeWorkRank *homeWorkRank = [_attendanceList objectAtIndex:indexPath.row];
        vc.childId = homeWorkRank.userId;
        vc.childName = homeWorkRank.name;
//        record.childId=homeWorkRank.userId;
//        record.ChildName=homeWorkRank.name;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

//点击后，过段时间cell自动取消选中
- (void)deselect
{
    [self.recordTableView deselectRowAtIndexPath:[self.recordTableView indexPathForSelectedRow] animated:YES];
    [self.attendanceTableView deselectRowAtIndexPath:[self.attendanceTableView indexPathForSelectedRow] animated:YES];
}

//刷新商数排名列表
- (void)setupRefreshView
{
    __weak typeof(self)tmpObject = self;
    _recordTableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _recordTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _recordTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}
#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fatchNewHomeWorksRereshing];
    });
}

-(void)fatchNewHomeWorksRereshing{
    //    _flags.hotTopRefresh = YES;
    //    TXUser *Puser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    //    user= [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryUserByUserId:Puser.userId error:nil];
    if (self.departmentIds!=nil&&[self.departmentIds count]>0) {
        int64_t classId=[self.departmentIds[_selectedIndex] integerValue];
        [[TXChatClient sharedInstance] AbilityHomeWorksClassId:classId onCompleted:^(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged) {
            if(error)
            {
                DDLogDebug(@"error:%@", error);
                [self showFailedHudWithError:error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_recordTableView.header endRefreshing];
                });
            }else{
                
                [self updateEmptyDataImageStatus:rankList.count > 0 ? NO : YES];
                
                [self updateRankListAfterHeaderRefresh:rankList];
                [_recordTableView.footer setHidden:!hasMore];
            }
        }];
    }
}
- (void)updateRankListAfterHeaderRefresh:(NSArray *)rankList{
    
    _recordList = rankList.copy;
    
    [_recordTableView.header endRefreshing];
    [self updateViewConstraints];
    [_recordTableView reloadData];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.recordTableView scrollsToTop];
    });
    
}
- (void)footerRereshing
{
    
    [_recordTableView.footer endRefreshing];
    // XCSDHomeWorkRank *question = [_rankList lastObject];
    //[self fetchQuestionListDataWithMaxId:question.id];
}

//刷新作业排名列表
- (void)setupRefreshHomeWorkView{
    __weak typeof(self)tmpObject = self;
    _attendanceTableView.header= [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject HomeWorkheaderRereshing];
    }];
    _attendanceTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject HomeWorkfooterRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _attendanceTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
}
- (void)HomeWorkheaderRereshing
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fatchHomeWorksRereshing];
    });
}
-(void)fatchHomeWorksRereshing{
    //    TXUser *Puser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    //    user= [[TXApplicationManager sharedInstance].currentUserDbManager.userDao queryUserByUserId:Puser.userId error:nil];
    if (self.departmentIds!=nil&&[self.departmentIds count]>0) {
        int64_t classId=[self.departmentIds[_selectedIndex] integerValue];
        [[TXChatClient sharedInstance] RankHomeWorksClassId:classId onCompleted:^(NSError *error, NSArray *rankList, BOOL hasMore, BOOL lastOneHasChanged) {
            if(error)
            {
                DDLogDebug(@"error:%@", error);
                [self showFailedHudWithError:error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_attendanceTableView.header endRefreshing];
                });
            }
            else
            {
                [self updateEmptyDataImageStatus:rankList.count > 0 ? NO : YES];
                [self updateHomeWorkListAfterHeaderRefresh:rankList];
                [_attendanceTableView.footer setHidden:!hasMore];
            }
        }];
    }
}
- (void)updateHomeWorkListAfterHeaderRefresh:(NSArray *)rankList{
    
    _attendanceList = rankList.copy;
    
    [_attendanceTableView.header endRefreshing];
    [self updateViewConstraints];
    [_attendanceTableView reloadData];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.attendanceTableView scrollsToTop];
    });
    
    
}
- (void)HomeWorkfooterRereshing
{
    
    [_attendanceTableView.footer endRefreshing];
    //_flags.newTopRefresh = NO;
    //XCSDHomeWorkRank *question = [_rankList lastObject];
    //[self fetchQuestionListDataWithMaxId:question.id];
    
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
        
    }
}


- (NSMutableArray *)attendanceList{
    
    if (_attendanceList == nil) {
        _attendanceList = [NSMutableArray array];
    }
    return _attendanceList;
}

- (NSMutableArray *)recordList{
    
    if (_recordList == nil) {
        _recordList  = [NSMutableArray array];
    }
    return _recordList;
}

@end
