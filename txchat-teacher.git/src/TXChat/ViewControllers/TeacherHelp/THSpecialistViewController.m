//
//  THSpecialistViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THSpecialistViewController.h"
#import "XLCycleScrollView.h"
#import "UIImageView+EMWebCache.h"
#import <MJRefresh.h>
#import "THSpecialistInfoViewController.h"
#import "THQuestionSelectTagViewController.h"
#import <TXChatCommon/KDCycleBannerView.h>

static NSInteger const kCellViewTag = 100;

@interface THSpecialistViewController ()
<KDCycleBannerViewDelegate,
KDCycleBannerViewDataource,
UITableViewDelegate,
UITableViewDataSource>
{
    BOOL _isTopRefresh;
    NSInteger _currentPage;
}
@property (nonatomic,strong) KDCycleBannerView *bannerScrollView;
@property (nonatomic,strong) UITableView *specialistTableView;
@property (nonatomic,strong) NSMutableArray *specialistArray;
@property (nonatomic,strong) NSMutableArray *bannerList;

@end

@implementation THSpecialistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"专家";
    _currentPage = 1;
    self.view.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
    [self createCustomNavBar];
    [self.btnRight setTitle:@"提问" forState:UIControlStateNormal];
    [self setupSpecialistViews];
    [self setupRefreshView];
    [self fetchBannerList];
    [self.specialistTableView.header beginRefreshing];
}
#pragma mark - UI视图创建
- (void)setupSpecialistViews{
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenWidth * 180/320;
    //顶部视图
    self.bannerScrollView = [[KDCycleBannerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.bannerScrollView.delegate = self;
    self.bannerScrollView.datasource = self;
    self.bannerScrollView.continuous = YES;
    self.bannerScrollView.autoPlayTimeInterval = 4.f;
    //TableView视图
    self.specialistTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY - kTabBarHeight) style:UITableViewStylePlain];
    self.specialistTableView.backgroundColor = [UIColor clearColor];
    self.specialistTableView.delegate = self;
    self.specialistTableView.dataSource = self;
    self.specialistTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.specialistTableView];
    //设置Header
    self.specialistTableView.tableHeaderView = self.bannerScrollView;
}
//集成刷新控件
- (void)setupRefreshView
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader = [MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    self.specialistTableView.header = gifHeader;
    self.specialistTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) self.specialistTableView.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}
#pragma mark - 按钮响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        THQuestionSelectTagViewController *vc = [[THQuestionSelectTagViewController alloc] init];
        vc.backVc = self.rdv_tabBarController;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - 获取网络数据
//获取顶部Banner列表
- (void)fetchBannerList
{
    [[TXChatClient sharedInstance].txJsbMansger fetchRecommendExpertsWithCompleted:^(NSError *error, NSArray *experts) {
        self.bannerList = [NSMutableArray arrayWithArray:experts];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.bannerList count] > 1) {
                self.bannerScrollView.continuous = YES;
            }else{
                self.bannerScrollView.continuous = NO;
            }
            [self.bannerScrollView reloadDataWithCompleteBlock:nil];
        });
    }];
}
//获取专家列表
- (void)fetchSpecialistData
{
    [[TXChatClient sharedInstance].txJsbMansger fetchExpertsWithPageNum:_isTopRefresh ? 1 : _currentPage onCompleted:^(NSError *error, NSArray *experts, BOOL hasMore) {
        //停止刷新
        if (_isTopRefresh) {
            [self.specialistTableView.header endRefreshing];
        }else{
            [self.specialistTableView.footer endRefreshing];
        }
        //处理数据
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            @synchronized(self.specialistArray) {
                if (_isTopRefresh) {
                    self.specialistArray = [NSMutableArray arrayWithArray:experts];
                    _currentPage = 2;
                }else{
                    [self.specialistArray addObjectsFromArray:experts];
                    _currentPage += 1;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.specialistTableView reloadData];
                [self.specialistTableView.footer setHidden:!hasMore];
            });
        }
    }];
}
#pragma mark - 上拉刷新下拉刷新
//下拉刷新
- (void)headerRereshing
{
    _isTopRefresh = YES;
    [self fetchSpecialistData];
}
//上拉加载
- (void)footerRereshing
{
    _isTopRefresh = NO;
    [self fetchSpecialistData];
}
#pragma mark - VC跳转
- (void)pushToInfoViewControllerWithUserInfo:(TXPBExpert *)userInfo
{
    THSpecialistInfoViewController *infoVc = [[THSpecialistInfoViewController alloc] init];
    infoVc.expertInfo = userInfo;
    [self.navigationController pushViewController:infoVc animated:YES];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_specialistArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initLineWithFrame:CGRectMake(0, 0, tableView.width_, 5.0f)];
    header.backgroundColor = kColorClear;
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        //背景图
        UIView *contentBgView = [[UIView alloc] init];
        contentBgView.backgroundColor = [UIColor whiteColor];
        contentBgView.tag = kCellViewTag + 1;
        [cell.contentView addSubview:contentBgView];
        //头像
        UIImageView *avatarImageView = [[UIImageView alloc] init];
        avatarImageView.backgroundColor = kColorCircleBg;
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        avatarImageView.clipsToBounds = YES;
        avatarImageView.tag = kCellViewTag + 2;
        [cell.contentView addSubview:avatarImageView];
        //姓名
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = kFontMiddle_b;
        nameLabel.textColor = KColorTitleTxt;
        nameLabel.tag = kCellViewTag + 3;
        [cell.contentView addSubview:nameLabel];
        //职位
        UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        positionLabel.backgroundColor = [UIColor clearColor];
        positionLabel.font = kFontChildSection;
        positionLabel.textColor = RGBCOLOR(0x75, 0x75, 0x75);
        positionLabel.tag = kCellViewTag + 4;
        [cell.contentView addSubview:positionLabel];
        //简介
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.font = kFontMiddle;
        descLabel.textColor = RGBCOLOR(0x4a, 0x4a, 0x4a);
        descLabel.numberOfLines = 2;
        descLabel.tag = kCellViewTag + 5;
        [cell.contentView addSubview:descLabel];
       //设置排版
        [contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(5);
            make.top.equalTo(cell.contentView).offset(0);
            make.right.equalTo(cell.contentView).offset(-5);
            make.bottom.equalTo(cell.contentView);
        }];
        [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cell.contentView).offset(5);
            make.top.equalTo(cell.contentView).offset(0);
            make.bottom.equalTo(cell.contentView);
            make.height.equalTo(avatarImageView.mas_width);
        }];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(avatarImageView.mas_right).offset(10);
            make.top.equalTo(avatarImageView).offset(10);
        }];
        [positionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel.mas_right).offset(5);
            make.bottom.equalTo(nameLabel);
            make.right.equalTo(cell.contentView).offset(-10);
        }];
        [descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(nameLabel);
            make.top.equalTo(nameLabel.mas_bottom).offset(10);
            make.right.equalTo(cell.contentView).offset(-10);
        }];
        //设置名称的Hugging优先级,让positionLabel紧贴着nameLabel排版
        [nameLabel setContentHuggingPriority:UILayoutPriorityRequired
                                   forAxis:UILayoutConstraintAxisHorizontal];
    }
    //设置数据
    TXPBExpert *dict = _specialistArray[indexPath.section];
    UIImageView *avatarImageView = (UIImageView *)[cell.contentView viewWithTag:kCellViewTag + 2];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:kCellViewTag + 3];
    UILabel *positionLabel = (UILabel *)[cell.contentView viewWithTag:kCellViewTag + 4];
    UILabel *descLabel = (UILabel *)[cell.contentView viewWithTag:kCellViewTag + 5];
    NSString *formatAvatarString = [dict.avatar getFormatPhotoUrl:180 hight:180];
    [avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatAvatarString] placeholderImage:[UIImage imageNamed:@"jsb_specialdefault"]];
    nameLabel.text = dict.name;
    positionLabel.text = dict.title;
//    NSMutableString *specialities = [NSMutableString string];
//    for (int i = 0; i < [dict.specialities count]; i++) {
//        TXPBTag *tag = dict.specialities[i];
//        [specialities appendString:tag.name];
//        if (i != [dict.specialities count] - 1) {
//            [specialities appendString:@","];
//        }
//    }
//    descLabel.text = specialities;
    descLabel.text = dict.pb_description;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转
    TXPBExpert *expert = _specialistArray[indexPath.section];
    [self pushToInfoViewControllerWithUserInfo:expert];
}
#pragma mark - KDCycleBannerViewDataource methods
- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView
{
    return _bannerList;
}
- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    return UIViewContentModeScaleAspectFill;
}
//- (UIImage *)placeHolderImageOfZeroBannerView {
//    return [UIImage imageNamed:@"zj_banner"];
//}
- (UIImage *)placeHolderImageOfBannerView:(KDCycleBannerView *)bannerView atIndex:(NSUInteger)index
{
    return [UIImage imageNamed:@"zj_banner"];
}
- (id)imageSourceForContent:(id)content
{
    TXPBExpert *expert = (TXPBExpert *)content;
    NSString *urlString = expert.rankBanner;
    return urlString;
}
#pragma mark - KDCycleBannerViewDelegate methods
- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    TXPBExpert *expert = _bannerList[index];
    [self pushToInfoViewControllerWithUserInfo:expert];
}

@end
