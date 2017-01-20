//
//  CircleHomeViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleHomeViewController.h"
#import "MJRefresh.h"
#import "CircleListHeaderCell1.h"
#import "NSDate+TuXing.h"
#import "CircleHomeCell.h"
#import "TXFeed+Circle.h"
#import "CircleNewCommentsViewController.h"

typedef enum : NSUInteger {
    RequestType_None = 0,
    RequestType_Header,
    RequestType_Footer,
} RequestType;


#define kHomeCellIdentifier             @"homeCellIdentifier"
#define kHeaderCellIdentifier           @"headerCellIdentifier"

@interface CircleHomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) RequestType type;
@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, strong) NSMutableArray *tmpListArr;
@property (nonatomic, assign) BOOL hasMore;

@end

@implementation CircleHomeViewController

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshList:) name:NOTIFY_UPDATE_CIRCLE object:nil];
    }
    return self;
}

- (void)onRefreshList:(NSNotification *)notification{
    self.type = RequestType_Header;
    [self fetchFeeds];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.titleStr = @"亲子圈";
    if (_nickName && [_nickName length]) {
        self.titleStr = _nickName;
    }
    self.umengEventText = @"用户亲子圈列表";
    [self createCustomNavBar];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.customNavigationView.maxY,self.view.width_ ,self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    [_listTableView registerClass:[CircleHomeCell class] forCellReuseIdentifier:kHomeCellIdentifier];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.showsVerticalScrollIndicator = YES;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    
    [self setupRefresh];
    //获取历史数据
    [self getFeeds];
    self.type = RequestType_Header;
    [_listTableView.header beginRefreshing];
}

//集成刷新控件
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader =[MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    _listTableView.header = gifHeader;
    _listTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
}

- (void)headerRereshing{
    self.type = RequestType_Header;
    [self fetchFeeds];
}

- (void)footerRereshing{
    self.type = RequestType_Footer;
    [self fetchFeeds];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (_userId == user.userId) {
        [self.btnRight setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    }
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED_COMMENT];
        CircleNewCommentsViewController *commentsVC = [[CircleNewCommentsViewController alloc] init];
        [self.navigationController pushViewController:commentsVC animated:YES];
    }
}

#pragma mark - 亲子圈数据请求
//获取历史数据
- (void)getFeeds{
    self.listArr = [NSMutableArray arrayWithArray:[[TXChatClient sharedInstance] getFeeds:LLONG_MAX count:20 userId:_userId error:nil]];
    [self manageData:_listArr];
    [self reloadData];
    if (_listArr.count < 20) {
        _listTableView.footer.hidden = YES;
        [_listTableView.footer noticeNoMoreData];
    }
}

- (void)manageData:(NSArray *)arr{
    NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:arr];
    self.dataArr = [NSMutableArray array];
    while ([tmpArr count]) {
        TXFeed *feed = [tmpArr objectAtIndex:0];
        
        feed.hasMore = [NSNumber numberWithBool:feed.hasMoreComment];
        
        NSString *createOn = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@", @(feed.createdOn/1000)]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date=[formatter dateFromString:createOn];
        NSTimeInterval timeStamp = [date timeIntervalSince1970];
        NSTimeInterval endTimeStamp = timeStamp + (60 * 60 * 24);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K BETWEEN {%llf,%llf}",@"createdOn",timeStamp * 1000,endTimeStamp * 1000];
        NSArray *arr1 = [tmpArr filteredArrayUsingPredicate:predicate];
        NSMutableArray *newFeedArr = [NSMutableArray array];
        for (TXFeed *tmpFeed in arr1) {
            [newFeedArr addObject:tmpFeed];
        }
        if ([date isToday]) {
            self.todayArr = newFeedArr;
        }else{
            [_dataArr addObject:newFeedArr];
        }
        [tmpArr removeObjectsInArray:arr1];
    }
}
- (void)fetchFeeds{
    __weak typeof(self)tmpObject = self;
    TXFeed *feed = nil;
    if (_type == RequestType_Footer) {
        feed = [_listArr lastObject];
        if (!feed) {
            [_listTableView.footer endRefreshing];
            return;
        }
    }
    DDLogDebug(@"fetchFeeds");
    [[TXChatClient sharedInstance] fetchFeeds:_type == RequestType_Header?LLONG_MAX:feed.feedId userId:_userId onCompleted:^(NSError *error, NSArray *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore) {
        if (error) {
            [tmpObject.listTableView.header endRefreshing];
            [tmpObject.listTableView.footer endRefreshing];
            tmpObject.listTableView.footer.hidden = YES;
            [tmpObject.listTableView.footer noticeNoMoreData];
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            NSMutableArray *arr = [NSMutableArray array];
            [feeds enumerateObjectsUsingBlock:^(TXFeed *feed, NSUInteger idx, BOOL *stop) {
                feed.hasMore = [NSNumber numberWithBool:feed.hasMoreComment];
                feed.circleLikes = [NSMutableArray arrayWithArray:txLikesDictionary[@(feed.feedId)]];
                feed.circleComments = [NSMutableArray arrayWithArray:txCommentsDictionary[@(feed.feedId)]];
                [arr addObject:feed];
            }];
            tmpObject.tmpListArr = [NSMutableArray arrayWithArray:arr];
            tmpObject.hasMore = hasMore;
            
            if (!feeds.count) {
                [tmpObject.listTableView.header endRefreshing];
                [tmpObject.listTableView.footer endRefreshing];
            }
            
            if (!tmpObject.isScrolling) {
                if (tmpObject.type == RequestType_Header) {
                    tmpObject.listArr = [NSMutableArray arrayWithArray:tmpObject.tmpListArr];
                    [tmpObject manageData:_listArr];
                }else if (tmpObject.type == RequestType_Footer){
                    [tmpObject.listArr addObjectsFromArray:tmpObject.tmpListArr];
                    [tmpObject manageData:_listArr];
                }
                tmpObject.type = RequestType_None;
                [tmpObject reloadData];
            }
        }
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return _dataArr.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [CircleListHeaderCell1 GetHeaderCellHeight:NO];
    }else{
        if (indexPath.row == 0) {
            return [CircleHomeCell GetHomeCellHeight:_todayArr andIsToday:YES andUserId:_userId];
        }else{
            return [CircleHomeCell GetHomeCellHeight:[_dataArr objectAtIndex:indexPath.row - 1] andIsToday:NO andUserId:_userId];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = kHeaderCellIdentifier;
        CircleListHeaderCell1 *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[CircleListHeaderCell1 alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.newsBtn.hidden = YES;
        cell.backgroundColor = kColorWhite;
        cell.contentView.backgroundColor = kColorWhite;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.listVC = self;
        [cell setPortrait:_portraitUrl andNickname:_nickName];
        return cell;
    }else{
        static NSString *CellIdentifier = kHomeCellIdentifier;
        CircleHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[CircleHomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.backgroundColor = kColorWhite;
        cell.contentView.backgroundColor = kColorWhite;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.homeVC = self;
        if (indexPath.row == 0) {
            cell.isToday = YES;
            [cell setCellContent:_todayArr andUserId:_userId];
        }else{
            cell.isToday = NO;
            [cell setCellContent:[_dataArr objectAtIndex:indexPath.row - 1] andUserId:_userId];
        }
        return cell;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIScrollView Delegate
- (void)reloadData{
    [_listTableView reloadData];
    [_listTableView.header endRefreshing];
    [_listTableView.footer endRefreshing];
    self.tmpListArr = [NSMutableArray array];
    if (!_hasMore) {
        _listTableView.footer.hidden = YES;
        [_listTableView.footer noticeNoMoreData];
    }else{
        _listTableView.footer.hidden = NO;
        [_listTableView.footer resetNoMoreData];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.isScrolling = NO;
        if (_type == RequestType_Header && _tmpListArr.count) {
            self.type = RequestType_None;
            self.listArr = [NSMutableArray arrayWithArray:_tmpListArr];
            [self manageData:_listArr];
            [self reloadData];
        }else if (_type == RequestType_Footer && _tmpListArr.count){
            self.type = RequestType_None;
            [_listArr addObjectsFromArray:_tmpListArr];
            [self manageData:_listArr];
            [self reloadData];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.isScrolling = NO;
    if (_type == RequestType_Header && _tmpListArr.count) {
        self.listArr = [NSMutableArray arrayWithArray:_tmpListArr];
        [self manageData:_listArr];
        [self reloadData];
    }else if (_type == RequestType_Footer && _tmpListArr.count){
        [_listArr addObjectsFromArray:_tmpListArr];
        [self manageData:_listArr];
        [self reloadData];
    }
}


@end
