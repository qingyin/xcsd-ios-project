//
//  HomeViewController.m
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//
#import "HomeWoekExamViewController.h"
#import "HomeViewController.h"
#import "GuardianDetailViewController.h"
#import "ParentNoticeListViewController.h"
#import "PublishmentDetailViewController.h"
#import "PublishmentListViewController.h"
#import "MedicineViewController.h"
#import "CookBookViewController.h"
#import "MailListViewController.h"
#import "UIImageView+EMWebCache.h"
#import "TXNoticeManager.h"
#import "InsuranceOrderViewController.h"
#import "TeacherNoticeListViewController.h"
#import <SDiPhoneVersion.h>
#import "CheckInListViewController.h"
#import "AttendanceViewController.h"
#import "TXSystemManager.h"
#import "LeavesListViewController.h"
#import "BabyAttendanceViewController.h"
#import "ContactListViewController.h"
#import "VoiceSpeechViewController.h"
#import <TXChatCommon/KDCycleBannerView.h>

#import "HomeWorkListViewController.h"
#import "GameWebViewController.h"
#import "HomeWorkTestViewController.h"
#import "THQuestionListViewController.h"
#import "THSpecialistViewController.h"
#import "THMineViewController.h"
#import "CustomTabBarController.h"
#import "SDiPhoneVersion.h"

#import "GameManager.h"
#import "TXClassroomListViewController.h"
#import "SecondTestListViewController.h"

#define kUnreadBtnBaseTag           121342
static const NSString *kGardenIntroUrlString = @"http://h5.tx2010.com/cms/article.do?gardenIntro&gardenId=";

@interface HomeViewController ()
<KDCycleBannerViewDelegate,
KDCycleBannerViewDataource,UIScrollViewDelegate>
{
    UIScrollView *_listView;
    KDCycleBannerView *_topView;
//    NSMutableArray *_bannerArr;
    UIView *_listBgView;
    UIImageView *_bannerImgView;
}

@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) NSArray *bannerArr;
@property (nonatomic, strong) NSDictionary *currentProfile;

@end

@implementation HomeViewController

-(void)dealloc
{
    [self removeNotification];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //bay gaoju
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHome) name:HomePostNotification object:nil];
  }
-(void)refreshHome{
    NSDictionary *dic = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (![dic isEqualToDictionary:_currentProfile]) {
        self.currentProfile = [NSDictionary dictionaryWithDictionary:dic];
        [self initListView];
        NSString *bannerImg = [_currentProfile objectForKey:TX_PROFILE_KEY_HOME_BANNERS];
        NSError *error = nil;
        self.bannerArr = [NSJSONSerialization JSONObjectWithData:[bannerImg?bannerImg:@"" dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
        //        if (bannerImg && _bannerImgView) {
        //            [_bannerImgView sd_setImageWithURL:[NSURL URLWithString:bannerImg] placeholderImage:[UIImage imageNamed:@"banner.jpg"]];
        //        }
        if (_topView) {
            [_topView reloadDataWithCompleteBlock:nil];
        }else{
            [self initTopCycleView];
        }
        _topView.continuous = _bannerArr.count>1?YES:NO;
    }
    
    [_topView layoutIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.view.backgroundColor = kColorWhite;
//  TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
//    if (currentUser && currentUser.gardenName && [currentUser.gardenName length]) {
//        self.titleStr = currentUser.gardenName;
//    }else{
//        self.titleStr = @"学校";
//    }
    self.titleStr=@"学堂";
    self.umengEventText = @"学堂";
    [self createCustomNavBar];
    
    self.listArray = [NSMutableArray array];
    
    self.currentProfile = [NSDictionary dictionaryWithDictionary:[[TXChatClient sharedInstance] getCurrentUserProfiles:nil]];

//    _listView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY - kTabBarHeight)];
    _listView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_)];
    _listView.delegate=self;
//    _listView.contentSize=CGSizeMake(self.view.width_, self.view.height_+95);
  //   _listView.contentSize=CGSizeMake(self.view.width_, self.view.height_+230);

    
    // _listView.pagingEnabled=YES;
    
    _listView.backgroundColor = kColorWhite;
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.bounces = NO;
//    _listView.alwaysBounceVertical=NO;
    [self.view addSubview:_listView];
//    //添加分割线效果
    //    //添加分割线效果
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _listView.width_, 2)];
    topLineView.backgroundColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    [_listView addSubview:topLineView];
    
    NSString *bannerImg = [_currentProfile objectForKey:TX_PROFILE_KEY_HOME_BANNERS];
    NSError *error = nil;
    self.bannerArr = [NSJSONSerialization JSONObjectWithData:[bannerImg?bannerImg:@"" dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&error];
    
    //轮播占位
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenWidth * 180/320;
    _bannerImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner.jpg"]];
    _bannerImgView.contentMode = UIViewContentModeScaleAspectFill;
    _bannerImgView.clipsToBounds = YES;
    //    if (bannerImg) {
    //        [_bannerImgView sd_setImageWithURL:[NSURL URLWithString:bannerImg] placeholderImage:[UIImage imageNamed:@"banner.jpg"]];
    //    }
    _bannerImgView.frame = CGRectMake(0, 0, width, height);
    _bannerImgView.userInteractionEnabled = YES;
    [_listView addSubview:_bannerImgView];
    
//    if (_bannerArr.count) {
        [self initTopCycleView];
        _topView.continuous = _bannerArr.count>1?YES:NO;
//    }

    //    [self initTopCycleView];
    [self initListView];
    
    [self registerNotification];
//    [self homeUnreadCountUpdate:nil];
}

- (void)initTopCycleView{
    CGFloat width = kScreenWidth;
    CGFloat height = kScreenWidth * 180/320;
    
    _topView = [[KDCycleBannerView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _topView.delegate = self;
    _topView.datasource = self;
    _topView.continuous = YES;
    _topView.autoPlayTimeInterval = 4.f;
    _topView.addCurveLine = NO;
    _topView.pageIndicatorTintColor = RGBCOLOR(0xd7, 0xd7, 0xd7);
    _topView.currentPageIndicatorTintColor = ColorNavigationTitle;
    _topView.backgroundCurveColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        _topView.curveDistance = 4.f;
    }
    [_listView addSubview:_topView];
}

- (void)initListView{
    
    int count = 4;
    int LRMargin = 10;
    //    int colMargin = 36;
    int rowMargin = 20;
    int colMargin = 20;
    
    //    CGFloat height = (kScreenHeight - _bannerImgView.maxY  - 16 - kTabBarHeight)/count;
    //    CGFloat width = kScreenWidth/count;
    CGFloat width = (kScreenWidth - (count - 1) * rowMargin - 2 * LRMargin) / count;
    
    [_listArray removeAllObjects];
    
    NSDictionary *tmpDic = @{
                             TX_PROFILE_KEY_OPTION_ANNOUNCEMENT:@{@"title":@"公告",@"img":@"icon_announcement",@"type":@(HomeListType_Announcement)},
                             TX_PROFILE_KEY_OPTION_ACTIVITY:@{@"title":@"活动",@"img":@"icon_activity",@"type":@(HomeListType_Activity)},
                             TX_PROFILE_KEY_OPTION_RECIPES:@{@"title":@"食谱",@"img":@"icon_recipes",@"type":@(HomeListType_Recipes)},
                             TX_PROFILE_KEY_OPTION_MEDICINE:@{@"title":@"喂药",@"img":@"icon_medicine",@"type":@(HomeListType_Medicine)},
                             TX_PROFILE_KEY_OPTION_CHECK_IN:@{@"title":@"我的考勤",@"img":@"icon_guardian",@"type":@(HomeListType_Guardian)},
                             TX_PROFILE_KEY_OPTION_NOTICE:@{@"title":@"通知",@"img":@"icon_notice",@"type":@(HomeListType_Notice)},
                             TX_PROFILE_KEY_OPTION_MAIL:@{@"title":@"园长信箱",@"img":@"icon_mail",@"type":@(HomeListType_Mail)},
                             TX_PROFILE_KEY_OPTION_INSURANCE:@{@"title":@"在园无忧",@"img":@"icon_insurance",@"type":@(HomeListType_Insurance)},
                             TX_PROFILE_KEY_OPTION_ATTENDANCE:@{@"title":@"孩子考勤",@"img":@"icon_attendance",@"type":@(HomeListType_Attendance)},
                             TX_PROFILE_KEY_OPTION_CONTACTS:@{@"title":@"通讯录",@"img":@"icon_address",@"type":@(HomeListType_Address)},
                             TX_PROFILE_KEY_OPTION_VOICE_BROADCAST:@{@"title":@"语音播报",@"img":@"icon_voicespeak",@"type":@(HomeListType_VoiceSpeak)},
                             TX_PROFILE_KEY_OPTION_HOMEWORK:@{@"title":@"作业",@"img":@"icon_homework",@"type":@(HomeListType_HomeWork)},
                             TX_PROFILE_KEY_OPTION_TEACHERCOMMUNITY:@{@"title":@"教师社区",@"img":@"icon_community",@"type":@(HomeListType_CeatherCommunity)},TX_PROFILE_KEY_OPTION_GAME:@{@"title":@"游戏",@"img":@"icon_game",@"type":@(HomeListType_Game)}, // by mey
                             TX_PROFILE_KEY_OPTION_ACHIEVEMENT:@{@"title":@"成绩",@"img":@"icon_achievemment",@"type":@(HomeListType_Achievement)},
                             TX_PROFILE_KEY_OPTION_THEME_COURSE : @{@"title":@"王辉课堂",@"img":@"icon_classroom",@"type":@(HomeListType_Course)},
                             TX_PROFILE_KEY_OPTION_THEME_TEST:@{@"title":@"测试",@"img":@"icon_test",@"type":@(HomeListType_ThemeTest)}
                             };
    
    
    NSArray *homeMenuList = nil;
    NSString *homeMenuStr = [_currentProfile objectForKey:KHOMELIST];
    NSArray *homeNameList = nil;
    NSString *homeName = [_currentProfile objectForKey:KHOMELIST_NAME];
    //by mey
    //NSString *homeMenuStr =@"homework,game,achievement,studententsefaty,notice,announcement,activity,themeTest";
    
    if(homeMenuStr != nil)
    {
        homeMenuList = [homeMenuStr componentsSeparatedByString:@","];
    }
    
    if (homeName) {
        homeNameList = [homeName componentsSeparatedByString:@","];
    }
    
    [homeMenuList enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if ([tmpDic.allKeys containsObject:key]) {
            
            NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:tmpDic[key]];
            [tmp setObject:homeNameList[idx] != nil ? homeNameList[idx] : tmpDic[key][@"title"] forKey:@"title"];
            
            [_listArray addObject:tmp.copy];
        }
    }];
    
    if (_listBgView) {
        [_listBgView removeFromSuperview];
        _listBgView = nil;
    }
    
    _listBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _listBgView.backgroundColor = kColorWhite;
    [_listView addSubview:_listBgView];
    
//    __block CGFloat offsetY = 16 * kScale1;
    __block CGFloat offsetY = 0;
    __block CGFloat maxY = 0;
    [self.listArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        btn.adjustsImageWhenHighlighted = NO;
        //        UIImage *img = [UIImage scaleImage:[UIImage imageNamed:dic[@"img"]] scale:([SDiPhoneVersion deviceSize] == iPhone35inch || [SDiPhoneVersion deviceSize] == iPhone4inch)?0.84:1];
        UIImage *img = [UIImage imageNamed:dic[@"img"]];
        //        UIImage *highlightedImage = [UIImage scaleImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_1",dic[@"img"]]] scale:[SDiPhoneVersion deviceSize] == iPhone35inch?0.84:1];
        btn.frame = CGRectMake(idx%count * (width + rowMargin) + LRMargin, offsetY + 20, width, img.size.height / img.size.width * width);
        [btn setImage:img forState:UIControlStateNormal];
        //        [btn setImage:highlightedImage forState:UIControlStateHighlighted];
        //        btn.imageEdgeInsets = [btn setImageEdgeInsetsFromOriginOffSet:CGVectorMake((width - img.size.width)/2, 0) imageSize:CGSizeMake(img.size.width, img.size.height)];
        [_listBgView addSubview:btn];
        
        UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        if ([SDiPhoneVersion deviceSize] == iPhone35inch || [SDiPhoneVersion deviceSize] == iPhone4inch) {
            label.font = [UIFont systemFontOfSize:14.f];
        }else {
            label.font = [UIFont systemFontOfSize:15.f];
        }
        label.backgroundColor = [UIColor clearColor];
        label.textColor = RGBCOLOR(166,172,183);
        
        label.textAlignment = NSTextAlignmentCenter;
        label.text = dic[@"title"];
        [label sizeToFit];
        label.frame = CGRectMake(btn.minX, btn.maxY, btn.width_, label.height_);
        //        label.centerX = btn.centerX;
        [_listBgView addSubview:label];
        
        NSNumber *type = dic[@"type"];
        UIButton *unread = [UIButton buttonWithType:UIButtonTypeCustom];
        unread.tag = kUnreadBtnBaseTag + type.integerValue;
        unread.backgroundColor = RGBCOLOR(255, 0, 0);
        unread.adjustsImageWhenHighlighted = NO;
        unread.titleLabel.font = [UIFont systemFontOfSize:8];
        [unread setTitleColor:kColorWhite forState:UIControlStateNormal];
        unread.titleLabel.textAlignment = NSTextAlignmentCenter;
        unread.hidden = YES;
        [_listBgView addSubview:unread];
        
        NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
        NSNumber *countValue = nil;
        switch (type.integerValue) {
            case TXClientCountType_Announcement:
                countValue = [unreadCountDic objectForKey:TX_COUNT_ANNOUNCEMENT];
                break;
            case TXClientCountType_Activity:
                countValue = [unreadCountDic objectForKey:TX_COUNT_ACTIVITY];
                break;
            case TXClientCountType_Medicine:
                countValue = [unreadCountDic objectForKey:TX_COUNT_MEDICINE];
                break;
            case TXClientCountType_Checkin:
                countValue = [unreadCountDic objectForKey:TX_COUNT_CHECK_IN];
                break;
            case TXClientCountType_Notice:
                countValue = [unreadCountDic objectForKey:TX_COUNT_NOTICE];
                break;
            case TXClientCountType_Mail:
                countValue = [unreadCountDic objectForKey:TX_COUNT_MAIL];
                break;
            default:
                break;
        }
        
        //        CGRect rect = [btn.imageView convertRect:_listBgView.frame toView:_listBgView];
        //        unread.frame = CGRectMake(idx%count * width + width/2+20, rect.origin.y, 10, 10);
        //        unread.frame = CGRectMake(idx%count * btn.width_ + btn.width_, rect.origin.y, 0,0);
        unread.frame = CGRectMake(btn.maxX - btn.width_ / 5 + 1, btn.maxY - btn.height_ + btn.height_ / 5 - 1, 0, 0);
        
        [self setUnreadWithNum:countValue.integerValue andType:type.integerValue];
        
        __weak typeof(self)tmpObject = self;
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            //            NSNumber *type = dic[@"type"];
            //            [tmpObject onClickListBtn:type.intValue];
            [tmpObject onClickListBtn:dic];
        }];
        
        
        if ((idx + 1) % count == 0) {
            offsetY = btn.maxY + colMargin;
        }
        
        maxY = label.maxY + 16 * kScale;
    }];
    
    //    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
    //        _listBgView.frame = CGRectMake(0, _bannerImgView.maxY, self.view.width_, maxY + 8);
    //    }else{
    //        int lines = ceil(_listArray.count/(count * 1.0));
    //        if (ceil(_listArray.count/(count * 1.0)) > count) {
    //            lines = ceil(_listArray.count/(count * 1.0));
    //        }
    _listBgView.frame = CGRectMake(0, _topView.maxY, self.view.width_,maxY);
    //    }
    _listView.contentSize = CGSizeMake(_listView.width_, _listBgView.maxY+self.customNavigationView.maxY*Coefficient);
}

- (void)setUnreadWithNum:(NSInteger)num andType:(HomeListType)type{
    UIButton *unreadBtn = (UIButton *)[_listBgView viewWithTag:type + kUnreadBtnBaseTag];
    unreadBtn.hidden = num == 0?YES:NO;
    //NSString *str = [NSString stringWithFormat:@"%lld", (long long)num];
    NSString *str = @" ";
//    if (type == HomeListType_Notice ||type == HomeListType_Mail ||type == HomeListType_Medicine  ) {
//        unreadBtn.width_ = 16;
//        str = num > 99?@"...":[NSString stringWithFormat:@"%@",@(num)];
//        if(num > 0 && num <= 9)
//        {
//            unreadBtn.titleLabel.font = [UIFont systemFontOfSize:10];
//        }
//        else
//        {
//            unreadBtn.titleLabel.font = [UIFont systemFontOfSize:8];
//        }
//    }else{
        unreadBtn.width_ = 10;
//    }
    unreadBtn.height_ = unreadBtn.width_;
    [unreadBtn setTitle:str forState:UIControlStateNormal];
    unreadBtn.layer.cornerRadius = unreadBtn.width_/2;
    unreadBtn.layer.masksToBounds = YES;

}
//点击了学校介绍
- (void)onGardenIntroduceViewTapped
{
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSNumber *gardenId = nil;
    if (currentUser) {
        gardenId = @(currentUser.gardenId);
    }
    NSString *gardenUrlString = @"";
    if ([TXSystemManager sharedManager].isDevVersion) {
        NSString *baseUrlString = [[TXSystemManager sharedManager] webBaseUrlString];
        gardenUrlString = [baseUrlString stringByAppendingString:@"cms/article.do?gardenIntro&gardenId="];
    }else{
        gardenUrlString = [NSString stringWithFormat:@"%@",kGardenIntroUrlString];
    }
    PublishmentDetailViewController *listVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:[NSString stringWithFormat:@"%@%@",gardenUrlString,gardenId ? gardenId : @""]];
    listVc.postType = TXHomePostType_Intro;
    [self.navigationController pushViewController:listVc animated:YES];
}

- (void)onClickListBtn:(NSDictionary *)dict{
    
    NSInteger type = [dict[@"type"] integerValue];
    NSString *title = dict[@"title"];
    switch (type) {
        case HomeListType_Announcement:
        {
            //公告
            PublishmentListViewController *listVc = [[PublishmentListViewController alloc] initWithPostType:TXHomePostType_Announcement];
            listVc.titleStr = title;
            listVc.bid = TX_PROFILE_KEY_OPTION_ANNOUNCEMENT;
            
            [self.navigationController pushViewController:listVc animated:YES];
        }
            break;
        case HomeListType_Activity:
        {
            //活动
            PublishmentListViewController *listVc = [[PublishmentListViewController alloc] initWithPostType:TXHomePostType_Activity];
            listVc.titleStr = title;
            listVc.bid = TX_PROFILE_KEY_OPTION_ACTIVITY;
            
            [self.navigationController pushViewController:listVc animated:YES];
        }
            break;
        case HomeListType_Recipes:
        {
            //食谱
            CookBookViewController *cookBookVc = [[CookBookViewController alloc] init];
            [self.navigationController pushViewController:cookBookVc animated:YES];
        }
            break;
        case HomeListType_Guardian:
        {
            //刷卡
            GuardianDetailViewController *detailVC = [[GuardianDetailViewController alloc] init];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
            
        case HomeListType_Notice:
        {
            //通知
            TeacherNoticeListViewController *teacherListVc = [[TeacherNoticeListViewController alloc] init];
            teacherListVc.bid = TX_PROFILE_KEY_OPTION_NOTICE;
            teacherListVc.titleStr = title;
            
            [self.navigationController pushViewController:teacherListVc animated:YES];
        }
            break;
        case HomeListType_Medicine:
        {
            //吃药
            MedicineViewController *medicineListVc = [[MedicineViewController alloc] init];
            [self.navigationController pushViewController:medicineListVc animated:YES];
        }
            break;
        case HomeListType_Mail:
        {
            //园长信箱
            MailListViewController  *mailListVc = [[MailListViewController alloc] init];
            [self.navigationController pushViewController:mailListVc animated:YES];
        }
            break;
        case HomeListType_Insurance:
        {
            //在园无忧
            InsuranceOrderViewController *orderVc = [[InsuranceOrderViewController alloc] initWithInsuranceType:InsuranceOrderType_Intro];
            [self.navigationController pushViewController:orderVc animated:YES];
        }
            break;
        case HomeListType_SignIn:
        {
            //签到记录
            CheckInListViewController *checkInList = [[CheckInListViewController alloc] init];
            [self.navigationController pushViewController:checkInList animated:YES];
        }
            break;
        case HomeListType_Attendance:
        {
            //考勤
            BabyAttendanceViewController *babyAttendance = [[BabyAttendanceViewController alloc] init];
            [self.navigationController pushViewController:babyAttendance animated:YES];
        }
            break;
        case HomeListType_Address:
        {
            //通讯录
            ContactListViewController *address = [[ContactListViewController alloc] init];
            address.bid = TX_PROFILE_KEY_OPTION_CONTACTS;
            address.titleStr = title;
            
            [self.navigationController pushViewController:address animated:YES];
        }
            break;
            //游戏
        case HomeListType_Game:
        {
			UIViewController *avc = [[GameManager getInstance] createGameLobbyViewController];
            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
            //成绩
        case HomeListType_Achievement:
        {
            HomeWoekExamViewController *vc=[[HomeWoekExamViewController alloc]init];
            vc.bid = TX_PROFILE_KEY_OPTION_ACHIEVEMENT;
            vc.titleStr = title;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;

        case HomeListType_VoiceSpeak:
        {
            //语音播报
            VoiceSpeechViewController *voiceSpeak = [[VoiceSpeechViewController alloc] init];
            [self.navigationController pushViewController:voiceSpeak animated:YES];
        }
            break;
        case HomeListType_HomeWork:
        {
            // 作业
            HomeWorkListViewController *homeWork=[[HomeWorkListViewController  alloc]init];
            homeWork.bid = TX_PROFILE_KEY_OPTION_HOMEWORK;
            homeWork.titleStr = title;
            
            [self.navigationController pushViewController:homeWork animated:YES];
        }
            break;
        case  HomeListType_CeatherCommunity:
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
            tabBarController.bid = TX_PROFILE_KEY_OPTION_TEACHERCOMMUNITY;
            
            
            [self.navigationController pushViewController:tabBarController animated:YES];        }
            break;
        case HomeListType_ThemeTest: {
            // 测试
            SecondTestListViewController *vc = [[SecondTestListViewController alloc]init];
            vc.bid = TX_PROFILE_KEY_OPTION_THEME_TEST;
            vc.titleStr = title;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case HomeListType_Course:{
            // 王辉课堂
            
            TXClassroomListViewController *vc = [[TXClassroomListViewController alloc] init];
            vc.bid = TX_PROFILE_KEY_OPTION_THEME_COURSE;
            vc.titleStr = title;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
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
                                             NSForegroundColorAttributeName: ColorNavigationTitle,
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


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.hidden = YES;
//    [self.btnRight setImage:[UIImage imageNamed:@"home_gardenintro"] forState:UIControlStateNormal];
//    [self.btnRight addTarget:self action:@selector(onGardenIntroduceViewTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - KDCycleBannerViewDataource methods
- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView
{
    return _bannerArr;
}
- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    return UIViewContentModeScaleAspectFill;
}
- (UIImage *)placeHolderImageOfZeroBannerView {
    return [UIImage imageNamed:@"banner.jpg"];
}
- (UIImage *)placeHolderImageOfBannerView:(KDCycleBannerView *)bannerView atIndex:(NSUInteger)index
{
    return [UIImage imageNamed:@"banner.jpg"];
}
- (id)imageSourceForContent:(id)content
{
    NSDictionary *dic = (NSDictionary *)content;
    NSString *urlString = dic[@"imgUrl"];
    NSString *imgStr = [urlString getFormatPhotoUrl:_topView.width_ hight:_topView.height_];
    return imgStr;
}
#pragma mark - KDCycleBannerViewDelegate methods
- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    NSDictionary *dic = _bannerArr[index];
    if (!dic[@"url"] || ![dic[@"url"] length]) {
        return;
    }
    PublishmentDetailViewController *listVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:dic[@"url"]];
    [self.navigationController pushViewController:listVc animated:YES];
}
#pragma mark - 红点count事件
-(void)registerNotification
{
    [self subscribeMultipleCountTypes:@[@(TXClientCountType_Announcement),@(TXClientCountType_Activity),@(TXClientCountType_Medicine),@(TXClientCountType_Checkin),@(TXClientCountType_Notice),@(TXClientCountType_Mail)] refreshBlock:^(NSArray *values) {
        TXAsyncRunInMain(^{
            for(NSDictionary *subDict in values)
            {
                NSNumber *countValue = subDict[TXClientCountNewValueKey];
                [self setUnreadWithNum:[countValue integerValue] andType:[subDict[TXClientCountSubType] integerValue]];
            }
        });
    } invokeNow:YES];
}

-(void)removeNotification
{
    [self unSubscribeAll];
}




@end
