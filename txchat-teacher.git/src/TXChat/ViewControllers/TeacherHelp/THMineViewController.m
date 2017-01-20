//
//  THMineViewController.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "THMineViewController.h"
#import <UIImage+Utils.h>
#import <UIImageView+Utils.h>
#import "MJTXRefreshGifHeader.h"
#import <MJRefresh.h>
#import "MineQuestionTableViewCell.h"
#import "MineAnswerTableViewCell.h"
#import "THQuestionSelectTagViewController.h"
#import "THQuestionDetailViewController.h"
#import "THAnswerDetailViewController.h"
#import "NSObject+EXTParams.h"

typedef NS_ENUM(NSInteger, QuestionsType)
{
    QuestionsType_myQuestions = 0,
    QuestionsType_myAnswers,
};

@interface THMineViewController ()<UITabBarDelegate, UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate>
{
    NSInteger _selectedAttendanceIndex;//tab栏 选中按钮顺序
    UITabBarItem *_leftItem;
    UITabBarItem *_rightItem;
    UITabBar *_tabbar;
    UIView  *_tabSelectedBtmView; //tab栏 下面 选中标签
    UITableView *_myQuestionstableView;
    UITableView *_myAnswerstableView;
    NSMutableArray *_questionsList;
    NSMutableArray *_answersList;    
    UIScrollView *_scrollView;
    UIView *_contentView;//滚动条内的view;
}
@end

@implementation THMineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _questionsList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

-(void)dealloc
{
    [self  removeNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"个人";
    [self createCustomNavBar];
    //设置提问
    [self.btnRight setTitle:@"提问" forState:UIControlStateNormal];
    
    [self setupTabViews];
    [self setupViews];
    [self setupRefresh];
    [self addEmptyDataImage:NO showMessage:@"还没有提问哦。"];
    [self addNotification];
    self.view.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
    
    [_myQuestionstableView.header beginRefreshing];
}

-(void)setupViews
{
    UIView *beginLine = [[UIView alloc] init];
    beginLine.backgroundColor = kColorLine;
    [self.view addSubview:beginLine];
    [beginLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kLineHeight);
        make.left.and.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).with.offset(self.customNavigationView.maxY);
    }];
    
    [_tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(beginLine.mas_bottom);
        make.left.and.right.mas_equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    
    UIScrollView *scrollView = UIScrollView.new;
    _scrollView = scrollView;
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = kColorBackground;
    [self.view addSubview:scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tabbar.mas_bottom);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    UIView* contentView = UIView.new;
    [contentView setBackgroundColor:kColorBackground];
    _contentView = contentView;
    [_scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
    }];
    //我的问题
    _myQuestionstableView = [[UITableView alloc] init];
    [_myQuestionstableView setDelegate:self];
    [_myQuestionstableView setDataSource:self];
    [_myQuestionstableView setShowsVerticalScrollIndicator:YES];
    [_myQuestionstableView setBackgroundColor:self.view.backgroundColor];
    _myQuestionstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentView addSubview:_myQuestionstableView];
    
    //我的回答
    _myAnswerstableView = [[UITableView alloc] init];
    [_myAnswerstableView setDelegate:self];
    [_myAnswerstableView setDataSource:self];
    [_myAnswerstableView setShowsVerticalScrollIndicator:YES];
    [_myAnswerstableView setBackgroundColor:self.view.backgroundColor];
    _myAnswerstableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_contentView addSubview:_myAnswerstableView];
    
    [_myQuestionstableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.bottom.mas_equalTo(_contentView.mas_bottom);
        make.right.mas_equalTo(_myAnswerstableView.mas_left);
    }];
    
    [_myAnswerstableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.width.mas_equalTo(self.view.frame.size.width);
        make.bottom.mas_equalTo(_contentView.mas_bottom);
        make.left.mas_equalTo(_myQuestionstableView.mas_right);
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@[_myAnswerstableView, _myQuestionstableView, self.view]);
        make.width.mas_equalTo(kScreenWidth*2);
    }];
    
    _scrollView.contentSize = CGSizeMake(kScreenWidth*2, kScreenHeight-_tabbar.maxY);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
}


-(void)setupTabViews
{
    UIColor *selectedColor = RGBCOLOR(0xff, 0x93, 0x3d);
    
    UITabBar *tabbar = [[UITabBar alloc] init];
    UITabBarItem *leftItem = nil;
    if(IOS7_OR_LATER)
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"我的提问" image:nil selectedImage:nil];
    }
    else
    {
        leftItem = [[UITabBarItem alloc] initWithTitle:@"我的提问" image:nil tag:0];
    }
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      KColorSubTitleTxt, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateNormal];
    
    
    [leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                      selectedColor, NSForegroundColorAttributeName,
                                      kFontLarge, NSFontAttributeName,
                                      nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [leftItem setTitlePositionAdjustment:UIOffsetMake(0, -8)];
    _leftItem = leftItem;
    
    UITabBarItem *rightItem = nil;
    if(IOS7_OR_LATER)
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"我的回答" image:nil selectedImage:nil];
    }
    else
    {
        rightItem = [[UITabBarItem alloc] initWithTitle:@"我的回答" image:nil tag:0];
    }
    
    
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       KColorSubTitleTxt, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateNormal];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                       selectedColor, NSForegroundColorAttributeName,
                                       kFontLarge, NSFontAttributeName,
                                       nil]  forState:UIControlStateSelected|UIControlStateHighlighted];
    [rightItem setTitlePositionAdjustment:UIOffsetMake(0, -8)];
    _rightItem = rightItem;
    NSArray *tabBarItemArray = [[NSArray alloc] initWithObjects: leftItem,rightItem,nil];
    [tabbar setItems: tabBarItemArray];
    [tabbar setBackgroundImage:[UIImageView createImageWithColor:kColorWhite]];
    [[UITabBar appearance] setShadowImage:[UIImageView createImageWithColor:kColorWhite]];
    tabbar.delegate = self;
    [self.view addSubview:tabbar];
    _tabbar = tabbar;
    [tabbar setSelectedItem:_leftItem];
    
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = RGBCOLOR(0xff, 0x93, 0x3d);
    _tabSelectedBtmView = selectedView;
    [tabbar addSubview:selectedView];
    CGFloat selectedViewWidth = kScreenWidth/2.0f;
    [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(selectedViewWidth, 2));
        make.bottom.mas_equalTo(tabbar.mas_bottom);
        make.left.mas_equalTo(tabbar.mas_left);
    }];
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
    }else{
        //发布
        THQuestionSelectTagViewController *vc = [[THQuestionSelectTagViewController alloc] init];
        vc.backVc = self.rdv_tabBarController;
        [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark-  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item // called when a new view is selected by the user (but not programatically)
{
    if(item == _leftItem)
    {
        if(_selectedAttendanceIndex != QuestionsType_myQuestions)
        {
            _selectedAttendanceIndex = QuestionsType_myQuestions;
            [self updateSelectedBtmView:_selectedAttendanceIndex];
            [_scrollView scrollRectToVisible:_myQuestionstableView.frame animated:YES];
            [self updateQuestionsTableView];
            [self performSelector:@selector(updateEmptyDataImage) withObject:nil afterDelay:0.3f];
        }
    }
    else if (item == _rightItem)
    {
        if(_selectedAttendanceIndex != QuestionsType_myAnswers)
        {
            _selectedAttendanceIndex = QuestionsType_myAnswers;
            [self updateSelectedBtmView:_selectedAttendanceIndex];
            [_scrollView scrollRectToVisible:_myAnswerstableView.frame animated:YES];
            [self updateAnswerTableView];
            [self performSelector:@selector(updateEmptyDataImage) withObject:nil afterDelay:0.3f];
        }
    }
}

-(void)updateSelectedBtmView:(NSInteger)index
{
    CGFloat centerY = kScreenWidth/2.0f;
    [_tabSelectedBtmView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_tabbar.mas_left).with.offset(centerY*index );
    }];
    [_tabSelectedBtmView layoutIfNeeded];
}

-(void)updateEmptyDataImage
{
    if(_selectedAttendanceIndex == QuestionsType_myQuestions)
    {
        if(_questionsList.count <= 0)
        {
            [self updateEmptyDataImageStatusAndTitle:YES newShowTitle:@"还没有提问哦"];
        }
        else
        {
            [self updateEmptyDataImageStatusAndTitle:NO newShowTitle:nil];
        }
    }
    else
    {
        if(_answersList.count <= 0)
        {
            [self updateEmptyDataImageStatusAndTitle:YES newShowTitle:@"还没有回答过问题哦"];
        }
        else
        {
            [self updateEmptyDataImageStatusAndTitle:NO newShowTitle:nil];
        }
        
    }
}

-(void)updateQuestionsTableView
{
    if(_questionsList.count <= 0)
    {
        [_myQuestionstableView.header beginRefreshing];
    }
    else
    {
        [_myQuestionstableView reloadData];
    }
}

-(void)updateAnswerTableView
{
    if(_answersList.count <= 0)
    {
        [_myAnswerstableView.header beginRefreshing];
    }
    else
    {
        [_myAnswerstableView reloadData];
    }
}



#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == _myQuestionstableView)
    {
        return _questionsList.count;
    }
    else
    {
        return _answersList.count;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(_myQuestionstableView == tableView)
    {
        static NSString *CellQuestionIdentifier = @"MineQuestionTableViewCell";
        MineQuestionTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:CellQuestionIdentifier];
        if (questionCell == nil) {
            questionCell = [[[NSBundle mainBundle] loadNibNamed:@"MineQuestionTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        if(indexPath.section >= _questionsList.count)
        {
            return  questionCell;
        }
        TXPBQuestion *question = _questionsList[indexPath.section];
        questionCell.titleLabel.text = question.title;
        NSString *questionDetail = question.content;
        NSMutableAttributedString *mutableDetail = [[NSMutableAttributedString alloc] initWithString:questionDetail];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.headIndent = 0;
        style.lineSpacing = 3;
        [mutableDetail addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, questionDetail.length)];
        questionCell.detailLabel.attributedText = mutableDetail;
        questionCell.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        
        int64_t replyNumber = 0;
        NSNumber *extNumber = [question extParamForKey:@"replyNumber"];
        if (extNumber) {
            replyNumber = [extNumber intValue];
        }else{
            replyNumber = question.replyNum;
        }        
        questionCell.answerLabel.text = [NSString stringWithFormat:@"%@人回答", @(replyNumber)];
        cell = questionCell;
    }
    else
    {
        static NSString *CellAnswerIdentifier = @"MineAnswerTableViewCell";
        MineAnswerTableViewCell *answerCell = [tableView dequeueReusableCellWithIdentifier:CellAnswerIdentifier];
        if (answerCell == nil) {
            answerCell = [[[NSBundle mainBundle] loadNibNamed:@"MineAnswerTableViewCell" owner:self options:nil] objectAtIndex:0];
        }
        if(indexPath.section >= _answersList.count)
        {
            return  answerCell;
        }
        TXPBQuestionAnswer *answer = _answersList[indexPath.section];
        answerCell.titleLabel.text = answer.questionTitle;
        NSString *answerDetail = answer.content;
        NSMutableAttributedString *mutableDetail = [[NSMutableAttributedString alloc] initWithString:answerDetail];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.headIndent = 0;
        style.lineSpacing = 3;
        [mutableDetail addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, answerDetail.length)];
        answerCell.detailLabel.attributedText = mutableDetail;
        answerCell.detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cell = answerCell;
    }
    return cell;
}
#pragma mark-  UITableViewDelegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(tableView == _myQuestionstableView)
    {
        if(indexPath.section < _questionsList.count)
        {
            TXPBQuestion *question = _questionsList[indexPath.section];
            THQuestionDetailViewController *vc = [[THQuestionDetailViewController alloc] init];
            vc.pbQuestion = question;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
    {
        if(indexPath.section < _answersList.count)
        {
            TXPBQuestionAnswer *answer = _answersList[indexPath.section];
            THAnswerDetailViewController *answerVc = [[THAnswerDetailViewController alloc] init];
            answerVc.questionAnswer = answer;
            [self.navigationController pushViewController:answerVc animated:YES];
        }
    }
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _myQuestionstableView)
    {
        return 97.0f;
    }
    return 78.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = kColorClear;
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 5.0f);
    return headerView;
}
//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    _myQuestionstableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _myQuestionstableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _myQuestionstableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
    _myAnswerstableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    _myAnswerstableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter1 = (MJRefreshAutoStateFooter *) _myAnswerstableView.footer;
    [autoStateFooter1 setTitle:@"" forState:MJRefreshStateIdle];
}


#pragma mark - 下拉刷新 拉取本地历史消息
- (void)headerRereshing{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self fetchNewDataRereshing];
    });
}
- (void)footerRereshing{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self LoadLastPages];
    });
}


- (void)LoadLastPages
{
    if(_selectedAttendanceIndex == QuestionsType_myQuestions)
    {
        [self loadLastPagesForQuestions];
    }
    else
    {
        [self loadLastPagesForAnswers];
    }
    
    
}

-(void)loadLastPagesForQuestions
{
    int64_t questionId = 0;
    if(_questionsList && [_questionsList count] > 0)
    {
        TXPBQuestion *question = _questionsList.lastObject;
        questionId = question.id;
    }
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    @weakify(self);
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionsWithTagId:0 authorId:currentUser.userId maxId:questionId onCompleted:^(NSError *error, NSArray *questions, BOOL hasMore) {
        @strongify(self);
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            [_myQuestionstableView.footer endRefreshing];
        }
        else
        {
            [self updateMyQuestionsAfterFooterRefresh:questions];
            [_myQuestionstableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_questionsList count] > 0?NO:YES];
    }];
}

-(void)updateMyQuestionsAfterFooterRefresh:(NSArray *)myQuestions
{
    @synchronized(_questionsList)
    {
        if(myQuestions != nil && [myQuestions count] > 0)
        {
            [_questionsList addObjectsFromArray:myQuestions];
        }
    }
    [_myQuestionstableView reloadData];
    [_myQuestionstableView.footer endRefreshing];
}


-(void)loadLastPagesForAnswers
{
    int64_t answerId = 0;
    if(_answersList && [_answersList count] > 0)
    {
        TXPBQuestionAnswer *answer = _answersList.lastObject;
        answerId = answer.id;
    }
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    @weakify(self);
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionAnswersWithQuestionId:0 authorId:currentUser.userId userType:0 maxId:answerId onCompleted:^(NSError *error, NSArray *answers, BOOL hasMore, NSArray *expertAnswers, BOOL hasMoreExpertAnswers) {
        @strongify(self);
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            [_myAnswerstableView.footer endRefreshing];
        }
        else
        {
            [self updateMyAnswersAfterFooterRefresh:answers];
            [_myAnswerstableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_answersList count] > 0?NO:YES];
    }];
}

-(void)updateMyAnswersAfterFooterRefresh:(NSArray *)myAnswers
{
    @synchronized(_answersList)
    {
        if(myAnswers != nil && [myAnswers count] > 0)
        {
            [_answersList addObjectsFromArray:myAnswers];
        }
    }
    [_myAnswerstableView reloadData];
    [_myAnswerstableView.footer endRefreshing];
}


- (void)fetchNewDataRereshing{
    if(_selectedAttendanceIndex == QuestionsType_myQuestions)
    {
        [self fetchNewMyQuestions];
    }
    else
    {
        [self fetchNewMyAnswers];
    }
}

-(void)fetchNewMyQuestions
{
    @weakify(self);
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionsWithTagId:0 authorId:currentUser.userId maxId:LONG_MAX onCompleted:^(NSError *error, NSArray *questions, BOOL hasMore) {
        @strongify(self);
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            [_myQuestionstableView.header endRefreshing];
        }
        else
        {
            [self updateQuestionsAfterHeaderRefresh:questions];
            [_myQuestionstableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_questionsList count] > 0?NO:YES];
    }];
}

-(void)updateQuestionsAfterHeaderRefresh:(NSArray *)questions
{
    @synchronized(_questionsList)
    {
        if(questions != nil && [questions count] > 0)
        {
            _questionsList = [NSMutableArray arrayWithArray:questions];
        }
    }
    [_myQuestionstableView.header endRefreshing];
    [_myQuestionstableView reloadData];
}


-(void)fetchNewMyAnswers
{
    @weakify(self);
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionAnswersWithQuestionId:0 authorId:currentUser.userId userType:0 maxId:LONG_MAX onCompleted:^(NSError *error, NSArray *answers, BOOL hasMore, NSArray *expertAnswers, BOOL hasMoreExpertAnswers) {
        @strongify(self);
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            [_myAnswerstableView.header endRefreshing];
        }
        else
        {
            [self updateAnswersAfterHeaderRefresh:answers];
            [_myAnswerstableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_answersList count] > 0?NO:YES];
    }];
}

-(void)updateAnswersAfterHeaderRefresh:(NSArray *)answers
{
    @synchronized(_answersList)
    {
        if(answers != nil && [answers count] > 0)
        {
            _answersList = [NSMutableArray arrayWithArray:answers];
        }
    }
    [_myAnswerstableView.header endRefreshing];
    [_myAnswerstableView reloadData];
}

#pragma mark-- UIScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint point=scrollView.contentOffset;
//    NSLog(@"%f,%f %@",point.x,point.y, @(__LINE__));
    if(point.x <= 0)
    {
        return;
    }
    if(point.x > kScreenWidth*2/4)
    {
        _selectedAttendanceIndex = QuestionsType_myAnswers;
    }
    else
    {
        _selectedAttendanceIndex = QuestionsType_myQuestions;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {
        CGRect visibleBounds = scrollView.bounds;
//        NSLog(@"rect:%@", NSStringFromCGRect(visibleBounds));
        NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
        if (index < 0) index = 0;
        if (index > 1) index = 1;
        if(index == 0)
        {
            _selectedAttendanceIndex = QuestionsType_myQuestions;
            [self updateEmptyDataImage];
            [self updateQuestionsTableView];
            [_tabbar setSelectedItem:_leftItem];
        }
        else
        {
            _selectedAttendanceIndex = QuestionsType_myAnswers;
            [self updateEmptyDataImage];
            [self updateAnswerTableView];
            [_tabbar setSelectedItem:_rightItem];
        }
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point=scrollView.contentOffset;
//    NSLog(@"%f,%f, %@",point.x,point.y, @(__LINE__));
    if(point.x > 0 && point.x < kScreenWidth)
    {
        [_tabSelectedBtmView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_tabbar.mas_left).with.offset(point.x/2);
        }];
        [_tabSelectedBtmView layoutIfNeeded];
        [self updateEmptyDataImageStatusAndTitle:NO newShowTitle:nil];
    }
}

#pragma mark-- 通知
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyNumbersChanges:) name:TeacherHelpQuestionReplysChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newQuestions:) name:TeacherHelpRefreshNewQuestionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newReply) name:TeacherHelpRefreshNewAnswerNotification object:nil];

}
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TeacherHelpQuestionReplysChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TeacherHelpRefreshNewQuestionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TeacherHelpRefreshNewAnswerNotification object:nil];
}

-(void)replyNumbersChanges:(NSNotification *)notification
{
    NSNumber *requestId = [notification.userInfo objectForKey:@"questionId"];
    __block NSInteger index = -1;
    [_questionsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TXPBQuestion *question = (TXPBQuestion *)obj;
        if(question && question.id == requestId.longLongValue)
        {
            index = idx;
            *stop = YES;
        }
    }];
    if(index >= 0)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
        [_myQuestionstableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)newQuestions:(NSNotification *)notification
{
    TXAsyncRunInMain(^{
        [_myQuestionstableView.header beginRefreshing];
    });
}

-(void)newReply
{
    TXAsyncRunInMain(^{
        [_myAnswerstableView.header beginRefreshing];
    });
}



@end
