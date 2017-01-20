//
//  CircleNewCommentsViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/21.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleNewCommentsViewController.h"
#import "MJRefresh.h"
#import "UIImageView+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "CircleDetailViewController.h"
#import "NSDate+TuXing.h"
#import "UILabel+ContentSize.h"

#define kContentBaseTag         231231

@interface CircleNewCommentsViewController ()<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) NSMutableArray *feedsArr;
@property (nonatomic, assign) BOOL isRefresh;

@end

@implementation CircleNewCommentsViewController

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:NOTIFY_UPDATE_CIRCLE object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshList:(NSNotification *)notification{
    if (!_isRefresh) {
        [_listArr removeAllObjects];
        [self fetchCommentsToMe:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.titleStr = @"消息列表";
    [self createCustomNavBar];
    
    self.listArr = [NSMutableArray array];
    self.feedsArr = [NSMutableArray array];
    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.customNavigationView.maxY,self.view.width_ ,self.view.height_
                                                                   - self.customNavigationView.maxY) style:UITableViewStylePlain];
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.showsVerticalScrollIndicator = YES;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    // 2.集成刷新控件
    [self setupRefresh];

    if (!_isRefresh) {
        [self fetchCommentsToMe:YES];
    }
}

/**
 *  创建上拉刷新
 */
- (void)setupRefresh{
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    _listTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    _listTableView.footer.hidden = YES;
    [_listTableView.footer noticeNoMoreData];
}

/**
 *  上拉刷新
 */
- (void)footerRereshing{
    [self fetchCommentsToMe:NO];
}

/**
 *  创建顶部导航条
 */
- (void)createCustomNavBar{
    [super createCustomNavBar];
//    [self.btnRight setTitle:@"清空" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
    }
}

/**
 *  获取消息列表
 */
- (void)fetchCommentsToMe:(BOOL)isHeader{
    
    _isRefresh = YES;
    TXComment *comment = nil;
    if (_listArr.count && !isHeader) {
        comment = [_listArr lastObject];
    }
    DDLogDebug(@"fetchCommentsToMe");
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    [[TXChatClient sharedInstance] fetchCommentsToMe:comment?comment.commentId:LLONG_MAX onCompleted:^(NSError *error, NSArray *comments, NSArray *txFeeds, BOOL hasMore) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        [tmpObject.listTableView.footer endRefreshing];
        if (error) {
            tmpObject.listTableView.footer.hidden = YES;
            [tmpObject.listTableView.footer noticeNoMoreData];
            [tmpObject showFailedHudWithError:error];
        }else{
            if (isHeader) {
                [_listArr removeAllObjects];
            }
            [tmpObject.listArr addObjectsFromArray:comments];
            [tmpObject.feedsArr addObjectsFromArray:txFeeds];
            [tmpObject.listTableView reloadData];

            if (!hasMore) {
                tmpObject.listTableView.footer.hidden = YES;
                [tmpObject.listTableView.footer noticeNoMoreData];
            }else{
                tmpObject.listTableView.footer.hidden = NO;
                [tmpObject.listTableView.footer resetNoMoreData];
            }
        }
        tmpObject.isRefresh = NO;
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _listArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getCellHeight:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        BOOL isPlus = SDiPhoneVersion.deviceSize ==iPhone55inch?YES:NO;
        UIImageView *portraitImgView = [[UIImageView alloc] init];
        portraitImgView.layer.cornerRadius = isPlus?6:4;
        portraitImgView.layer.masksToBounds = YES;
        portraitImgView.frame = CGRectMake(10, 13, 40, 40);
        portraitImgView.tag = kContentBaseTag;
        [cell.contentView addSubview:portraitImgView];
        
        UILabel *nameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        nameLb.backgroundColor = kColorClear;
        nameLb.font = kFontMiddle;
        nameLb.textColor = kColorGray1;
        nameLb.textAlignment = NSTextAlignmentLeft;
        nameLb.tag = kContentBaseTag + 1;
        [cell.contentView addSubview:nameLb];
        
        UIImageView *likeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(portraitImgView.maxX + 10, portraitImgView.maxY - 15, 12, 12)];
        likeImgView.image = [UIImage imageNamed:@"circle_like"];
        likeImgView.tag = kContentBaseTag + 2;
        [cell.contentView addSubview:likeImgView];
        
        UILabel *commentLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        commentLb.textAlignment = NSTextAlignmentLeft;
        commentLb.textColor = kColorBlack;
        commentLb.numberOfLines = 0;
        commentLb.font = kFontMiddle;
        commentLb.tag = kContentBaseTag + 3;
        [cell.contentView addSubview:commentLb];
        
        UIImageView *contentImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 65, 12, 55, 55)];
        contentImgView.tag = kContentBaseTag + 4;
        [cell.contentView addSubview:contentImgView];
        
        UILabel *contentLb = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 65, 12, 55, 55)];
        contentLb.numberOfLines = 0;
        contentLb.font = kFontSmall;
        contentLb.textColor = kColorBlack;
        contentLb.textAlignment = NSTextAlignmentLeft;
        contentLb.tag = kContentBaseTag + 5;
        contentLb.lineBreakMode = NSLineBreakByTruncatingTail;
        [cell.contentView addSubview:contentLb];
        
        UILabel *timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        timeLb.font = kFontMini;
        timeLb.textColor = kColorGray;
        timeLb.textAlignment = NSTextAlignmentLeft;
        timeLb.tag = kContentBaseTag + 7;
        [cell.contentView addSubview:timeLb];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
        lineView.tag = kContentBaseTag + 6;
        [cell.contentView addSubview:lineView];
    }
    
    UIImageView *portraitImgView  = (UIImageView *)[cell.contentView viewWithTag:kContentBaseTag];
    UILabel *nameLb = (UILabel *)[cell.contentView viewWithTag:kContentBaseTag + 1];
    UIImageView *likeImgView = (UIImageView *)[cell.contentView viewWithTag:kContentBaseTag + 2];
    UILabel *commentLb = (UILabel *)[cell.contentView viewWithTag:kContentBaseTag + 3];
    UIImageView *contentImgView = (UIImageView *)[cell.contentView viewWithTag:kContentBaseTag + 4];
    UILabel *contentLb = (UILabel *)[cell.contentView viewWithTag:kContentBaseTag + 5];
    UIView *lineView = (UIView *)[cell.contentView viewWithTag:kContentBaseTag + 6];
    UILabel *timeLb = (UILabel *)[cell.contentView viewWithTag:kContentBaseTag + 7];
    
    TXComment *comment = _listArr[indexPath.row];
    //头像
    [portraitImgView TX_setImageWithURL:[NSURL URLWithString:[comment.userAvatarUrl getFormatPhotoUrl:40 hight:40]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    
    nameLb.text = comment.userNickname;
    [nameLb sizeToFit];
    nameLb.frame = CGRectMake(portraitImgView.maxX + 10, portraitImgView.minY + 1, nameLb.width_, nameLb.height_);
    timeLb.text = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(comment.createdOn/1000)]];
    [timeLb sizeToFit];
    
    if (comment.commentType == TXPBCommentTypeLike) {
        commentLb.hidden = YES;
        likeImgView.hidden = NO;
        timeLb.frame = CGRectMake(nameLb.minX, likeImgView.maxY + 10, timeLb.width_, timeLb.height_);
    }else{
        commentLb.hidden = NO;
        likeImgView.hidden = YES;
        commentLb.text = comment.content;
        CGSize size = [commentLb sizeThatFits:CGSizeMake(kScreenWidth - 10 - 55 - 12 - nameLb.minX, MAXFLOAT)];
        
        commentLb.frame = CGRectMake(portraitImgView.maxX + 10, portraitImgView.maxY - 1 - nameLb.height_, size.width, size.height);
        timeLb.frame = CGRectMake(nameLb.minX, commentLb.maxY + 10, timeLb.width_, timeLb.height_);
    }
    
    lineView.frame = CGRectMake(0, timeLb.maxY + 12, kScreenWidth, kLineHeight);
    
    
    TXFeed *feed = _feedsArr[indexPath.row];
    
    if (feed.attaches.count) {
        contentImgView.hidden = NO;
        contentLb.hidden = YES;
        TXPBAttach *attch = feed.attaches[0];
        NSString *imgStr;
        if (attch.attachType == TXPBAttachTypePic) {
            imgStr = [attch.fileurl getFormatPhotoUrl:55 hight:55];
        }else{
            imgStr = [attch.fileurl getFormatVideoUrl:55 hight:55];
        }
        contentImgView.backgroundColor = kColorCircleBg;
        [contentImgView TX_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                contentImgView.image = [UIImage imageNamed:@"tp_148x148"];
            }
        }];
        if (attch.attachType == TXPBAttachTypeVedio) {
            //视频半透视图
            UIView *playBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentImgView.frame.size.width, contentImgView.frame.size.height)];
            playBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
            playBgView.userInteractionEnabled = NO;
            [contentImgView addSubview:playBgView];
            //视频播放视图
            UIImageView *playVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            playVideoView.center = CGPointMake(contentImgView.frame.size.width / 2, contentImgView.frame.size.width / 2);
            playVideoView.backgroundColor = [UIColor clearColor];
            playVideoView.image = [UIImage imageNamed:@"chat_video_play"];
            [contentImgView addSubview:playVideoView];
        }else{
            [contentImgView removeAllSubviews];
        }

    }else{
        contentImgView.hidden = YES;
        contentLb.hidden = NO;
        contentLb.text = feed.content;
        CGSize size = [contentLb sizeThatFits:CGSizeMake(55, 55)];
        if (size.height > 55) {
            contentLb.frame = CGRectMake(kScreenWidth - 65, 12, 55, 55);
        }else{
            contentLb.frame = CGRectMake(kScreenWidth - 65, 12, 55, size.height);
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CircleDetailViewController *avc = [[CircleDetailViewController alloc] init];
    avc.feed = _feedsArr[indexPath.row];
    avc.presentVC = self;
    [self.navigationController pushViewController:avc animated:YES];

}

- (CGFloat)getCellHeight:(NSIndexPath *)indexPath{
    TXComment *comment = _listArr[indexPath.row];
    CGSize nameSize = [UILabel contentSizeForLabelWithText:comment.userNickname maxWidth:MAXFLOAT font:kFontMiddle];
    CGFloat height = 0;
    CGSize size = [UILabel contentSizeForLabelWithText:[NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(comment.createdOn/1000)]] maxWidth:MAXFLOAT font:kFontMini];
    if (comment.commentType == TXPBCommentTypeLike) {
        height += (13 + 10 + size.height + 38);
    }else{
        CGSize commentSize = [UILabel contentSizeForLabelWithText:comment.content maxWidth:kScreenWidth - 10 - 55 - 12 - 60 font:kFontMiddle];
        height = 12 + 40 - 1 - nameSize.height + 10 + size.height + commentSize.height;
    }
    return height + 13;
}


@end
