//
//  THSpecialistAnsweredQuestionsViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/30.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THSpecialistAnsweredQuestionsViewController.h"
#import "SpecialResponseTableViewCell.h"
#import <MJRefresh.h>
#import "MJTXRefreshGifHeader.h"
#import "THAnswerDetailViewController.h"

@interface THSpecialistAnsweredQuestionsViewController ()< UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_answersList;
    TXPBExpert *_expect;
}
@end

@implementation THSpecialistAnsweredQuestionsViewController

-(id)initWithSpecialist:(TXPBExpert *)expect
{
    self = [super init];
    if(self)
    {
        _expect = expect;
        _answersList = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"回答的问题";
    [self createCustomNavBar];
    [self setupViews];
    [self setupRefresh];
    self.view.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
    
    [_tableView.header beginRefreshing];
}

-(void)setupViews
{

    //我的问题
    _tableView = [[UITableView alloc] init];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setShowsVerticalScrollIndicator:YES];
    [_tableView setBackgroundColor:self.view.backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(self.customNavigationView.maxY, 0, 0, 0));
    }];
}

#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark-  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    return [_questionsList count];
    return _answersList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *CellQuestionIdentifier = @"SpecialResponseTableViewCell";
    SpecialResponseTableViewCell *questionCell = [tableView dequeueReusableCellWithIdentifier:CellQuestionIdentifier];
    if (questionCell == nil) {
        questionCell = [[[NSBundle mainBundle] loadNibNamed:@"SpecialResponseTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    if(indexPath.section >= _answersList.count)
    {
        return  questionCell;
    }
    TXPBQuestionAnswer *answer = _answersList[indexPath.section];
    questionCell.questionTitleLabel.text = answer.questionTitle;
    NSString *answerDetail = answer.content;
    NSMutableAttributedString *mutableDetail = [[NSMutableAttributedString alloc] initWithString:answerDetail];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.headIndent = 0;
    style.lineSpacing = 6;
    [mutableDetail addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, answerDetail.length)];
    questionCell.answerDetailLabel.attributedText = mutableDetail;
    questionCell.supportCountLabel.text = [NSString stringWithFormat:@"%@", [self formatSupportByNumber:(NSInteger)(answer.thankNum)]];
    [questionCell.supportCountLabel sizeToFit];
    cell = questionCell;
    return cell;
}

-(NSString *)formatSupportByNumber:(NSInteger)thankNum
{
//    if(thankNum <= 9999)
//    {
//        return [NSString stringWithFormat:@"%@", @(thankNum)];
//    }
//    return [NSString stringWithFormat:@"%@万", @(thankNum/10000.0f)];
    return [NSString stringWithFormat:@"%@", @(thankNum )];
}

#pragma mark-  UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TXPBQuestionAnswer *answer = _answersList[indexPath.section];
    THAnswerDetailViewController *answerVc = [[THAnswerDetailViewController alloc] init];
    answerVc.questionAnswer = answer;
    [self.navigationController pushViewController:answerVc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84.0f;
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
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf fetchNewQuestionAnswersRereshing];
    });
}
- (void)footerRereshing{
    __weak __typeof(&*self) weakSelf=self;  //by sck
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf LoadLastPages];
    });
}


- (void)LoadLastPages
{
        int64_t beginAnswerId = 0;
        if(_answersList != nil && [_answersList count] > 0)
        {
            TXPBQuestionAnswer *beginAnswer = _answersList.lastObject;
            beginAnswerId = beginAnswer.id;
        }
    @weakify(self);
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionAnswersWithQuestionId:0 authorId:_expect.id userType:0 maxId:beginAnswerId onCompleted:^(NSError *error, NSArray *answers, BOOL hasMore, NSArray *expertAnswers, BOOL hasMoreExpertAnswers) {
        @strongify(self);
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            [_tableView.footer endRefreshing];
        }
        else
        {
            [self updateAnswersAfterFooterReresh:answers];
            [_tableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_answersList count] > 0?NO:YES];
    }];

}



-(void)updateAnswersAfterFooterReresh:(NSArray *)answers
{
    @synchronized(_answersList)
    {
        if(answers != nil && [answers count] > 0)
        {
            [_answersList addObjectsFromArray:answers];
        }
    }
    [_tableView reloadData];
    [_tableView.footer endRefreshing];
}


- (void)fetchNewQuestionAnswersRereshing{
    @weakify(self);
    [[TXChatClient sharedInstance].txJsbMansger fetchQuestionAnswersWithQuestionId:0 authorId:_expect.id userType:0 maxId:LONG_MAX onCompleted:^(NSError *error, NSArray *answers, BOOL hasMore, NSArray *expertAnswers, BOOL hasMoreExpertAnswers) {
        @strongify(self);
        if(error)
        {
            DDLogDebug(@"error:%@", error);
            [self showFailedHudWithError:error];
            [_tableView.header endRefreshing];
        }
        else
        {
            [self updateAnswersAfterHeaderRefresh:answers];
            [_tableView.footer setHidden:!hasMore];
        }
        [self updateEmptyDataImageStatus:[_answersList count] > 0?NO:YES];
        
    }];
}

- (void)updateAnswersAfterHeaderRefresh:(NSArray *)answers
{
    @synchronized(_answersList)
    {
        if(answers != nil && [answers count] > 0)
        {
            _answersList = [NSMutableArray arrayWithArray:answers];
        }
    }
    [_tableView.header endRefreshing];
    [_tableView reloadData];
}

@end
