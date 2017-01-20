//
//  THGuideArticlesTableViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THGuideArticlesTableViewController.h"
#import <MJRefresh.h>
#import "THGuideArticleTableViewCell.h"
#import "THGuideArticleDetailViewController.h"
#import "TXCustomAlertWindow.h"

@interface THGuideArticlesTableViewController ()
{
    BOOL _isTopRefresh;
}
@property (nonatomic,strong) NSMutableArray *articleList;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@end

@implementation THGuideArticlesTableViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveRefreshKnowledgeNotification:) name:TeacherHelpRefreshNewArticleNotification object:nil];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setupRefreshView];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //刷新最新数据
    if (!_articleList) {
        [self.tableView.header beginRefreshing];
    }
}
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadingView;
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
#pragma mark - 刷新通知
- (void)onReceiveRefreshKnowledgeNotification:(NSNotification *)notification
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
- (void)showErrorTip:(NSError *)error
{
    NSString *message = error.userInfo[kErrorMessage];
    NSString *msgWithCode = nil;
    if(error.code > 0){
        msgWithCode = [NSString stringWithFormat:@"%@(%@)",message, @(error.code)];
    }else{
        msgWithCode = message;
    }
    MBProgressHUD *failedHud = [[MBProgressHUD alloc] initWithView:self.view];
    [[TXCustomAlertWindow sharedWindow] showWithView:failedHud];
    failedHud.mode = MBProgressHUDModeNone;
    failedHud.labelText = msgWithCode;
    [failedHud show:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [failedHud hide:YES];
        [[TXCustomAlertWindow sharedWindow] hide];
    });

}
- (void)fetchGuideArticlesWithMaxId:(int64_t)maxId
{
    if (!_articleList) {
        [self.tableView addSubview:self.loadingView];
        self.loadingView.center = CGPointMake(self.tableView.center.x, self.tableView.center.y - 60);
        [self.loadingView startAnimating];
    }
    [[TXChatClient sharedInstance].txJsbMansger fetchKnowledgesWithTagId:_category.id auhtorId:0 maxId:maxId onCompleted:^(NSError *error, NSArray *knowledge, BOOL hasMore) {
        if (_isTopRefresh) {
            [self.tableView.header endRefreshing];
        }else{
            [self.tableView.footer endRefreshing];
        }
        if (error) {
            [self showErrorTip:error];
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
                if (_loadingView) {
                    [self.loadingView stopAnimating];
                    [self.loadingView removeFromSuperview];
                    self.loadingView = nil;
                }
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
