 //
//  PublishmentListViewController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "PublishmentListViewController.h"
#import "PublishmentListTableViewCell.h"
#import "HomePublishmentEntity.h"
#import "PublishmentDetailViewController.h"
#import <MJRefresh.h>

@interface PublishmentListViewController ()
<UITableViewDelegate,
UITableViewDataSource>
{
    UITableView *_tableView;
    BOOL _isTopRefresh;
}
@property (nonatomic) TXHomePostType postType;
@property (nonatomic,strong) NSMutableArray *listArray;
@end

@implementation PublishmentListViewController

- (instancetype)initWithPostType:(TXHomePostType)type
{
    self = [super init];
    if (self) {
        _postType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    [self setupPublishmentListView];
    [self setupRefreshView];
    self.listArray = [NSMutableArray array];
    [self fetchLocalPostListWithMaxId:LLONG_MAX];
    [_tableView.header beginRefreshing];
}
#pragma mark - UI视图创建
- (void)setupPublishmentListView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}
//集成刷新控件
- (void)setupRefreshView
{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    
    MJTXRefreshGifHeader *gifHeader =[MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _tableView.header = gifHeader;
    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    //    [self setTitle:MJRefreshAutoFooterIdleText forState:MJRefreshStateIdle];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) _tableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
    
}
#pragma mark - 按钮响应
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 上啦刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    _isTopRefresh = YES;
    [self fetchPublishmentListWithMaxId:LLONG_MAX];
}
//上拉加载
- (void)footerRereshing
{
    _isTopRefresh = NO;
    HomePublishmentEntity *entity = [_listArray lastObject];
    [self fetchPublishmentListWithMaxId:entity.postId];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_listArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    PublishmentListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[PublishmentListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify cellWidth:CGRectGetWidth(tableView.frame)];
        cell.backgroundColor = [UIColor whiteColor];
        cell.backgroundView = nil;
    }
    if (indexPath.row < [_listArray count]) {
        cell.entity = _listArray[indexPath.row];
    }
    
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row < [_listArray count]) {
//        HomePublishmentEntity *entity = _listArray[indexPath.row];
//        return entity.rowHeight;
//    }
    return 94;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击跳转
    HomePublishmentEntity *entity = _listArray[indexPath.row];
    PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:entity.postUrl];
    detailVc.postType = _postType;
    [self.navigationController pushViewController:detailVc animated:YES];
    //设置已读状态
    entity.isRead = YES;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
#pragma mark - 网络请求
- (void)fetchPublishmentListWithMaxId:(int64_t)maxId
{
    NSError *userError = nil;
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:&userError];
    if (userError) {
        DDLogDebug(@"获取postType:%@ 当前userError:%@",@(_postType),userError);
        return;
    }
    [[TXChatClient sharedInstance] fetchPosts:maxId gardenId:currentUser.gardenId postType:(TXPBPostType)_postType onCompleted:^(NSError *error, NSArray *posts, BOOL hasMore) {
//        NSLog(@"error:%@",error);
//        NSLog(@"posts:%@",posts);
//        NSLog(@"hasMore:%@",hasMore ? @"是" : @"否");
        if (error) {
            [self showFailedHudWithError:error];
            DDLogDebug(@"获取postType:%@ 请求error:%@",@(_postType),error);
            if (_isTopRefresh) {
                [_tableView.header endRefreshing];
            }else{
                [_tableView.footer endRefreshing];
            }
            //刷新列表信息
            BOOL isEmpty = [_listArray count] > 0 ? NO : YES;
            [self updateEmptyDataImageStatus:isEmpty];
        }else{
            //处理数据并刷新列表
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (_isTopRefresh) {
                    self.listArray = [NSMutableArray array];
                }
                for (NSInteger i = 0; i < [posts count]; i++) {
                    HomePublishmentEntity *entity = [[HomePublishmentEntity alloc] initWithPBPost:posts[i]];
                    if (_postType == TXHomePostType_Announcement) {
                        entity.isHideImage = YES;
                    }
                    if (entity) {
                        [_listArray addObject:entity];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    //刷新列表
                    [_tableView reloadData];
                    if (_isTopRefresh) {
                        [_tableView.header endRefreshing];
                    }else{
                        [_tableView.footer endRefreshing];
                    }
                    [_tableView.footer setHidden:!hasMore];
                    //刷新列表信息
                    BOOL isEmpty = [_listArray count] > 0 ? NO : YES;
                    [self updateEmptyDataImageStatus:isEmpty];
                });
            });
        }

    }];
}
//获取本地数据
- (void)fetchLocalPostListWithMaxId:(int64_t)maxId
{
    DDLogDebug(@"getPosts");
    NSError *error = nil;
    NSArray *posts = [[TXChatClient sharedInstance] getPosts:(TXPBPostType)_postType maxPostId:maxId count:20 error:&error];
//    NSLog(@"本地list:%@",posts);
    if (error) {
        DDLogDebug(@"获取postType:%@ 请求error:%@",@(_postType),error);
        if (_isTopRefresh) {
            [_tableView.header endRefreshing];
        }else{
            [_tableView.footer endRefreshing];
        }
        [self addEmptyDataImage:NO showMessage:@"暂无信息"];
        [self updateEmptyDataImageStatus:YES];
    }else{
        //处理数据并刷新列表
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (_isTopRefresh) {
                self.listArray = [NSMutableArray array];
            }
            for (NSInteger i = 0; i < [posts count]; i++) {
                HomePublishmentEntity *entity = [[HomePublishmentEntity alloc] initWithPBPost:posts[i]];
                if (_postType == TXHomePostType_Announcement) {
                    entity.isHideImage = YES;
                }
                if (entity) {
                    [_listArray addObject:entity];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //刷新列表
                [_tableView reloadData];
                if (_isTopRefresh) {
                    [_tableView.header endRefreshing];
                }else{
                    [_tableView.footer endRefreshing];
                }
//                [_tableView.footer setHidden:YES];
                //刷新列表信息
                BOOL isEmpty = [_listArray count] > 0 ? NO : YES;
                if (isEmpty) {
                    [self addEmptyDataImage:NO showMessage:@"暂无信息"];
                }
                [self updateEmptyDataImageStatus:isEmpty];
                //根据红点判断是否需要刷新加载数据
                if (_postType == TXHomePostType_Activity) {
                    //活动
                    NSDictionary *dict = [self countValueForType:TXClientCountType_Activity];
                    NSInteger activityValue = [dict[TXClientCountNewValueKey] integerValue];
                    if (activityValue > 0 || [_listArray count] == 0) {
                        [_tableView.header beginRefreshing];
                    }
                    [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_ACTIVITY];
                }else if (_postType == TXHomePostType_Announcement) {
                    //公告
                    NSDictionary *dict = [self countValueForType:TXClientCountType_Announcement];
                    NSInteger announcementValue = [dict[TXClientCountNewValueKey] integerValue];
                    if (announcementValue > 0 || [_listArray count] == 0) {
                        [_tableView.header beginRefreshing];
                    }
                    [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_ANNOUNCEMENT];
                }
            });
        });
    }
}
@end
