//
//  FoundViewController.m
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import "FoundViewController.h"
#import "CircleListViewController.h"
#import "FoundWebViewController.h"
#import "UILabel+ContentSize.h"
#import "TXSystemManager.h"
#import "CustomTabBarController.h"
#import "THQuestionListViewController.h"
#import "THGuideViewController.h"
#import "THSpecialistViewController.h"
#import "THMineViewController.h"
#import "BroadcastInfoViewController.h"
#import "TXClassroomListViewController.h"
#import "WXYListViewController.h"

#define kCellContentViewBaseTag                     1212121

@interface FoundViewController ()
<UITableViewDelegate,
UITableViewDataSource>
{
    UITableView *_listTableView;
}

@property (nonatomic, strong) NSArray *listArr;

@end

@implementation FoundViewController

- (void)dealloc
{
    [self unSubscribeAll];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"发现";
    [self createCustomNavBar];
    
//    _listArr = @[@{@"title":@"亲子圈",@"img":@"fx-qzq",@"type":@(FoundType_Circle)},
//                 @{@"title":@"活动专区",@"img":@"fx-hd",@"type":@(FoundType_Event)},
//                 @{@"title":@"微豆商城",@"img":@"fx-jf",@"type":@(FoundType_Shop)},
//                 @{@"title":@"教师成长",@"img":@"fx_jsb",@"type":@(FoundType_TeacherHelp)}];
    
    _listArr = @[@{@"title":@"亲子圈",@"img":@"fx-qzq",@"type":@(FoundType_Circle)},
                  @{@"title":@"理解孩子",@"img":@"fx-wjy",@"type":@(FoundType_WeiXueYuan)},
//                 @{@"title":@"云课堂",@"img":@"fx-wkt",@"type":@(FoundType_ClassBroadcast)}
//                 @{@"title":@"教师成长",@"img":@"fx_jsb",@"type":@(FoundType_TeacherHelp)}
//                 @{@"title":@"活动专区",@"img":@"fx-hd",@"type":@(FoundType_Event)},
//                 @{@"title":@"微豆商城",@"img":@"fx-jf",@"type":@(FoundType_Shop)}
                 ];

    
    _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY - kTabBarHeight) style:UITableViewStylePlain];
    _listTableView.backgroundColor = kColorBackground;
    _listTableView.showsHorizontalScrollIndicator = NO;
    _listTableView.showsVerticalScrollIndicator = NO;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.bounces = NO;
    [self.view addSubview:_listTableView];
    // Do any additional setup after loading the view.
    //处理亲子圈的红点
    [self subscribeMultipleCountTypes:@[@(TXClientCountType_Feed),@(TXClientCountType_FeedComment)] refreshBlock:^(NSArray *values) {
        //        NSLog(@"亲子圈values:%@",values);
        [_listTableView reloadData];
    } invokeNow:NO];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //刷新视图
    [_listTableView reloadData];
}
//判断是否有红点
- (BOOL)isHasNewDotForType:(FoundType)type
{
    if (type == FoundType_Circle) {
        //亲子圈
        NSDictionary *feedDict = [self countValueForType:TXClientCountType_Feed];
        if (feedDict[TXClientCountNewValueKey]) {
            NSInteger feedCount = [feedDict[TXClientCountNewValueKey] integerValue];
            if (feedCount) {
                return YES;
            }
        }
        NSDictionary *feedCommentDict = [self countValueForType:TXClientCountType_FeedComment];
        if (feedCommentDict[TXClientCountNewValueKey]) {
            NSInteger feedCommentCount = [feedCommentDict[TXClientCountNewValueKey] integerValue];
            if (feedCommentCount) {
                return YES;
            }
        }
    }
    return NO;
}
#pragma mark - UITableView delegate and dataSource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _listArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width_, 10.f  * kScale)];
    view.backgroundColor = kColorClear;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10  * kScale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *Identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = kColorWhite;
        cell.backgroundColor = kColorWhite;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //icon
        UIImageView *iconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 12, 21, 21)];
        iconImgView.backgroundColor = kColorClear;
        iconImgView.tag = kCellContentViewBaseTag;
        [cell.contentView addSubview:iconImgView];
        //标题
        UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(iconImgView.maxX + 16, 0, 150, 45)];
        titleLb.font = kFontMiddle;
        titleLb.textAlignment = NSTextAlignmentLeft;
        titleLb.textColor = kColorBlack;
        titleLb.tag = kCellContentViewBaseTag + 1;
        [cell.contentView addSubview:titleLb];
        //红点
        UIImageView *dotImgView = [[UIImageView alloc] initWithFrame:CGRectMake(160, 18, 9, 9)];
        dotImgView.backgroundColor = [UIColor clearColor];
        dotImgView.image = [UIImage imageNamed:@"unread_background"];
//        dotImgView.layer.cornerRadius = 4.5;
//        dotImgView.layer.masksToBounds = YES;
        dotImgView.tag = kCellContentViewBaseTag + 2;
        [cell.contentView addSubview:dotImgView];
        
        [cell.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)]];
        [cell.contentView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 45 - kLineHeight, kScreenWidth, kLineHeight)]];
    }
    
    NSDictionary *dic = _listArr[indexPath.section];
    UIImageView *iconImgView = (UIImageView *)[cell.contentView viewWithTag:kCellContentViewBaseTag];
    iconImgView.image = [UIImage imageNamed:dic[@"img"]];
    UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 1];
    titleLb.text = dic[@"title"];
    //设置frame
    CGFloat titleWidth = [UILabel widthForLabelWithText:dic[@"title"] maxHeight:45 font:kFontMiddle];
    titleLb.frame = CGRectMake(iconImgView.maxX + 16, 0, titleWidth, 45);
    UIView *dotView = (UIView *)[cell.contentView viewWithTag:kCellContentViewBaseTag + 2];
    dotView.frame = CGRectMake(titleLb.maxX + 5, 18, 9, 9);
    FoundType type = [dic[@"type"] integerValue];
    if ([self isHasNewDotForType:type]) {
        dotView.hidden = NO;
    }else{
        dotView.hidden = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _listArr[indexPath.section];
    NSNumber *type = dic[@"type"];
    switch (type.integerValue) {
        case FoundType_Circle:
        {
            //亲子圈
            CircleListViewController *avc = [[CircleListViewController alloc] init];
            avc.bid = @"parentcircle";
            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
        case FoundType_Event:
        case FoundType_Shop:
        {
            //活动专区+微豆商城
            FoundWebViewController *avc = [[FoundWebViewController alloc] init];
            avc.foundType = type.integerValue;
            avc.enterVc = self;
            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
        case FoundType_TeacherHelp:
        {
            //教师帮
            //问题
            THQuestionListViewController *questionVc = [[THQuestionListViewController alloc] init];
            //宝典
//            THGuideViewController *guideVc = [[THGuideViewController alloc] init];
            //专家
            THSpecialistViewController *specialVc = [[THSpecialistViewController alloc] init];
            //我的
            THMineViewController *mineVC = [[THMineViewController alloc] init];
            
            CustomTabBarController *tabBarController = [[CustomTabBarController alloc] init];
//            [tabBarController setViewControllers:@[questionVc, guideVc, specialVc, mineVC]];
            [tabBarController setViewControllers:@[questionVc, specialVc, mineVC]];
            [self customizeTHTabBarForController:tabBarController];
            [self.navigationController pushViewController:tabBarController animated:YES];
        }
            break;
        case FoundType_ClassBroadcast:{
            
            UIViewController *broadcastVC = [[TXClassroomListViewController alloc] init];
            [self.navigationController pushViewController:broadcastVC animated:YES];
            
//            BroadcastInfoViewController *infoVC = [[BroadcastInfoViewController alloc] init];
//            [self.navigationController pushViewController:infoVC animated:YES];
        }
            break;
        case FoundType_WeiXueYuan:
        {
            //微学园
            WXYListViewController *wxyListVc = [[WXYListViewController alloc] init];
            wxyListVc.bid = @"understandchild";
            [self.navigationController pushViewController:wxyListVc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark -教师帮TabBar
- (void)customizeTHTabBarForController:(RDVTabBarController *)tabBarController
{
//    NSArray *tabBarItemImages = @[@{@"title":@"问题",@"img":@"thTab_wt"}, @{@"title":@"宝典",@"img":@"thTab_bd"}, @{@"title":@"专家",@"img":@"thTab_zj"},@{@"title":@"我",@"img":@"thTab_gr"}];
    NSArray *tabBarItemImages = @[@{@"title":@"问题",@"img":@"thTab_wt"}, @{@"title":@"专家",@"img":@"thTab_zj"},@{@"title":@"个人",@"img":@"thTab_gr"}];
   
    NSInteger index = 0;
    [tabBarController.tabBar setHeight:kTabBarHeight];
    tabBarController.tabBar.backgroundView.backgroundColor = kColorWhite;
    [tabBarController.tabBar addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 0, kScreenWidth, kLineHeight)]];
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        NSDictionary *dic = [tabBarItemImages objectAtIndex:index];
        [item setTitle:dic[@"title"]];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            item.unselectedTitleAttributes = @{
                                               NSFontAttributeName: [UIFont systemFontOfSize:12],
                                               NSForegroundColorAttributeName: kColorItem,
                                               };
            item.selectedTitleAttributes = @{
                                             NSFontAttributeName: [UIFont systemFontOfSize:12],
                                             NSForegroundColorAttributeName: kColorOrange,
                                             };
        } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
            item.unselectedTitleAttributes = @{
                                               UITextAttributeFont: [UIFont systemFontOfSize:12],
                                               UITextAttributeTextColor: kColorItem,
                                               };
            item.selectedTitleAttributes = @{
                                             UITextAttributeFont: [UIFont systemFontOfSize:12],
                                             UITextAttributeTextColor: KColorAppMain,
                                             };
#endif
        }
        [item setBadgeBackgroundColor:RGBCOLOR(255, 0, 0)];
        item.badgePositionAdjustment = UIOffsetMake(-4, 3);
        if ([SDiPhoneVersion deviceSize] == iPhone47inch ||
            [SDiPhoneVersion deviceSize] == iPhone55inch){
            [item setBadgeTextFont:[UIFont systemFontOfSize:4.5f]];
        }else{
            [item setBadgeTextFont:[UIFont systemFontOfSize:3.f]];
        }
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@-l",dic[@"img"]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",dic[@"img"]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

@end
