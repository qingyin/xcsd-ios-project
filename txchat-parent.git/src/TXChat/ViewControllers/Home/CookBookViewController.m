//
//  CookBookViewController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CookBookViewController.h"
#import "TXProgressHUD.h"
#import "CookBookDetailView.h"

static NSInteger const kRecipeViewTag = 100;

@interface CookBookViewController ()
<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UILabel *_titleDateLabel;
    UIButton *_previousRecipeButton;
    UIButton *_nextRecipeButton;
    UIImageView *_leftScrollIndicatorView;
    UIImageView *_rightScrollIndicatorView;
    NSInteger _currentIndex;
}
@property (nonatomic,strong) NSArray *listArray;
@end

@implementation CookBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    self.titleStr = @"食谱";
    [self fetchCookBookListWithMaxId:LLONG_MAX];
}

#pragma mark - UI视图创建
- (void)setupCookBookScrollView
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), 35)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    _titleDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, topView.width_, topView.height_)];
    _titleDateLabel.backgroundColor = [UIColor clearColor];
    _titleDateLabel.textAlignment = NSTextAlignmentCenter;
    _titleDateLabel.font = [UIFont systemFontOfSize:16];
    _titleDateLabel.textColor = RGBCOLOR(0xff, 0x9f, 0x22);
    [topView addSubview:_titleDateLabel];
    //添加滑动标示
    _leftScrollIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 15, 15)];
    _leftScrollIndicatorView.backgroundColor = [UIColor clearColor];
    [_leftScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_leftArrow_normal"]];
    [topView addSubview:_leftScrollIndicatorView];
    _rightScrollIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(topView.width_ - 25, 10, 15, 15)];
    _rightScrollIndicatorView.backgroundColor = [UIColor clearColor];
    [_rightScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_rightArrow_normal"]];
    [topView addSubview:_rightScrollIndicatorView];
    //添加点击按钮
    _previousRecipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _previousRecipeButton.frame = CGRectMake(0, 0, 80, topView.height_);
    [_previousRecipeButton addTarget:self action:@selector(onPreviousRecipeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:_previousRecipeButton];
    _nextRecipeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextRecipeButton.frame = CGRectMake(topView.width_ - 80, 0, 80, topView.height_);
    [_nextRecipeButton addTarget:self action:@selector(onNextRecipeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:_nextRecipeButton];
    //添加分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, topView.height_ - kLineHeight, topView.width_, kLineHeight)];
    lineView.backgroundColor = kColorLine;
    [topView addSubview:lineView];
    //滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - topView.maxY)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.directionalLockEnabled = YES;
    [_scrollView setShowsHorizontalScrollIndicator:YES];
    [self.view addSubview:_scrollView];
    
}
- (void)freshRecipesListView
{
    for (NSInteger i = 0; i < [self.listArray count]; i++) {
        TXPost *post = self.listArray[i];
        CookBookDetailView *recipeView = [[CookBookDetailView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) * i, 0, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame)) postId:post.postId postType:TXHomePostType_Recipes];
        recipeView.backgroundColor = [UIColor clearColor];
        recipeView.webView.scrollView.bounces = NO;
        recipeView.tag = kRecipeViewTag + i;
        [_scrollView addSubview:recipeView];
        //添加分割线
        if (i != [self.listArray count] - 1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_scrollView.frame) * (i + 1) - 1, 0, 2, CGRectGetHeight(_scrollView.frame))];
            lineView.backgroundColor = kColorLine;
            [_scrollView addSubview:lineView];
        }
        //先加载第一页
        if (i == 0 || i == 1) {
            [recipeView startRecipeRequest];
        }
    }
    _currentIndex = 0;
    //设置contentsize
    [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.frame) * [self.listArray count], _scrollView.height_)];
    if ([self.listArray count] > 1) {
        [_rightScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_rightArrow_highlighted"]];
    }
    //设置当前标题
    if ([self.listArray count] > 0) {
        TXPost *post = self.listArray[0];
        _titleDateLabel.text = post.title;
    }
}
#pragma mark - 按钮响应
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)onPreviousRecipeButtonTapped
{
    if (_currentIndex == 0) {
        return;
    }
    NSInteger lastIndex = _currentIndex - 1;
    if (lastIndex < 0) {
        lastIndex = 0;
    }
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.frame) * lastIndex, 0) animated:YES];
}
- (void)onNextRecipeButtonTapped
{
    if (_currentIndex >= [self.listArray count] - 1) {
        return;
    }
    NSInteger nextIndex = _currentIndex + 1;
    if (nextIndex > [self.listArray count] - 1) {
        nextIndex = [self.listArray count] - 1;
    }
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.view.frame) * nextIndex, 0) animated:YES];
}
#pragma mark - Helper
//滚动到上一页
- (void)scrollToPreviousRecipePage
{
    NSInteger lastIndex = _currentIndex - 1;
    if (lastIndex < 0) {
        lastIndex = 0;
    }
    CookBookDetailView *lastRecipeView = (CookBookDetailView *)[_scrollView viewWithTag:kRecipeViewTag + lastIndex];
    [lastRecipeView startRecipeRequest];
}
//滚动到下一页
- (void)scrollToNextRecipePage
{
    NSInteger nextIndex = _currentIndex + 1;
    if (nextIndex > [self.listArray count] - 1) {
        nextIndex = [self.listArray count] - 1;
    }
    CookBookDetailView *nextRecipeView = (CookBookDetailView *)[_scrollView viewWithTag:kRecipeViewTag + nextIndex];
    [nextRecipeView startRecipeRequest];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect visibleBounds = scrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self.listArray count] - 1) index = [self.listArray count] - 1;
    _currentIndex = index;
    //当前页开始请求
    CookBookDetailView *recipeView = (CookBookDetailView *)[_scrollView viewWithTag:kRecipeViewTag + _currentIndex];
    [recipeView startRecipeRequest];
    //上一页开始请求
    [self scrollToPreviousRecipePage];
    //下一页开始请求
    [self scrollToNextRecipePage];
    //判断是否显示左右滚动标示
    if (_currentIndex >= 0 && _currentIndex < [self.listArray count]) {
        TXPost *post = self.listArray[index];
        _titleDateLabel.text = post.title;
    }
    if ([self.listArray count] > 0) {
        if (_currentIndex == 0) {
            [_leftScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_leftArrow_normal"]];
        }else {
            [_leftScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_leftArrow_highlighted"]];
        }
        if (_currentIndex == [self.listArray count] - 1) {
            [_rightScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_rightArrow_normal"]];
        }else {
            [_rightScrollIndicatorView setImage:[UIImage imageNamed:@"recipe_rightArrow_highlighted"]];
        }
    }
}
#pragma mark - 网络请求
- (void)fetchCookBookListWithMaxId:(int64_t)maxId
{
    NSError *userError = nil;
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:&userError];
    if (userError) {
        DDLogDebug(@"获取postType:%@ 当前userError:%@",@(TXHomePostType_Recipes),userError);
        //刷新空白信息
        [self addEmptyDataImage:NO showMessage:@"暂无食谱"];
        return;
    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:nil];
    [[TXChatClient sharedInstance] fetchPosts:maxId gardenId:currentUser.gardenId postType:(TXPBPostType)TXHomePostType_Recipes onCompleted:^(NSError *error, NSArray *posts, BOOL hasMore) {
        TXAsyncRunInMain(^{
            [TXProgressHUD hideHUDForView:self.view animated:YES];
            if (error) {
                [self showFailedHudWithError:error];
                DDLogDebug(@"获取postType:%@ 请求error:%@",@(TXHomePostType_Recipes),error);
                //刷新空白信息
                [self addEmptyDataImage:NO showMessage:@"暂无食谱"];
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    self.listArray = [NSArray arrayWithArray:posts];
                    //处理数据并刷新列表
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.listArray count] == 0) {
                            //刷新空白信息
                            [self addEmptyDataImage:NO showMessage:@"暂无食谱"];
                            [self updateEmptyDataImageStatus:YES];
                        }else{
                            [self setupCookBookScrollView];
                            [self freshRecipesListView];
                        }
                    });
                });
            }
        });
    }];
}


@end
