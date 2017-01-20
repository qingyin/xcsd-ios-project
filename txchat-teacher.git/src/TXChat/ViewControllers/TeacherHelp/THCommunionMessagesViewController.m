//
//  THCommunionMessagesViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/10.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THCommunionMessagesViewController.h"
#import <MJRefresh.h>
#import "THQuestionListTableViewCell.h"
#import "THQuestionDetailViewController.h"
#import "THSpecialistInfoViewController.h"
#import "THAnswerDetailViewController.h"
#import "THGuideArticleDetailViewController.h"
#import "NSObject+EXTParams.h"

static NSString *const kCommunionMessageReadFlag = @"communion_isRead_";

@interface THCommunionMessagesViewController()
<UITableViewDelegate,
UITableViewDataSource>
{
    BOOL _isTopRefresh;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *communionList;
@end

@implementation THCommunionMessagesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleStr = @"消息详情";
    [self createCustomNavBar];
    [self setupMessagesTableView];
    [self setupRefreshView];
    _isTopRefresh = YES;
    [self.tableView.header beginRefreshing];
}
#pragma mark - UI视图创建
- (void)setupMessagesTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
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
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 网络请求
- (void)fetchCommunionMessagesWithMaxId:(int64_t)maxId
{
    [[TXChatClient sharedInstance].txJsbMansger fetchCommunionMessagesWithMaxId:maxId onCompleted:^(NSError *error, NSArray *communionMessages, BOOL hasMore) {
        if (_isTopRefresh) {
            [self.tableView.header endRefreshing];
        }else{
            [self.tableView.footer endRefreshing];
        }
        //处理数据
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            @synchronized(self.communionList) {
                NSMutableArray *list = [NSMutableArray array];
                [communionMessages enumerateObjectsUsingBlock:^(TXPBCommunionMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    SInt64 objId = obj.id;
                    BOOL isRead = [[TXChatClient sharedInstance].userManager querySettingBoolValueWithKey:[NSString stringWithFormat:@"%@%@",kCommunionMessageReadFlag,@(objId)] error:nil];
                    [obj setTXExtParams:@(isRead) forKey:@"isRead"];
                    [list addObject:obj];
                }];
                if (_isTopRefresh) {
                    self.communionList = [NSMutableArray arrayWithArray:list];
                }else{
                    [self.communionList addObjectsFromArray:list];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView.footer setHidden:!hasMore];
                //更新红点
                [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_JSB];
            });
        }
    }];
}
#pragma mark - 上拉刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    _isTopRefresh = YES;
    [self fetchCommunionMessagesWithMaxId:LLONG_MAX];
}
//上拉加载
- (void)footerRereshing
{
    _isTopRefresh = NO;
    TXPBCommunionMessage *msg = [_communionList lastObject];
    [self fetchCommunionMessagesWithMaxId:msg.id];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_communionList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TXPBCommunionMessage *message = _communionList[indexPath.row];
    return [THQuestionListTableViewCell heightForCellWithCommunion:message contentWidth:tableView.width_];
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
    TXPBCommunionMessage *message = _communionList[indexPath.row];
    cell.communionMessage = message;
    //读取已读状态
    cell.isRead = [[message extParamForKey:@"isRead"] boolValue];
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转
    TXPBCommunionMessage *message = _communionList[indexPath.row];
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    BOOL isTargetMe = NO;
    if (currentUser.userId == message.toUserId) {
        //针对我的操作
        isTargetMe = YES;
    }
    TXPBCommunionObjType objType = message.objType;
    switch (objType) {
        case TXPBCommunionObjTypeTQuestion: {
            //问题
            THQuestionDetailViewController *detailVc = [[THQuestionDetailViewController alloc] init];
            detailVc.pbQuestion = message.refQuestion;
            [self.navigationController pushViewController:detailVc animated:YES];
            break;
        }
        case TXPBCommunionObjTypeTKnowledge: {
            //宝典文章
            THGuideArticleDetailViewController *detailVc = [[THGuideArticleDetailViewController alloc] init];
            [self.navigationController pushViewController:detailVc animated:YES];
            break;
        }
        case TXPBCommunionObjTypeTExpert: {
            //专家
            THSpecialistInfoViewController *infoVc = [[THSpecialistInfoViewController alloc] init];
            [self.navigationController pushViewController:infoVc animated:YES];
            break;
        }
        case TXPBCommunionObjTypeTAnswer: {
            //答案
            THAnswerDetailViewController *detailVc = [[THAnswerDetailViewController alloc] init];
            detailVc.questionAnswer = message.refAnswer;
            [self.navigationController pushViewController:detailVc animated:YES];
            break;
        }
        default: {
            break;
        }
    }
    //设置是否已读
    SInt64 objId = message.id;
    [[TXChatClient sharedInstance].userManager saveSettingValue:@"1" forKey:[NSString stringWithFormat:@"%@%@",kCommunionMessageReadFlag,@(objId)] error:nil];
    [message setTXExtParams:@(YES) forKey:@"isRead"];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
@end
