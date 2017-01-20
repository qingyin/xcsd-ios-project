//
//  TXChatListViewController.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatListViewController.h"
#import "TXChatListTableViewCell.h"
#import "TXNetworkUnReachableViewController.h"
#import "NoNetworkViewController.h"
#import <MJRefresh.h>
#import <SDiPhoneVersion.h>

@interface TXChatListViewController ()
<UITableViewDelegate,
UITableViewDataSource>
{
    UIView *_noChatBackgroundView;
    UIButton *_networkStateView;
}
@end

@implementation TXChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commonSetup];
    [self createCustomNavBar];
    self.btnLeft.hidden = YES;
    [self setupChatListTableView];
    [self setupPullDownRefreshView];
}
#pragma mark - UI视图创建
- (void)commonSetup
{
    //取消iOS7上的insetEdge
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (void)setupChatListTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY - kTabBarHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 64;
    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        _tableView.rowHeight = 75;
    }
    [self.view addSubview:_tableView];
}
//集成刷新控件
- (void)setupPullDownRefreshView
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _tableView.header = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject triggleHeaderRefreshing];
    }];
}
- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [UIButton buttonWithType:UIButtonTypeCustom];
        _networkStateView.frame = CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 30);
        _networkStateView.backgroundColor = RGBCOLOR(0xff, 0xf6, 0xd8);
        [_networkStateView addTarget:self action:@selector(onNetworkStateViewClicked) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"noNetworkTip"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"当前网络不可用，请检查你的网络设置";
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}
//无列表时的效果图
- (UIView *)backgroundViewForNoChatList
{
    UIView *retView = [[UIView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY)];
    retView.backgroundColor = [UIColor clearColor];
    //添加logo视图
    UIImageView *noMsgLogoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54, 60)];
    noMsgLogoImageView.backgroundColor = [UIColor clearColor];
    noMsgLogoImageView.center = CGPointMake(CGRectGetWidth(retView.frame) / 2, CGRectGetHeight(retView.frame) / 2 - 30);
    noMsgLogoImageView.image = [UIImage imageNamed:@"logo_nomsg"];
    [retView addSubview:noMsgLogoImageView];
    //添加简介
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(noMsgLogoImageView.frame), CGRectGetWidth(retView.frame) - 40, 40)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.font = [UIFont systemFontOfSize:16];
    descriptionLabel.textColor = RGBCOLOR(202, 202, 202);
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.text = @"没有消息!";
    [retView addSubview:descriptionLabel];
    
    return retView;
}
#pragma mark - public
//设置网络状态是否显示
- (void)updateNetworkStateViewVisible:(NSNumber *)isVisible
{
    _tableView.tableHeaderView = [isVisible boolValue] ? [self networkStateView] : nil;
}
#pragma mark - 下拉刷新
- (void)triggleHeaderRefreshing
{
    //子类继承
}
- (void)endHeaderRefreshing
{
    [_tableView.header endRefreshing];
}
#pragma mark - 按钮点击操作
- (void)onNetworkStateViewClicked
{
    //进入到无网络连接提示界面
    NoNetworkViewController *networkVc = [[NoNetworkViewController alloc] init];
    [self.navigationController pushViewController:networkVc animated:YES];
}
#pragma mark - 刷新操作
//重新刷新视图
- (void)reloadChatList
{
    [_tableView reloadData];
    //添加无聊天列表时自定义背景图
    if ([_dataSource numberOfRowsInChatConversations] == 0) {
        if (!_noChatBackgroundView && [self backgroundViewForNoChatList]) {
            _noChatBackgroundView = [self backgroundViewForNoChatList];
            _noChatBackgroundView.frame = CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(_noChatBackgroundView.frame), CGRectGetHeight(_noChatBackgroundView.frame));
            [self.view addSubview:_noChatBackgroundView];
        }
    }else{
        if (_noChatBackgroundView) {
            [_noChatBackgroundView removeFromSuperview];
            _noChatBackgroundView = nil;
        }
    }
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource numberOfRowsInChatConversations];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    TXChatListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[TXChatListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify width:CGRectGetWidth(tableView.frame)];
        cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = nil;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    id<TXChatConversationData> item = [_dataSource conversationDataForItemAtIndexPath:indexPath];
    cell.conversationData = item;
    if (indexPath.row < [_dataSource numberOfRowsInChatConversations] && indexPath.row == [_dataSource numberOfRowsInChatConversations] - 1) {
        cell.isBottomCell = YES;
    }else{
        cell.isBottomCell = NO;
    }
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_dataSource canEditChatConversationsRowAtIndexPath:indexPath];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegate titleForDeleteConfirmationButtonForChatConversationsRowAtIndexPath:indexPath];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_dataSource && [_dataSource respondsToSelector:@selector(commitEditingStyle:forChatConversationsRowAtIndexPath:)]) {
        [_dataSource commitEditingStyle:editingStyle forChatConversationsRowAtIndexPath:indexPath];
    }
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //返回给代理类
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectChatConversationAtIndexPath:)]) {
        [_delegate didSelectChatConversationAtIndexPath:indexPath];
    }
}

@end
