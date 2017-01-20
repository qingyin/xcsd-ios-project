//
//  HomeViewController.m
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import "HomeViewController.h"
#import "ParentNoticeListViewController.h"
#import "PublishmentDetailViewController.h"
#import "PublishmentListViewController.h"
#import "MedicineViewController.h"
#import "CookBookViewController.h"
#import "MailListViewController.h"
#import "UIImageView+EMWebCache.h"
#import "TXNoticeManager.h"
#import "InsuranceOrderViewController.h"
#import <SDiPhoneVersion.h>
#import "CalendarHomeViewController.h"
#import "BabyAttendanceViewController.h"
#import <TXChatCommon/KDCycleBannerView.h>
#import "TXSystemManager.h"
#import "GameWebViewController.h"
#import "MainViewController.h"
//#import "TeacherNoticeListViewController.h"
#import "HomeWorkListViewController.h"
#import "HomeWorkTestViewController.h"
#import "studentsXafetyViewController.h"

#import "TestListViewController.h"
#import "SecondTestListViewController.h"
#import "ChildInfo.h"
#import "GameViewController.h"
#import "HomeWorkDetailViewController.h"
#import "HomeworkDetailTwoViewController.h"

#import "GameManager.h"
#import "HomeworkResultController.h"
#import "TXClassroomListViewController.h"

#define kUnreadBtnBaseTag           121342
static const NSString *kGardenIntroUrlString = @"http://h5.tx2010.com/cms/article.do?gardenIntro&gardenId=";

@interface HomeViewController ()
<KDCycleBannerViewDataource,
KDCycleBannerViewDelegate ,UIScrollViewDelegate>
{
    UIScrollView *_listView;
    KDCycleBannerView *_topView;
    UIImageView *_bannerImgView;
//    NSMutableArray *_bannerArr;
    UIView *_listBgView;
}

@property (nonatomic,strong) NSMutableArray *listArray;
@property (nonatomic,strong) NSArray *bannerArr;
@property (nonatomic, strong) NSDictionary *currentProfile;

@property (nonatomic,copy) ChildInfo* curChildInfo;
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
 //   TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
//    if (currentUser && currentUser.gardenName && [currentUser.gardenName length]) {
//        self.titleStr = currentUser.gardenName;
//    }else{
//        self.titleStr = @"学校";
//    }
    self.titleStr=@"学堂";
    self.umengEventText = @"学堂列表";
    [self createCustomNavBar];
    
    self.listArray = [NSMutableArray array];
    
    self.currentProfile = [NSDictionary dictionaryWithDictionary:[[TXChatClient sharedInstance] getCurrentUserProfiles:nil]];
   
    _listView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_)];
    _listView.delegate=self;
    //_listView.contentSize=CGSizeMake(self.view.width_, self.view.height_+230);
   // _listView.pagingEnabled=YES;
    
    _listView.backgroundColor = kColorWhite;
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.showsVerticalScrollIndicator = NO;
    _listView.bounces = NO;
//    _listView.alwaysBounceVertical=NO;
    [self.view addSubview:_listView];
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
//    //添加幼儿园介绍标示
//    UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(width - 120, height - 40, 120, 40)];
//    introLabel.backgroundColor = kColorGray;
//    introLabel.textAlignment = NSTextAlignmentCenter;
//    introLabel.textColor = kColorWhite;
//    introLabel.font = kFontNormal;
//    introLabel.text = @"幼儿园介绍";
//    [_bannerImgView addSubview:introLabel];
    //添加点击手势
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGardenIntroduceViewTapped)];
    [_bannerImgView addGestureRecognizer:gesture];
//    if (_bannerArr.count) {
        [self initTopCycleView];
        _topView.continuous = _bannerArr.count>1?YES:NO;
//    }
    [self initListView];
    
    [self registerNotification];
//    [self homeUnreadCountUpdate:nil];
	[self getCurrentChildInfo];
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
    _topView.currentPageIndicatorTintColor = RGBCOLOR(0x5f, 0xc8, 0xfa);
    _topView.backgroundCurveColor = RGBCOLOR(0xf3, 0xf3, 0xf3);
    if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        _topView.curveDistance = 4.f;
    }
    
    [_listView addSubview:_topView];
}

- (void)initListView{
    
    int count = 4;
    int LRMargin = 10;
    int colMargin = 20;
    int rowMargin = 20;
    
 //   CGFloat height = (kScreenHeight - _bannerImgView.maxY  - 16 - kTabBarHeight)/count;
    CGFloat width = (kScreenWidth - (count - 1) * rowMargin - 2 * LRMargin) / count;
//    CGFloat width1 = kScreenWidth / count;
    
    [_listArray removeAllObjects];
    
    NSDictionary *tmpDic = @{
                             TX_PROFILE_KEY_OPTION_HOMEWORK:@{@"title":@"作业",@"img":@"icon_homework",@"type":@(TXClientCountType_HomeWork)},
                             TX_PROFILE_KEY_OPTION_GAME:@{@"title":@"游戏",@"img":@"icon_game",@"type":@(HomeListType_Game)}, // by mey
                             TX_PROFILE_KEY_OPTION_ACHIEVEMENT:@{@"title":@"成绩",@"img":@"icon_achievemment",@"type":@(HomeListType_Achievement)},
                             XCSD_PROFILE_KEY_OPTION_STUDENTSEFATY:@{@"title":@"学生安全",@"img":@"icon_insurance",@"type":@(HomeListType_StudentSefaty)},
                             TX_PROFILE_KEY_OPTION_NOTICE:@{@"title":@"通知",@"img":@"icon_notice",@"type":@(HomeListType_Notice)},
                             TX_PROFILE_KEY_OPTION_ANNOUNCEMENT:@{@"title":@"公告",@"img":@"icon_announcement",@"type":@(HomeListType_Announcement)},
                             TX_PROFILE_KEY_OPTION_ACTIVITY:@{@"title":@"活动",@"img":@"icon_activity",@"type":@(HomeListType_Activity)},
                             TX_PROFILE_KEY_OPTION_THEME_TEST:@{@"title":@"测试",@"img":@"icon_test",@"type":@(HomeListType_ThemeTest)},
                             TX_PROFILE_KEY_OPTION_THEME_COURSE : @{@"title":@"王辉课堂",@"img":@"icon_classroom",@"type":@(HomeListType_Course)}


	
    
//    TX_PROFILE_KEY_OPTION_RECIPES:@{@"title":@"食谱",@"img":@"icon_recipes",@"type":@(HomeListType_Recipes)},
//    TX_PROFILE_KEY_OPTION_MEDICINE:@{@"title":@"喂药",@"img":@"icon_medicine",@"type":@(HomeListType_Medicine)},
//    TX_PROFILE_KEY_OPTION_CHECK_IN:@{@"title":@"宝宝考勤",@"img":@"icon_game",@"type":@(HomeListType_Guardian)},
//    
//    TX_PROFILE_KEY_OPTION_MAIL:@{@"title":@"园长信箱",@"img":@"icon_mail",@"type":@(HomeListType_Mail)},
//    TX_PROFILE_KEY_OPTION_INSURANCE:@{@"title":@"在园无忧",@"img":@"icon_insurance",@"type":@(HomeListType_Insurance)},
   
    };
    
//    NSArray *keyArr = @[
//                        TX_PROFILE_KEY_OPTION_ANNOUNCEMENT,TX_PROFILE_KEY_OPTION_ACTIVITY,TX_PROFILE_KEY_OPTION_RECIPES,TX_PROFILE_KEY_OPTION_MEDICINE,TX_PROFILE_KEY_OPTION_CHECK_IN,TX_PROFILE_KEY_OPTION_NOTICE,TX_PROFILE_KEY_OPTION_INSURANCE,TX_PROFILE_KEY_OPTION_GAME,TX_PROFILE_KEY_OPTION_HOMEWORK,TX_PROFILE_KEY_OPTION_ACHIEVEMENT];
    
    // by mey
    
//    NSArray *keyArr = @[TX_PROFILE_KEY_OPTION_HOMEWORK,TX_PROFILE_KEY_OPTION_GAME,TX_PROFILE_KEY_OPTION_ACHIEVEMENT,XCSD_PROFILE_KEY_OPTION_STUDENTSEFATY,TX_PROFILE_KEY_OPTION_NOTICE,TX_PROFILE_KEY_OPTION_ANNOUNCEMENT,
//                        TX_PROFILE_KEY_OPTION_ACTIVITY,TX_PROFILE_KEY_OPTION_THEME_TEST, TX_PROFILE_KEY_OPTION_THEME_COURSE];
	
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

    [_listView addSubview:_listBgView];
    
    __block CGFloat offsetY = 16 * kScale1;
    __block CGFloat maxY = 0;
    [self.listArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
        
        
        UIImage *img = [UIImage imageNamed:dic[@"img"]];
        UIButton *btn = [[UIButton alloc] init];
        [btn setImage:img forState:UIControlStateNormal];
//        btn.frame = CGRectMake(idx%count * width + LRMargin, offsetY + 22, img.size.width, img.size.height );
        btn.frame = CGRectMake((idx % count) * (width + rowMargin) + LRMargin, offsetY + 22, width, img.size.height / img.size.width * width);
          
        NSNumber *type = dic[@"type"];
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
        [_listBgView addSubview:label];
        

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
            case TXClientCountType_HomeWork:
                countValue=[unreadCountDic objectForKey:TX_COUNT_HOMEWORK];
                break;
            default:
                break;
        }
        
        unread.frame = CGRectMake(btn.maxX - btn.width_ / 5 + 1, btn.maxY - btn.height_ + btn.height_ / 5 - 1, 0, 0);
        [self setUnreadWithNum:countValue.integerValue andType:type.integerValue];
        
//        __weak typeof(self)tmpObject = self;
        WEAKTEMP
        [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
//            NSNumber *type = dic[@"type"];
            [tmpObject onClickListBtn:dic];
        }];
        
        
        if ((idx + 1) % count == 0) {
//            offsetY = label.maxY + 16 * kScale;
            offsetY = btn.maxY + colMargin;
        }
//        CGFloat f = kScale;
        maxY = label.maxY + 16 * kScale;
        
    }];
    
//    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
//        _listBgView.frame = CGRectMake(0, _bannerImgView.maxY, self.view.width_, maxY + 8);
//    }else{
//    int lines = ceil(_listArray.count/(count * 1.0));
//        _listBgView.frame = CGRectMake(0, _bannerImgView.maxY, self.view.width_, height * lines);
////    }
    _listBgView.frame = CGRectMake(0, _bannerImgView.maxY, self.view.width_,maxY);
    _listView.contentSize = CGSizeMake(_listView.width_, _listBgView.maxY+self.customNavigationView.maxY*Coefficient);

}

- (void)setUnreadWithNum:(NSInteger)num andType:(HomeListType)type{
    UIButton *unreadBtn = (UIButton *)[_listBgView viewWithTag:type + kUnreadBtnBaseTag];
    unreadBtn.hidden = num == 0?YES:NO;
    NSString *str=@"";
    //NSString *str = [NSString stringWithFormat:@"%lld", (long long)num];
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
//点击了幼儿园介绍
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
//- (void)onClickListBtn:(HomeListType)type{
- (void)onClickListBtn:(NSDictionary *)dict{
    
    NSInteger type = [dict[@"type"] integerValue];
    NSString *title = dict[@"title"];
    switch (type) {
        case HomeListType_Announcement:
        {
//            //公告
            PublishmentListViewController *listVc = [[PublishmentListViewController alloc] initWithPostType:TXHomePostType_Announcement];
            listVc.titleStr = title;
            listVc.bid = TX_PROFILE_KEY_OPTION_ANNOUNCEMENT;
            [self.navigationController pushViewController:listVc animated:YES];
            
//            CalendarHomeViewController *avc = [[CalendarHomeViewController alloc] init];
//            avc.titleStr = @"请假时间";
//            [avc setAirPlaneToDay:365 ToDateforString:nil];
//            avc.calendarblock = ^(NSArray *selectedArr){
//            };
//            [self.navigationController pushViewController:avc animated:YES];
        }
            break;
        case HomeListType_Activity:
        {
            //活动
            PublishmentListViewController *listVc = [[PublishmentListViewController alloc] initWithPostType:TXHomePostType_Activity];
            listVc.titleStr = title;
            listVc.bid = TX_PROFILE_KEY_OPTION_ACTIVITY;
            [self.navigationController pushViewController:listVc animated:YES];
           // NSLog(@"listVc.titleStr=%@",listVc.titleStr);
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
            //考勤
            BabyAttendanceViewController *detailVC = [[BabyAttendanceViewController alloc] init];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
            
        case HomeListType_Notice:
        {
            //通知
            ParentNoticeListViewController *parentListVc = [[ParentNoticeListViewController alloc] init];
            parentListVc.titleStr = title;
            parentListVc.bid = TX_PROFILE_KEY_OPTION_NOTICE;
            [self.navigationController pushViewController:parentListVc animated:YES];
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
        //游戏
        case HomeListType_Game:
        {
			UIViewController *avc = [[GameManager getInstance] createGameLobbyViewController];
//            avc.titleStr = title;
            [self.navigationController pushViewController:avc animated:YES];
            
        }
            break;
        case TXClientCountType_HomeWork:            //作业
        {
            HomeWorkListViewController *homeWorkListVc = [[HomeWorkListViewController alloc] init];
            homeWorkListVc.titleStr = title;
            homeWorkListVc.bid = TX_PROFILE_KEY_OPTION_HOMEWORK;
            [self.navigationController pushViewController:homeWorkListVc animated:YES];
            
//            HomeworkDetailTwoViewController *homeworkVC = [[HomeworkDetailTwoViewController alloc] init];
//            [self.navigationController pushViewController:homeworkVC animated:YES];
        }
            break;
            //成绩
		case HomeListType_Achievement:
		{
            HomeworkResultController *avc = [[HomeworkResultController alloc] init];
            avc.bid = TX_PROFILE_KEY_OPTION_ACHIEVEMENT;
            avc.titleStr = title;
			[self.navigationController pushViewController:avc animated:YES];
			
        }
            break;
        case HomeListType_StudentSefaty:// 学生安全
        {
            studentsXafetyViewController *vc=[[studentsXafetyViewController alloc]init];
            vc.bid = TX_PROFILE_KEY_OPTION_HOMEWORK;
            vc.titleStr = title;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
		case HomeListType_ThemeTest:// 主题测试
		{
			SecondTestListViewController *vc = [[SecondTestListViewController alloc]init];
            vc.childInfo = self.curChildInfo;
//			vc.hidesBottomBarWhenPushed = YES;
            vc.titleStr = title;
            vc.bid = TX_PROFILE_KEY_OPTION_THEME_TEST;
            
			[self.navigationController pushViewController:vc animated:YES];
		}
			break;
        case HomeListType_Course:{//王辉课堂
            
            TXClassroomListViewController *classVC = [[TXClassroomListViewController alloc] init];
            classVC.titleStr = title;
            classVC.bid = TX_PROFILE_KEY_OPTION_THEME_COURSE;
            [self.navigationController pushViewController:classVC animated:YES];
        }
            break;
        default:
            break;
    }
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
    [self subscribeMultipleCountTypes:@[@(TXClientCountType_Announcement),@(TXClientCountType_Activity),@(TXClientCountType_Medicine),@(TXClientCountType_Checkin),@(TXClientCountType_Notice),@(TXClientCountType_Mail),@(TXClientCountType_HomeWork),] refreshBlock:^(NSArray *values) {
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

-(void)getCurrentChildInfo
{
	TXUser * user = [[TXChatClient sharedInstance]getCurrentUser:nil];
	
	if ([user.childUserIdAndRelationsList count] == 0) {
		//         todo
	}
	else
	{
		TXPBChild *child= (TXPBChild*)user.childUserIdAndRelationsList[0];
		self.curChildInfo = [[ChildInfo alloc]init];
		self.curChildInfo.id = [[NSNumber numberWithLongLong:child.userId] stringValue];
		//self.curChildInfo.id = @"2";
		self.curChildInfo.childType = kChildTypeWritable;
		
		SchoolAgeInfo *schoolAge = [[SchoolAgeInfo alloc]init];
		schoolAge.value = @"2";
		self.curChildInfo.schoolAge = schoolAge;
	}
}

@end
