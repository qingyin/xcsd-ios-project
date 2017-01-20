//
//  THSpecialistArticlesViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/30.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THSpecialistArticlesViewController.h"
#import <MJRefresh.h>
#import "THGuideArticleTableViewCell.h"
#import "THGuideArticleDetailViewController.h"

@interface THSpecialistArticlesViewController ()
<UITableViewDelegate,
UITableViewDataSource>
{
    BOOL _isTopRefresh;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *articleList;
@end

@implementation THSpecialistArticlesViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"发布的文章";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRefreshExpertKnowledgeListNotification:) name:TeacherHelpRefreshNewArticleNotification object:nil];
    [self createCustomNavBar];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self setupRefreshView];
    //刷新最新数据
    if (!_articleList) {
        [self.tableView.header beginRefreshing];
    }
}
//集成刷新控件
- (void)setupRefreshView
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    self.tableView.header = gifHeader;
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) self.tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}
#pragma mark - 按钮响应犯法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 刷新通知
- (void)onReceiveRefreshExpertKnowledgeListNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo && [[userInfo allKeys] containsObject:@"knowledgeId"]) {
        int64_t answerId = [userInfo[@"knowledgeId"] longLongValue];
        [self refreshKnowledgeListWithId:answerId];
    }
}
//根据id刷新数据
- (void)refreshKnowledgeListWithId:(int64_t)knowledgeId
{
    __block NSInteger knowledgeIndex = -1;
    //从列表中查找
    @synchronized(self.articleList) {
        [self.articleList enumerateObjectsUsingBlock:^(TXPBKnowledge *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.id == knowledgeId) {
                //喜欢该条回答
                knowledgeIndex = idx;
                *stop = YES;
            }
        }];
    }
    if (knowledgeIndex != -1) {
        //刷新该列
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:knowledgeIndex inSection:0];
        if ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) {
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        }
    }
}
#pragma mark - 网络加载
- (void)fetchGuideArticlesWithMaxId:(int64_t)maxId
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[TXChatClient sharedInstance].txJsbMansger fetchKnowledgesWithTagId:0 auhtorId:_expertInfo.id maxId:maxId onCompleted:^(NSError *error, NSArray *knowledge, BOOL hasMore) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (_isTopRefresh) {
            [self.tableView.header endRefreshing];
        }else{
            [self.tableView.footer endRefreshing];
        }
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            if (_isTopRefresh) {
                @synchronized (_articleList) {
                    self.articleList = [NSMutableArray arrayWithArray:knowledge];
                }
            }else{
                @synchronized (_articleList) {
                    [_articleList addObjectsFromArray:knowledge];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView.footer setHidden:!hasMore];
            });
        }
    }];
}
#pragma mark - 上拉刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    _isTopRefresh = YES;
    [self fetchGuideArticlesWithMaxId:LLONG_MAX];
}
//上拉加载
- (void)footerRereshing
{
    _isTopRefresh = NO;
    TXPBKnowledge *dict = [_articleList lastObject];
    [self fetchGuideArticlesWithMaxId:dict.id];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articleList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 89;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    THGuideArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[THGuideArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify cellWidth:self.view.width_];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
    }
    cell.articleDict = self.articleList[indexPath.row];
    
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转
    TXPBKnowledge *knowledge = self.articleList[indexPath.row];
    THGuideArticleDetailViewController *avc = [[THGuideArticleDetailViewController alloc] init];
    avc.knowledge = knowledge;
    [self.navigationController pushViewController:avc animated:YES];
}

@end
