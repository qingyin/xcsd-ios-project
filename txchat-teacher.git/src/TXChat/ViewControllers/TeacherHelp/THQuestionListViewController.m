//
//  THQuestionListViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THQuestionListViewController.h"
#import "THQuestionListTableViewCell.h"
#import <MJRefresh.h>
#import "THQuestionDetailViewController.h"
#import "THQuestionSelectTagViewController.h"

@interface THQuestionListViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UIScrollViewDelegate>
{
    NSInteger _currentIndex;
    int _hotQuestionPage;
    int _newQuestionPage;
    struct {
        unsigned int hotHasFetched:1;
        unsigned int newHasFetched:1;
        unsigned int hotTopRefresh:1;
        unsigned int newTopRefresh:1;
    } __block _flags;
}
@property (nonatomic,strong) UISegmentedControl *segmentedControl;
@property (nonatomic,strong) UIScrollView *contentScrollView;
@property (nonatomic,strong) UITableView *hotestTableView;
@property (nonatomic,strong) UITableView *newestTableView;
@property (nonatomic,strong) NSMutableArray *hotestQuestions;
@property (nonatomic,strong) NSMutableArray *newestQuestions;
@property (nonatomic,strong) UIActivityIndicatorView *hotestLoadingIndicatorView;
@property (nonatomic,strong) UIActivityIndicatorView *newestLoadingIndicatorView;

@end

@implementation THQuestionListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _hotQuestionPage = 1;
        _newQuestionPage = 1;
        self.hotestQuestions = [NSMutableArray array];
        self.newestQuestions = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRefreshNewestQuestionsNotification:) name:TeacherHelpRefreshNewQuestionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveAddNewAnswerNotification:) name:TeacherHelpQuestionReplysChangedNotification object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    [self setupQuestionListView];
    [self setupRefreshView];
    //设置默认选中的index
    [self setCurrentSelectedIndex:0];
}
#pragma mark - UI视图创建
- (void)createCustomNavBar
{
    [super createCustomNavBar];
    //添加切换Segment
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"最新",@"热门"]];
    self.segmentedControl.frame = CGRectMake(0, 0, 137, 27);
    self.segmentedControl.center = CGPointMake(self.view.centerX, kNavigationHeight / 2 + kStatusBarHeight);
    self.segmentedControl.tintColor = RGBCOLOR(138, 143, 255);
    [self.segmentedControl addTarget:self action:@selector(onSegmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.customNavigationView addSubview:self.segmentedControl];
    //设置提问
    [self.btnRight setTitle:@"提问" forState:UIControlStateNormal];
}
- (void)setupQuestionListView
{
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY - kTabBarHeight)];
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.contentScrollView];
    //添加最新列表
    self.newestTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _contentScrollView.width_, _contentScrollView.height_) style:UITableViewStylePlain];
    self.newestTableView.backgroundColor = [UIColor clearColor];
    self.newestTableView.delegate = self;
    self.newestTableView.dataSource = self;
    self.newestTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentScrollView addSubview:self.newestTableView];
    //添加热门列表
    self.hotestTableView = [[UITableView alloc] initWithFrame:CGRectMake(_contentScrollView.width_, 0, _contentScrollView.width_, _contentScrollView.height_) style:UITableViewStylePlain];
    self.hotestTableView.backgroundColor = [UIColor clearColor];
    self.hotestTableView.delegate = self;
    self.hotestTableView.dataSource = self;
    self.hotestTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.contentScrollView addSubview:self.hotestTableView];
    //设置contentSize
    [self.contentScrollView setContentSize:CGSizeMake(_contentScrollView.width_ * 2, _contentScrollView.height_)];
}
//集成刷新控件
- (void)setupRefreshView
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *hotHeader = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [hotHeader updateFillerColor:kColorWhite];
    MJTXRefreshGifHeader *gifHeader = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _hotestTableView.header = hotHeader;
    _newestTableView.header = gifHeader;
    _hotestTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    _newestTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *hotStateFooter = (MJRefreshAutoStateFooter *) _hotestTableView.footer;
    [hotStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _newestTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];

}
- (UIActivityIndicatorView *)hotestLoadingIndicatorView
{
    if (!_hotestLoadingIndicatorView) {
        _hotestLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _hotestLoadingIndicatorView;
}
- (UIActivityIndicatorView *)newestLoadingIndicatorView
{
    if (!_newestLoadingIndicatorView) {
        _newestLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _newestLoadingIndicatorView;
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        THQuestionSelectTagViewController *vc = [[THQuestionSelectTagViewController alloc] init];
        vc.backVc = self.rdv_tabBarController;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)onSegmentControlValueChanged:(UISegmentedControl *)control
{
    [self setCurrentSelectedIndex:control.selectedSegmentIndex];
}
#pragma mark - NSNotification通知
- (void)onReceiveRefreshNewestQuestionsNotification:(NSNotification *)notification
{
    if (_flags.newHasFetched) {
        _flags.newTopRefresh = YES;
        [_newestTableView.header beginRefreshing];
    }
    [self setCurrentSelectedIndex:0];
}
- (void)onReceiveAddNewAnswerNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo && [[userInfo allKeys] containsObject:@"questionId"]) {
        int64_t questionId = [userInfo[@"questionId"] longLongValue];
        [self refreshQuestionListWithId:questionId];
    }
}
//根据id刷新数据
- (void)refreshQuestionListWithId:(int64_t)questionId
{
    __block NSInteger hotIndex = -1;
    __block NSInteger latestIndex = -1;
    //从最热列表中查找
    @synchronized(self.hotestQuestions) {
        [self.hotestQuestions enumerateObjectsUsingBlock:^(TXPBQuestion *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id == questionId) {
                //喜欢该条回答
                hotIndex = idx;
                *stop = YES;
            }
        }];
    }
    if (hotIndex != -1) {
        //刷新该列
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:hotIndex inSection:0];
        if ([[self.hotestTableView indexPathsForVisibleRows] containsObject:indexPath]) {
            [self.hotestTableView beginUpdates];
            [self.hotestTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.hotestTableView endUpdates];
        }
    }
    //从最新列表中查找
    @synchronized(self.newestQuestions) {
        [self.newestQuestions enumerateObjectsUsingBlock:^(TXPBQuestion *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id == questionId) {
                //喜欢该条回答
                latestIndex = idx;
                *stop = YES;
            }
        }];
    }
    if (latestIndex != -1) {
        //刷新该列
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:latestIndex inSection:0];
        if ([[self.newestTableView indexPathsForVisibleRows] containsObject:indexPath]) {
            [self.newestTableView beginUpdates];
            [self.newestTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.newestTableView endUpdates];
        }
    }
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
        [_newestTableView.header beginRefreshing];
    }else if (_currentIndex == 1 && !_flags.hotHasFetched) {
        [_hotestTableView.header beginRefreshing];
    }
}
//获取问题列表
- (void)fetchQuestionListDataWithMaxId:(int64_t)maxId
{
    if (_currentIndex == 1 && !_flags.hotHasFetched) {
        //请求热门
        self.hotestLoadingIndicatorView.center = CGPointMake(_contentScrollView.centerX, _hotestTableView.centerY -  40);
        [self.hotestTableView addSubview:self.hotestLoadingIndicatorView];
        [self.hotestLoadingIndicatorView startAnimating];
        //更新标志位
        _flags.hotHasFetched = YES;
    }else if (_currentIndex == 0 && !_flags.newHasFetched) {
        //请求最新
        self.newestLoadingIndicatorView.center = CGPointMake(_contentScrollView.centerX, _newestTableView.centerY -  40);
        [self.newestTableView addSubview:self.newestLoadingIndicatorView];
        [self.newestLoadingIndicatorView startAnimating];
        //更新标志位
        _flags.newHasFetched = YES;
    }
    if (_currentIndex == 1) {
        //获取热门的问题集
        [[TXChatClient sharedInstance].txJsbMansger fetchHotQuestionsWithPageNum:_flags.hotTopRefresh ? 1 : _hotQuestionPage onCompleted:^(NSError *error, NSArray *questions, BOOL hasMore) {
            if (_flags.hotTopRefresh) {
                [_hotestTableView.header endRefreshing];
            }else{
                [_hotestTableView.footer endRefreshing];
            }
            //处理数据
            if (error) {
                [self showFailedHudWithError:error];
                if (_hotestLoadingIndicatorView) {
                    [self.hotestLoadingIndicatorView stopAnimating];
                    [self.hotestLoadingIndicatorView removeFromSuperview];
                    self.hotestLoadingIndicatorView = nil;
                }
            }else{
                if (_flags.hotTopRefresh) {
                    @synchronized (_hotestQuestions) {
                        _hotestQuestions = [NSMutableArray arrayWithArray:questions];
                    }
                    _hotQuestionPage = 2;
                }else{
                    @synchronized (_hotestQuestions) {
                        [_hotestQuestions addObjectsFromArray:questions];
                    }
                    _hotQuestionPage += 1;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_hotestLoadingIndicatorView) {
                        [self.hotestLoadingIndicatorView stopAnimating];
                        [self.hotestLoadingIndicatorView removeFromSuperview];
                        self.hotestLoadingIndicatorView = nil;
                    }
                    [_hotestTableView reloadData];
                    [_hotestTableView.footer setHidden:!hasMore];
                });
            }
        }];
    }else{
        //获取最新的问题集
        [[TXChatClient sharedInstance].txJsbMansger fetchQuestionsWithTagId:0 authorId:0 maxId:maxId onCompleted:^(NSError *error, NSArray *questions, BOOL hasMore) {
            if (error) {
                [self showFailedHudWithError:error];
                if (_hotestLoadingIndicatorView) {
                    [self.hotestLoadingIndicatorView stopAnimating];
                    [self.hotestLoadingIndicatorView removeFromSuperview];
                    self.hotestLoadingIndicatorView = nil;
                }
            }else{
                if (_flags.newTopRefresh) {
                    @synchronized (_newestQuestions) {
                        _newestQuestions = [NSMutableArray arrayWithArray:questions];
                    }
                    _newQuestionPage = 2;
                }else{
                    @synchronized (_newestQuestions) {
                        [_newestQuestions addObjectsFromArray:questions];
                    }
                    _newQuestionPage += 1;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_newestLoadingIndicatorView) {
                        [self.newestLoadingIndicatorView stopAnimating];
                        [self.newestLoadingIndicatorView removeFromSuperview];
                        self.newestLoadingIndicatorView = nil;
                    }
                    [_newestTableView reloadData];
                    if (_flags.newTopRefresh) {
                        [_newestTableView.header endRefreshing];
                    }else{
                        [_newestTableView.footer endRefreshing];
                    }
                    [_newestTableView.footer setHidden:!hasMore];
                });
            }
        }];
    }
}
//获取问题,暂时用字典代替对象
- (TXPBQuestion *)questionAtIndex:(NSInteger)index isHot:(BOOL)isHot
{
    if (isHot) {
        //热门问题
        if (!_hotestQuestions || ![_hotestQuestions count]) {
            return nil;
        }
        __block TXPBQuestion *dict = nil;
        if (index >= 0 && index < [_hotestQuestions count]) {
            dict = _hotestQuestions[index];
        }
        return dict;
    }
    //最新问题
    if (!_newestQuestions || ![_newestQuestions count]) {
        return nil;
    }
    __block TXPBQuestion *data = nil;
    if (index >= 0 && index < [_newestQuestions count]) {
        data = _newestQuestions[index];
    }
    return data;
}
#pragma mark - 上拉刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    if (_currentIndex == 1) {
        _flags.hotTopRefresh = YES;
        [self fetchQuestionListDataWithMaxId:LLONG_MAX];
    }else{
        _flags.newTopRefresh = YES;
        [self fetchQuestionListDataWithMaxId:LLONG_MAX];
    }
}
//上拉加载
- (void)footerRereshing
{
    if (_currentIndex == 1) {
        _flags.hotTopRefresh = NO;
        TXPBQuestion *question = [_hotestQuestions lastObject];
        [self fetchQuestionListDataWithMaxId:question.id];
    }else{
        _flags.newTopRefresh = NO;
        TXPBQuestion *question = [_newestQuestions lastObject];
        [self fetchQuestionListDataWithMaxId:question.id];
    }
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _hotestTableView) {
        return [_hotestQuestions count];
    }
    return [_newestQuestions count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXPBQuestion *question = [self questionAtIndex:indexPath.row isHot:_currentIndex == 1 ? YES : NO];
    CGFloat height = [THQuestionListTableViewCell heightForCellWithQuestion:question contentWidth:tableView.width_];
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    THQuestionListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[THQuestionListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify cellWidth:CGRectGetWidth(tableView.frame)];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.questionDict = [self questionAtIndex:indexPath.row isHot:_currentIndex == 1 ? YES : NO];
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转
    THQuestionDetailViewController *vc = [[THQuestionDetailViewController alloc] init];
    vc.pbQuestion = [self questionAtIndex:indexPath.row isHot:_currentIndex == 1 ? YES : NO];
    [self.navigationController pushViewController:vc animated:YES];
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
@end
