//
//  CircleListViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleListViewController.h"
#import "MJRefresh.h"
#import "CircleListHeaderCell.h"
#import "CircleListOtherCell.h"
#import "NSMutableAttributedString+NimbusKitAttributedLabel.h"
#import "TXMessageInputView.h"
#import "AppDelegate.h"
#import "SendNotificationViewController.h"
//#import "CHShowPhotoView.h"
#import "TXSystemManager.h"
#import "UILabel+ContentSize.h"
#import "TXPhotoBrowserViewController.h"
#import "CirclePublishViewController.h"
#import "CircleUploadCenter.h"
#import "VideoRecordViewController.h"
#import "TXVideoPreviewViewController.h"
#import "TXContactManager.h"
#import "DropdownView.h"
#import "VideoPickerViewController.h"
#import <extobjc.h>
#import "UploadImageStatus.h"


#define kHeaderCellIdentifier           @"headerCellIdentifier"
#define kOtherCellIdentifier            @"otherCellIdentifier"
#define NAVBAR_CHANGE_POINT             64

typedef enum : NSUInteger {
    RequestType_None = 0,
    RequestType_Header,
    RequestType_Footer,
} RequestType;

@interface CircleListViewController ()<
    UITableViewDataSource,
    UITableViewDelegate,
    UIGestureRecognizerDelegate,
    XHMessageInputViewDelegate,
    MoreViewDelegate,
    UIScrollViewDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    TXImagePickerControllerDelegate>
{
    TXFeed *_currentFeed;     //当前操作的评论
    UIImageView *_navigationBarMaskView;
    UIView *_blurBarView;
    BOOL _isNeedUpdateFeedListFrame;
    UIView *_topBarLineView;
    UILabel *_barTitleLb;
    CustomButton *_addFeedButton;
    BOOL _isNormalAddFeedImage;
    BOOL _statusBarWhite;
    dispatch_queue_t _loadDataQueue;
    
    UIButton *_selectedBtn;
    NSInteger _selectedIndex;
    UIImageView *_bgImgView;
    UIImageView *_arrowImgView;
    
    BOOL _isEditBgImg;
    BOOL _isURLPeeking;
}

@property (nonatomic, strong) NSMutableArray *titlesArr;
@property (nonatomic, strong) DropdownView *dropdownView;
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, weak) UITableView *listTableView;
@property (nonatomic, weak) TXMessageInputView *msgInputView;
@property (nonatomic, strong) TXFeed *currentFeed;
@property (nonatomic, strong) NSArray *photoArr;
@property (nonatomic, strong) NSMutableArray *tmpListArr;
@property (nonatomic, assign) RequestType type;
@property (nonatomic, assign) BOOL isScrolling;     //是不是正在滚动
@property (nonatomic, strong) NSNumber *currentToUserId;
@property (nonatomic, strong) NSString *currentToUserName;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL isFirstLoad;
@property (nonatomic, assign) NSInteger newsNum;
@property (nonatomic, strong) NSMutableArray *groupList;

@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, weak) UIView *selectView;
@property (nonatomic, assign) CGFloat selectHeight;

@end

@implementation CircleListViewController

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshList:) name:NOTIFY_UPDATE_CIRCLE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshList:) name:kRefreshUseInfo object:nil];
        WEAKSELF
        [self subscribeCountType:TXClientCountType_FeedComment refreshBlock:^(NSInteger oldValue, NSInteger newValue, TXClientCountType type) {
            if(newValue > 0)
            {
                STRONGSELF
                if (strongSelf) {
                    strongSelf.newsNum = newValue;
                    strongSelf.isShowNews = YES;
                    [strongSelf reloadData];
                }
            }
        }];
        
        self.departmentId = -1;
        
        _loadDataQueue = dispatch_queue_create("com.txFeed.loadDataQueue", NULL);
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    //添加输入框组件
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *rootViewController = (UINavigationController *)delegate.window.rootViewController;
//    UIViewController *vc = rootViewController.topViewController;
//    if (![_msgInputView isDescendantOfView:vc.view]) {
//        [vc.view addSubview:_msgInputView];
//        [vc.view bringSubviewToFront:_msgInputView];
//    }
    // 设置关联的scrollView
    self.msgInputView.associatedScrollView = _listTableView;
    
    NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
    NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_FEED];
//    NSNumber *commentCountValue = [unreadCountDic objectForKey:TX_COUNT_FEED_COMMENT];
    if (countValue.integerValue > 0 && _listTableView) {
        self.type = RequestType_Header;
        [_listTableView.header beginRefreshing];
    }
//    else if (commentCountValue.integerValue >0 && _listTableView){
//        [_listTableView setContentOffset:CGPointMake(0, 0) animated:NO];
//    }
//    if (_statusBarWhite) {
//        if (IOS7_OR_LATER) {
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//        }else{
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
//        }
//    }
    
    
    DropdownView *dropdownView = [[DropdownView alloc] init];
    _dropdownView = dropdownView;
    @weakify(self);
    [_dropdownView showInView:self.view andListArr:_titlesArr andDropdownBlock:^(int index) {
        @strongify(self);
        if(index == -1)
        {
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            return;
        }
        else
        {
            _selectedIndex = index;
            if (index == 0) {
                self.titleStr = @"全部";
                self.departmentId = -1;
            }else{
                TXDepartment *depart = self.groupList[index];
                self.titleStr = depart.name;
                self.departmentId = depart.departmentId;
            }
            self.titleLb.text = self.titleStr;
            CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
            _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
            _arrowImgView.centerY = self.titleLb.centerY;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _arrowImgView.transform = CGAffineTransformMakeRotation(0);
            } completion:nil];
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            TXAsyncRun(^{
                TXAsyncRunInMain(^{
                    self.type = RequestType_Header;
                    [self.listTableView.header beginRefreshing];
                    [TXProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
            
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    //移除输入框组件
//    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *rootViewController = (UINavigationController *)delegate.window.rootViewController;
//    UIViewController *vc = rootViewController.topViewController;
//    if ([_msgInputView isDescendantOfView:vc.view]) {
//        [_msgInputView removeFromSuperview];
//    }
    
    [self.msgInputView.inputView endEditing:YES];
}

/**
 *  刷新列表
 *
 *  @param notification 通知
 */
- (void)onRefreshList:(NSNotification *)notification{
    
    if ([notification.object isKindOfClass:[TXFeed class]]) {
        //详情的feed有修改（喜欢或者评论），对应替换列表页面feed
        TXFeed *feed = notification.object;
        feed.isFold = [NSNumber numberWithBool:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedId == %lld",feed.feedId];
        NSArray *arr = [_listArr filteredArrayUsingPredicate:predicate];
        if (arr.count) {
            feed.likeLb = [CircleListViewController getNIAttributedLabelWith:feed.circleLikes];
            feed.commentLbArr = [CircleListViewController getAttrobuteLabelArr:feed];
            feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
            [_listArr replaceObjectAtIndex:[_listArr indexOfObject:arr[0]] withObject:feed];
            [_listTableView reloadData];
        }
    }else if ([notification.object isKindOfClass:[NSDictionary class]]){
        NSDictionary *dic = notification.object;
        TXFeed *feed = dic.allValues[0];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"feedId == %lld",feed.feedId];
        NSArray *arr = [_listArr filteredArrayUsingPredicate:predicate];
        if (arr.count) {
            [_listArr removeObject:arr[0]];
            [_listTableView reloadData];
        }
    }
    else{
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
        if (notification.object) {
            //如果object存在，表示新发布了亲子圈，列表滚动到顶部
            [_listTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        self.type = RequestType_Header;
        [self fetchFeeds];
    }
}

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


- (void)viewDidLoad {
    [super viewDidLoad];
    _statusBarWhite = YES;
    [self createCustomNavBar];
    
    _isFirstLoad = YES;
    
    self.titlesArr = [NSMutableArray array];
    
    NSDictionary *unreadCountDic = [[TXChatClient sharedInstance] getCountersDictionary];
    NSNumber *countValue = [unreadCountDic objectForKey:TX_COUNT_FEED_COMMENT];
    if([countValue integerValue] > 0)
    {
        self.isShowNews = YES;
        self.newsNum = countValue.integerValue;
        [MobClick event:@"create_newmessage" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@(self.newsNum), @"圈子新消息数", nil] counter:1];
    }
    
    
    //添加默认view，避免push和present时tableview往下挪移20像素的问题
    UIView *fixPxView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 0)];
    fixPxView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:fixPxView];
    //添加tableview
    UITableView *listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,self.customNavigationView.maxY,self.view.width_ ,self.view.height_ - self.customNavigationView.maxY) style:UITableViewStylePlain];
    _listTableView = listTableView;
    _listTableView.backgroundColor = kColorBackground;
    _listTableView.delegate = self;
    _listTableView.dataSource = self;
    _listTableView.showsVerticalScrollIndicator = YES;
    _listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_listTableView];
    //设置评论输入框组件
    [self setupChatToolBarView];
    // 2.集成刷新控件
    [self setupRefresh];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    tapGesture.delegate = self;
    [_listTableView addGestureRecognizer:tapGesture];
    
    //获取最新亲子圈列表
    self.type = RequestType_Header;
    [self loadFeedFormLocal];

    self.groupList = [NSMutableArray arrayWithObject:@"全部"];
    [_groupList addObjectsFromArray:[[TXChatClient sharedInstance] getAllDepartments:nil]];
    if (_groupList.count == 2) {
        TXDepartment *department = _groupList[1];
        self.departmentId = department.departmentId;
        //只有一个组不显示筛选框
        self.titleStr = department.name;
        self.titleLb.text = self.titleStr;
        return;
    }else if (_groupList.count < 2){
        self.titleLb.text = @"亲子圈";
        return;
    }
    [_groupList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            [_titlesArr addObject:obj];
        }else{
            TXDepartment *depart = obj;
            [_titlesArr addObject:depart.name];
        }
    }];
    
    _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectedBtn.adjustsImageWhenHighlighted = NO;
    _selectedBtn.frame = CGRectMake(0, self.customNavigationView.height_ - kNavigationHeight, self.customNavigationView.width_, kNavigationHeight);
    [_selectedBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavigationView addSubview:_selectedBtn];
    [self.customNavigationView bringSubviewToFront:self.btnLeft];
    [self.customNavigationView bringSubviewToFront:self.btnRight];
    self.titleLb.font = kFontMiddle;
    self.titleLb.text = @"全部";
    
    _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dh_s"]];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [self.customNavigationView addSubview:_arrowImgView];
}

#pragma mark - DROPDOWN VIEW
- (void)showDropDownView
{
    [_dropdownView showDropDownView:self.customNavigationView.maxY];
    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
    _arrowImgView.centerY = self.titleLb.centerY;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:nil];
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.dropdownView = nil;
}

//- (void)dropdownViewDidHide:(LMDropdownView *)dropdownView{
////    isShowDrop = NO;
//    if (isReload) {
//        isReload = NO;
//        __weak __typeof(&*self) weakSelf=self;  //by sck
//        [TXProgressHUD showHUDAddedTo:weakSelf.view withMessage:@""];
//        TXAsyncRun(^{
//            TXAsyncRunInMain(^{
//                weakSelf.type = RequestType_Header;
//                [weakSelf.listTableView.header beginRefreshing];
//                [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
//            });
//        });
//    }
//    
//    _listTableView.scrollEnabled = YES;
//    CGSize size = [self.titleLb sizeThatFits:CGSizeMake(kScreenWidth, MAXFLOAT)];
//    _arrowImgView.frame = CGRectMake(self.titleLb.width_/2 + size.width/2, 0, 11, 9);
//    _arrowImgView.centerY = self.titleLb.centerY;
////    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
////        _arrowImgView.transform = CGAffineTransformMakeRotation(0);
////    } completion:nil];
//}


/**
 *  点击Navigation标题按钮
 *
 *  @return sender
 */

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonRight) {
        if ([[CircleUploadCenter shareInstance] isForbiddenAddFeed]) {
            [self showFailedHudWithTitle:@"亲子圈暂不可用"];
            return;
        }
        sender.selected = !sender.selected;
        [self initSelectView];
    }else if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initSelectView{
    if (!_coverView) {
        UIView *coverView = [[UIView alloc] init];
        _coverView = coverView;
        _coverView.clipsToBounds = YES;
        _coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0);
        _coverView.frame = _listTableView.frame;
        [self.view addSubview:_coverView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCoverView:)];
        [_coverView addGestureRecognizer:tap];
    }
    
    if (!_selectView) {
        UIView *selectView = [[UIView alloc] init];
        _selectView = selectView;
        _selectView.backgroundColor = kColorWhite;
        _selectView.frame = CGRectMake(0, 0, kScreenWidth, 108);
        [_coverView addSubview:_selectView];
        _selectView.maxY = 0;
        CGFloat offset = (kScreenWidth - 70 - 50 * 4)/3.0;
        NSArray *arr = @[@"图片",@"拍照"];
        if (IOS7_OR_LATER) {
            arr = @[@"图片",@"拍照",@"拍视频",@"导入视频"];
        }
        for (int i = 0; i < arr.count; ++i) {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"qzq-%d",i + 1]];
            imageView.frame = CGRectMake(35 + (offset + 50) * i, 17, 50, 50);
            [_selectView addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
            label.font = [UIFont systemFontOfSize:11.f];
            label.textColor = kColorBlack;
            label.text = arr[i];
            label.textAlignment = NSTextAlignmentCenter;
            [_selectView addSubview:label];
            [label sizeToFit];
            label.frame = CGRectMake(imageView.minX, imageView.maxY + 8, imageView.width_, label.height_);
            _selectHeight = 17 + 50 + 8 + 17 + label.height_;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100 + i;
            [btn addTarget:self action:@selector(onSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
            [_selectView addSubview:btn];
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(imageView.mas_left);
                make.right.mas_equalTo(imageView.mas_right);
                make.top.mas_equalTo(imageView.mas_top);
                make.bottom.mas_equalTo(label.mas_bottom);
            }];
        }
        _selectView.height_ = _selectHeight;
    }
    if (self.btnRight.selected) {
        _coverView.hidden = NO;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _coverView.backgroundColor = self.btnRight.selected?RGBACOLOR(0, 0, 0, 0.6):RGBACOLOR(0, 0, 0, 0);
        _selectView.maxY = self.btnRight.selected?_selectHeight:0;
    } completion:^(BOOL finished) {
        _coverView.hidden = self.btnRight.selected?NO:YES;
    }];
}

- (void)hideCoverView:(UITapGestureRecognizer *)tap{
    self.btnRight.selected = !self.btnRight.selected;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _coverView.backgroundColor = self.btnRight.selected?RGBACOLOR(0, 0, 0, 0.6):RGBACOLOR(0, 0, 0, 0);
        _selectView.maxY = self.btnRight.selected?_selectHeight:0;
    } completion:^(BOOL finished) {
        _coverView.hidden = self.btnRight.selected?NO:YES;
    }];
}

- (void)onSelectBtn:(UIButton *)btn{
    [self.msgInputView endEdit];
    NSInteger index = btn.tag - 100;
    switch (index) {
        case 0:
        {
            [[TXSystemManager sharedManager] requestPhotoPermissionWithBlock:^(BOOL photoGranted) {
                if (photoGranted) {
                    //已授权相册访问
//                    [self showImagePickerControllerWithCurrentSelectedCount:9];
                    [self showImagePickerControllerWithMaxSelectionNumber:9 currentSelectedCount:0];
                }else{
                    //未授权相册访问
                    [self showPhotoPermissionDeniedAlert];
                }
            }];
        }
            break;
        case 1:
        {
            //拍照
            [[TXSystemManager sharedManager] requestCameraPermissionWithBlock:^(BOOL cameraGranted) {
                if (cameraGranted) {
                    UIImagePickerController *photoPickerController = [[UIImagePickerController alloc]init];
                    photoPickerController.view.backgroundColor = kColorClear;
                    UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeCamera;
                    photoPickerController.sourceType = sourcheType;
                    photoPickerController.delegate = self;
                    photoPickerController.allowsEditing = NO;
                    [self.navigationController presentViewController:photoPickerController animated:YES completion:NULL];
                }else{
                    [self showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:YES];
                }
            }];
        }
            break;
        case 2:
        {
            [[TXSystemManager sharedManager] requestCameraAndMicrophonePermissionWithBlock:^(BOOL cameraGranted, BOOL microphoneGranted) {
                TXAsyncRunInMain(^{
                    if (cameraGranted && microphoneGranted) {
                        //已授权
                        VideoRecordViewController *recordVc = [[VideoRecordViewController alloc] init];
                        recordVc.backVc = self;
                        [self.navigationController pushViewController:recordVc animated:YES];
                    }else{
                        //未授权
                        [self showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:microphoneGranted];
                    }
                });
            }];
        }
            break;
        case 3:
        {
            //本地视频
            [[TXSystemManager sharedManager] requestPhotoPermissionWithBlock:^(BOOL photoGranted) {
                TXAsyncRunInMain(^{
                    if (photoGranted) {
                        //已授权
                        WEAKSELF
                        VideoPickerViewController *vc = [[VideoPickerViewController alloc] init];
                        vc.finishBlock = ^(NSURL *videoURL,NSDate *videoDate) {
                            STRONGSELF
                            CirclePublishViewController *uploadVc = [[CirclePublishViewController alloc] init];
                            uploadVc.videoType = YES;
                            uploadVc.videoURL = videoURL;
                            uploadVc.videoBackVc = strongSelf;
                            [strongSelf.navigationController pushViewController:uploadVc animated:YES];
                        };
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        //未授权
                        [self showPhotoPermissionDeniedAlert];
                    }
                });
            }];
        }
            break;
        default:
            break;
    }
    
    [self hideCoverView:nil];
}


//弹出发表类型Sheet
- (void)showAddFeedChooseSheet
{
    [self.msgInputView endEdit];
    [self showNormalSheetWithTitle:nil items:@[@"小视频",@"照片"] clickHandler:^(NSInteger index) {
        if (index == 0) {
            [[TXSystemManager sharedManager] requestCameraAndMicrophonePermissionWithBlock:^(BOOL cameraGranted, BOOL microphoneGranted) {
                TXAsyncRunInMain(^{
                    if (cameraGranted && microphoneGranted) {
                        //已授权
                        VideoRecordViewController *recordVc = [[VideoRecordViewController alloc] init];
                        recordVc.backVc = self;
                        [self.navigationController pushViewController:recordVc animated:YES];
                    }else{
                        //未授权
                        [self showPermissionAlertWithCameraGranted:cameraGranted microphoneGranted:microphoneGranted];
                    }
                });
            }];
            
        }else if (index == 1) {
            CirclePublishViewController *avc = [[CirclePublishViewController alloc] init];
            [self.navigationController pushViewController:avc animated:YES];
        }
    } completion:nil];
}

/**
 *  创建聊天工具栏视图
 */
- (void)setupChatToolBarView
{
    // 设置Message TableView 的bottom edg
    [self setTableViewInsetsWithBottomValue:kChatToolBarHeight];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *rootViewController = (UINavigationController *)delegate.window.rootViewController;
    UIViewController *vc = rootViewController.topViewController;
    TXMessageInputView *msgInputView = [[TXMessageInputView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(rootViewController.view.frame), CGRectGetWidth(rootViewController.view.frame), kChatToolBarHeight)];
    _msgInputView = msgInputView;
    _msgInputView.delegate = self;
    _msgInputView.associatedScrollView = _listTableView;
    _msgInputView.contentViewController = rootViewController;
    _msgInputView.shouldShowInputViewWhenFinished = NO;
    [_msgInputView setupView];
    [vc.view addSubview:_msgInputView];
    [vc.view bringSubviewToFront:_msgInputView];
}

/**
 *  识别触摸时间，屏蔽点击btn等的事件
 */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    if (self.dropdownView.isOpen) {
//        return NO;
//    }
    if([touch.view isKindOfClass:[NIAttributedLabel class]] ||
       [touch.view isKindOfClass:[MLEmojiLabel class]] ||
       [touch.view isKindOfClass:[UIButton class]])
       {
        return NO;
    }
    return YES;
}

- (void)onTapGesture:(UIGestureRecognizer *)gesture{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideMoreView object:nil];
    [self.msgInputView endEdit];
}

/**
 *  集成刷新控件
 */
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

/**
 *  下拉刷新
 */
- (void)headerRereshing{
    self.type = RequestType_Header;
    [self fetchFeeds];
}

/**
 *  上拉刷新
 */
- (void)footerRereshing{
    self.type = RequestType_Footer;
    [self fetchFeeds];
}

/**
 *  创建顶部导航条
 */
- (void)createCustomNavBar{
    [super createCustomNavBar];
//    [self.btnRight setImage:[UIImage imageNamed:@"circle_new_1"] forState:UIControlStateNormal];
    
    [self.btnRight setImage:[UIImage imageNamed:@"circle_more"] forState:UIControlStateNormal];
    [self.btnRight setImage:[UIImage imageNamed:@"circle_more_1"] forState:UIControlStateSelected];
}
//创建新的导航栏
- (void)setupFeedNavigationBarView
{
    _navigationBarMaskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, NAVBAR_CHANGE_POINT)];
    _navigationBarMaskView.image = [UIImage imageNamed:@"feedNvBarMask"];
    [self.view addSubview:_navigationBarMaskView];
    _navigationBarMaskView.alpha = 0.0;
    //滚动时的top图
    _blurBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, NAVBAR_CHANGE_POINT)];
    _blurBarView.backgroundColor = kColorWhite;
    [self.view addSubview:_blurBarView];
//    _blurBarView.alpha = 0.f;
    _topBarLineView = [[UIView alloc] initWithFrame:CGRectMake(0, _blurBarView.maxY - 0.5, _blurBarView.width_, 0.5)];
    _topBarLineView.backgroundColor = RGBCOLOR(0xd8, 0xd8, 0xd8);
    [_blurBarView addSubview:_topBarLineView];
    //创建标题
    CGFloat navHeight = IOS7_OR_LATER?kNavigationHeight + kStatusBarHeight:kNavigationHeight;
    _barTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, self.view.width_, kNavigationHeight)];
    _barTitleLb.backgroundColor = [UIColor clearColor];
    _barTitleLb.frame = CGRectMake(0, 0,self.view.width_, kNavigationHeight);
    _barTitleLb.center = CGPointMake(self.view.centerX, navHeight - kNavigationHeight / 2);
    _barTitleLb.font = kFontSuper_b;
    _barTitleLb.textColor = kColorWhite;
    _barTitleLb.textAlignment = NSTextAlignmentCenter;
    _barTitleLb.text = @"亲子圈";
    [self.view addSubview:_barTitleLb];
    //添加相机按钮
    _addFeedButton = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.width_ - 100, navHeight - kNavigationHeight, 100, kNavigationHeight)];
    _addFeedButton.showBackArrow = NO;
    _addFeedButton.tag = TopBarButtonRight;
    _addFeedButton.adjustsImageWhenHighlighted = NO;
    _addFeedButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _addFeedButton.titleLabel.font = kFontMiddle;
    _addFeedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft * 2);
    _addFeedButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft * 2);
    _addFeedButton.exclusiveTouch = YES;
    [_addFeedButton setImage:[UIImage imageNamed:@"circle_new_1"] forState:UIControlStateNormal];
    [_addFeedButton addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addFeedButton];
    _isNormalAddFeedImage = YES;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    _navigationBarMaskView.alpha = 0.f;
    _barTitleLb.textColor = kColorNavigationTitle;

}
#pragma mark - 亲子圈数据请求
/**
 *  获取历史数据，从数据库中加载
 */
- (void)getHistoryFeeds{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *feeds = [[TXChatClient sharedInstance] getFeeds:LLONG_MAX count:20 isInbox:YES error:nil];
//        self.listArr = [NSMutableArray array];
        NSMutableArray *lists = [NSMutableArray array];
        for (TXFeed *feed in feeds) {
            NSArray *likes = [[TXChatClient sharedInstance] getComments:feed.feedId targetType:TXPBTargetTypeFeed commentType:TXPBCommentTypeLike maxCommentId:LLONG_MAX count:LLONG_MAX error:nil];
            NSArray *comments = [[TXChatClient sharedInstance] getComments:feed.feedId targetType:TXPBTargetTypeFeed commentType:TXPBCommentTypeReply maxCommentId:LLONG_MAX count:LLONG_MAX error:nil];
            
            feed.isFold = [NSNumber numberWithBool:YES];
            feed.circleLikes = [NSMutableArray arrayWithArray:likes];
            feed.circleComments = [NSMutableArray arrayWithArray:comments];
            feed.likeLb = [CircleListViewController getNIAttributedLabelWith:feed.circleLikes];
            feed.commentLbArr = [CircleListViewController getAttrobuteLabelArr:feed];
//            [_listArr addObject:feed];
            [lists addObject:feed];
        }
        [self updateFeedList:lists];

        if (_listArr.count == feeds.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
                if (_listArr.count < 20) {
                    _listTableView.footer.hidden = YES;
                    [_listTableView.footer noticeNoMoreData];
                }
            });
        }
    });
}
//加载本地feed并开始渲染
- (void)loadFeedFormLocal
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *feeds = [[TXChatClient sharedInstance] getFeeds:LLONG_MAX count:10 isInbox:YES error:nil];
        self.isFirstLoad = NO;
        self.tmpListArr = [NSMutableArray array];
        if (feeds && [feeds count] > 0) {
            self.hasMore = YES;

            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            for(TXFeed *feed in feeds)
            {
                dispatch_group_async(group, queue, ^{
                    NSArray *likes = [[TXChatClient sharedInstance] getComments:feed.feedId targetType:TXPBTargetTypeFeed commentType:TXPBCommentTypeLike maxCommentId:LLONG_MAX count:LLONG_MAX error:nil];
                    NSArray *comments = [[TXChatClient sharedInstance] getComments:feed.feedId targetType:TXPBTargetTypeFeed commentType:TXPBCommentTypeReply maxCommentId:LLONG_MAX count:LLONG_MAX error:nil];
                    NSMutableDictionary *likeDict = [NSMutableDictionary dictionary];
                    NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
                    likeDict[@(feed.feedId)] = likes;
                    commentDict[@(feed.feedId)] = comments;
                    [self doSomethingWithFeed:feed andLikes:likeDict andComments:commentDict];
                });
            }
            dispatch_group_notify(group, queue, ^{
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF == %@",@""];
                NSArray *arr = [self.tmpListArr filteredArrayUsingPredicate:pre];
                if (arr && arr.count) {
                    [self.tmpListArr removeObjectsInArray:arr];
                }
                if (self.type == RequestType_Header) {
                    NSArray *array1 = [self.tmpListArr sortedArrayUsingComparator:cmptr];
                    [self updateFeedList:array1];
                }else if (self.type == RequestType_Footer){
                    [self addNewFeedList:self.tmpListArr];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (self.type == RequestType_Header) {
//                        [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED];
//                    }
                    [_listTableView reloadData];
                    //加载新的Feed
                    self.type = RequestType_Header;
                    [_listTableView.header beginRefreshing];
                });
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.type = RequestType_Header;
                [_listTableView.header beginRefreshing];
            });
        }
    });
}
/**
 *  获取亲子圈网络数据
 */
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
    RequestType currentType = _type;
    if (_selectedIndex != 0) {
        TXDepartment *department = _groupList[_selectedIndex];
        NSNumber *departmentId  = @(department.departmentId);
        [[TXChatClient sharedInstance].feedManager fetchFeedsWithDepartmentId:departmentId.longLongValue maxId:_type == RequestType_Header?LLONG_MAX:feed.feedId isInbox:YES onCompleted:^(NSError *error, NSArray *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            tmpObject.isFirstLoad = NO;
            tmpObject.tmpListArr = [NSMutableArray array];
            if (error) {
                [tmpObject.listTableView.header endRefreshing];
                [tmpObject.listTableView.footer endRefreshing];
//                tmpObject.listTableView.footer.hidden = YES;
//                [tmpObject.listTableView.footer noticeNoMoreData];
                [tmpObject showFailedHudWithError:error];
                
            }else if(currentType == tmpObject.type){
                tmpObject.hasMore = hasMore;
                
                if (!feeds.count) {
                    [tmpObject.listTableView.header endRefreshing];
                    [tmpObject.listTableView.footer endRefreshing];
                    //                [tmpObject reloadData];
                }
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_group_t group = dispatch_group_create();
                for(TXFeed *feed in feeds)
                {
                    dispatch_group_async(group, queue, ^{
                        [tmpObject doSomethingWithFeed:feed andLikes:txLikesDictionary andComments:txCommentsDictionary ];
                    });
                }
                dispatch_group_notify(group, queue, ^{
                    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF == %@",@""];
                    NSArray *arr = [tmpObject.tmpListArr filteredArrayUsingPredicate:pre];
                    if (arr && arr.count) {
                        [tmpObject.tmpListArr removeObjectsInArray:arr];
                    }
                    if (tmpObject.type == RequestType_Header) {
                        NSArray *array1 = [tmpObject.tmpListArr sortedArrayUsingComparator:cmptr];
                        [tmpObject updateFeedList:array1];
                    }else if (tmpObject.type == RequestType_Footer){
                        [tmpObject addNewFeedList:tmpObject.tmpListArr];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (tmpObject.type == RequestType_Header) {
                            [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED];
                        }
                        tmpObject.type = RequestType_None;
                        [tmpObject reloadData];
                    });
                });
            }
        }];

        return;
    }
    [[TXChatClient sharedInstance] fetchFeeds:_type == RequestType_Header?LLONG_MAX:feed.feedId isInbox:YES onCompleted:^(NSError *error, NSArray *feeds, NSMutableDictionary *txLikesDictionary, NSMutableDictionary *txCommentsDictionary, BOOL hasMore) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        tmpObject.isFirstLoad = NO;
        tmpObject.tmpListArr = [NSMutableArray array];
        if (error) {
            [tmpObject.listTableView.header endRefreshing];
            [tmpObject.listTableView.footer endRefreshing];
//            tmpObject.listTableView.footer.hidden = YES;
//            [tmpObject.listTableView.footer noticeNoMoreData];
            [tmpObject showFailedHudWithError:error];

        }else if(currentType == tmpObject.type){
            tmpObject.hasMore = hasMore;
            
            if (!feeds.count) {
                [tmpObject.listTableView.header endRefreshing];
                [tmpObject.listTableView.footer endRefreshing];
//                [tmpObject reloadData];
            }
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_group_t group = dispatch_group_create();
            for(TXFeed *feed in feeds)
            {
                dispatch_group_async(group, queue, ^{
                    [tmpObject doSomethingWithFeed:feed andLikes:txLikesDictionary andComments:txCommentsDictionary ];
                });
            }
            dispatch_group_notify(group, queue, ^{
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF == %@",@""];
                NSArray *arr = [tmpObject.tmpListArr filteredArrayUsingPredicate:pre];
                if (arr && arr.count) {
                    [tmpObject.tmpListArr removeObjectsInArray:arr];
                }
                if (tmpObject.type == RequestType_Header) {
                    NSArray *array1 = [tmpObject.tmpListArr sortedArrayUsingComparator:cmptr];
                    [tmpObject updateFeedList:array1];
                }else if (tmpObject.type == RequestType_Footer){
                    [tmpObject addNewFeedList:tmpObject.tmpListArr];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (tmpObject.type == RequestType_Header) {
                        [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED];
                    }
                    tmpObject.type = RequestType_None;
                    [tmpObject reloadData];
                });
            });
        }
    }];
}


- (void)doSomethingWithFeed:(TXFeed *)feed andLikes:(NSMutableDictionary *)txLikesDictionary andComments:(NSMutableDictionary *)txCommentsDictionary{
    @synchronized(self)  {
        feed.isFold = [NSNumber numberWithBool:YES];
        feed.hasMore = [NSNumber numberWithBool:feed.hasMoreComment];
        feed.circleLikes = [NSMutableArray arrayWithArray:txLikesDictionary[@(feed.feedId)]];
        feed.circleComments = [NSMutableArray arrayWithArray:txCommentsDictionary[@(feed.feedId)]];
        dispatch_async(dispatch_get_main_queue(), ^{
            feed.likeLb = [CircleListViewController getNIAttributedLabelWith:txLikesDictionary[@(feed.feedId)]];
            feed.commentLbArr = [CircleListViewController getAttrobuteLabelArr:feed];
            feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
        });
        [_tmpListArr addObject:feed];

    }
}

/**
 *  赞
 *
 *  @param feed   当前选中的feed
 *  @param isLike 是赞还是取消
 */
- (void)onFeedLikeResponse:(TXFeed *)feed andIsLike:(BOOL)isLike{
//    if ([CircleUploadCenter shareInstance].isForbiddenAddFeed) {
//        //已禁言
//        [self showFailedHudWithTitle:@"亲子圈暂不可用"];
//        return;
//    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    __weak typeof(self)tmpObject = self;
    if (isLike) {
        //点赞
        [[TXChatClient sharedInstance] sendComment:nil commentType:TXPBCommentTypeLike toUserId:feed.userId targetId:feed.feedId targetType:TXPBTargetTypeFeed onCompleted:^(NSError *error, int64_t commentId) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"点赞", nil] counter:1];
                [tmpObject showFailedHudWithError:error];
            }else{
                [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"点赞", nil] counter:1];
                if (feed.circleLikes.count) {
                    [feed.circleLikes insertObject:@(commentId) atIndex:0];
                }else{
                    feed.circleLikes = [NSMutableArray array];
                    [feed.circleLikes addObject:@(commentId)];
                }
                feed.likeLb = [CircleListViewController getNIAttributedLabelWith:feed.circleLikes];
                feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tmpObject reloadData];
                });
                [self reportEvent:XCSDPBEventTypeLikeFeed bid:[NSString stringWithFormat:@"%lld",feed.feedId]];
            }
        }];
        

    }else{
        
        BOOL isMine = NO;
        int64_t commentId;
        if (feed.circleLikes.count && [feed.circleLikes[0] isKindOfClass:[NSNumber class]]) {
            isMine = YES;
            NSNumber *tmpCommentId = feed.circleLikes[0];
            commentId = tmpCommentId.integerValue;
        }else{
            NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
            NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
            if (arr1.count) {
                TXPBLike *like = arr1[0];
                commentId = like.commentId;
            }else{
                [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
                return;
            }
        }
        
        [[TXChatClient sharedInstance] deleteComment:commentId onCompleted:^(NSError *error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [tmpObject showFailedHudWithError:error];

            }else{
                if (isMine) {
                    [feed.circleLikes removeObjectAtIndex:0];
                }else{

                    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"%K == %d",@"userId",user.userId];
                    NSArray *arr1 = [feed.circleLikes filteredArrayUsingPredicate:predicate1];
                    if (arr1.count) {
                        [feed.circleLikes removeObject:arr1[0]];
                    }
                }
                feed.likeLb = [CircleListViewController getNIAttributedLabelWith:feed.circleLikes];
                feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tmpObject reloadData];
                });
            }
        }];
    }
}

/**
 *  删除自己发布的feed
 *  教师删除家长的feed
 *
 *  @param feed 当前选中feed
 */
- (void)onFeedDeleteResponse:(TXFeed *)feed{
    if (feed.feedType == TXFeedTypeActivity) {
        [[TXChatClient sharedInstance].feedManager blockActivityFeedWithFeedId:feed.feedId];
        [self.listArr removeObject:feed];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    }else{
        __weak typeof(self)tmpObject = self;
        [[TXChatClient sharedInstance] deleteFeed:feed.feedId onCompleted:^(NSError *error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"删除圈子", nil] counter:1];
                [tmpObject showFailedHudWithError:error];
            }else{
                [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"删除圈子", nil] counter:1];
                [tmpObject.listArr removeObject:feed];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tmpObject reloadData];
                });
            }
        }];
    }
}
//播放视频
- (void)playVideoWithURLString:(NSString *)urlString
       thumbnailImageURLString:(NSString *)imageUrlString
{
    TXVideoPreviewViewController *videoVc = [[TXVideoPreviewViewController alloc] initWithVideoURLString:urlString];
    videoVc.mustCachedFirst = YES;
    videoVc.thumbImageURLString = imageUrlString;
    videoVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:videoVc animated:YES completion:nil];
}
/**
 *  全屏展示图片
 *
 *  @param arr   图片Arr
 *  @param index 显示第几张
 */
- (void)showPhotoView:(NSArray *)arr andIndex:(int)index
{
    NSMutableArray *tmpArr = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(NSString *fileurl, NSUInteger idx, BOOL *stop) {
        [tmpArr addObject:fileurl];
    }];
    self.photoArr = tmpArr;
    TXPhotoBrowserViewController *browerVc = [[TXPhotoBrowserViewController alloc] initWithFullScreen:YES];
    [browerVc showBrowserWithImages:tmpArr currentIndex:index];
    browerVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:browerVc animated:YES completion:nil];
}

/**
 *  删除评论
 *
 *  @param feed        当前选中feed
 *  @param feedComment 评论体
 */
- (void)onFeedCommentDeleteResponse:(TXFeed *)feed andComment:(id)feedComment{
    [self.view endEditing:YES];
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
//    [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        if (!buttonIndex) {
//            [self deleteCommentWithFeed:feed andComment:feedComment];
//        }
//    }];
    [self showNormalSheetWithTitle:nil items:@[@"删除"] clickHandler:^(NSInteger index) {
        if (index == 0) {
            [self deleteCommentWithFeed:feed andComment:feedComment];
        }
    } completion:nil];
}
/**
 *  展示删除或者回复的选择sheet
 *
 *  @param block 点击的回调,0是回复，1是删除
 */
- (void)showFeedDeleteOrAddChooseSheetWithCompletion:(void(^)(NSInteger index))block
{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"回复",@"删除", nil];
//    [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//        block(buttonIndex);
//    }];
    [self showNormalSheetWithTitle:nil items:@[@"回复",@"删除"] clickHandler:^(NSInteger index) {
        block(index);
    } completion:nil];
}
//删除feed的评论
- (void)deleteCommentWithFeed:(TXFeed *)feed andComment:(id)feedComment
{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    int64_t commentId;
    if ([feedComment isKindOfClass:[NSMutableDictionary class]]) {
        NSDictionary *dic = feedComment;
        NSNumber *num = dic[@"commentId"];
        commentId = num.integerValue;
    }else{
        TXComment *comment = feedComment;
        commentId = comment.commentId;
    }
    
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] deleteComment:commentId onCompleted:^(NSError *error) {
        if (error) {
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"删除评论", nil] counter:1];
            [TXProgressHUD hideHUDForView:tmpObject.view animated:NO];
            [tmpObject showFailedHudWithError:error];
        }else{
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"删除评论", nil] counter:1];
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            [feed.circleComments removeObject:feedComment];
            feed.commentLbArr = [CircleListViewController getAttrobuteLabelArr:feed];
            feed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:feed]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tmpObject reloadData];
            });
        }
    }];
}
/**
 *  添加新评论
 *
 *  @param feed        当前操作的feed
 *  @param placeholder 如果是回复某人的评论，需要把评论人带过来（回复：XXX）
 *  @param toUserId    被回复人的id
 *  @param toUserName  被回复人的名字
 */
- (void)onFeedCommentAddResponse:(TXFeed *)feed
                  andPlaceholder:(NSString *)placeholder
                     andToUserId:(NSNumber *)toUserId
                   andToUserName:(NSString *)toUserName{
    if ([CircleUploadCenter shareInstance].isForbiddenAddFeed) {
        //已禁言
        [self showFailedHudWithTitle:@"亲子圈暂不可用"];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideMoreView object:nil];
    if (placeholder && placeholder.length) {
        self.msgInputView.inputTextView.placeHolder = placeholder;
        _currentToUserId = toUserId;
        _currentToUserName = toUserName;
    }else{
        _currentToUserId = nil;
        _currentToUserName = nil;
        self.msgInputView.inputTextView.placeHolder = @"";
    }
    [self.msgInputView.inputTextView becomeFirstResponder];
    
    _currentFeed = feed;
    
    [self reportEvent:XCSDPBEventTypeCommentFeed bid:[NSString stringWithFormat:@"%lld",feed.feedId]];
}

/**
 *  发布评论
 *
 *  @param comment 评论内容
 */
- (void)sendComment:(NSString *)comment{
    if ([CircleUploadCenter shareInstance].isForbiddenAddFeed) {
        //已禁言
        [self showFailedHudWithTitle:@"亲子圈暂不可用"];
        return;
    }
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] sendComment:comment commentType:TXPBCommentTypeReply toUserId:_currentToUserId?_currentToUserId.integerValue:0 targetId:_currentFeed.feedId targetType:TXPBTargetTypeFeed onCompleted:^(NSError *error, int64_t commentId) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"评论", nil] counter:1];
            [tmpObject showFailedHudWithError:error];
        }else{
            [MobClick event:@"feed" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"评论", nil] counter:1];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:comment forKey:@"comment"];
            [dic setValue:@(commentId) forKey:@"commentId"];
            if (_currentToUserId) {
                [dic setValue:_currentToUserId forKey:@"userId"];
                [dic setValue:_currentToUserName forKey:@"userName"];
            }
            [tmpObject.currentFeed.circleComments addObject:dic];
            tmpObject.currentFeed.commentLbArr = [CircleListViewController getAttrobuteLabelArr:tmpObject.currentFeed];
            tmpObject.currentFeed.height = [NSNumber numberWithFloat:[CircleListOtherCell GetListOtherCellHeight:tmpObject.currentFeed]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [tmpObject.msgInputView endEdit];
                [tmpObject reloadData];
            });
        }
    }];

}
#pragma mark - Feed读取和设置
//读取index的feed
- (TXFeed *)feedForListWithIndex:(NSInteger)index
{
    if (!_listArr || ![_listArr count]) {
        return nil;
    }
    __block TXFeed *feed = nil;
    dispatch_sync(_loadDataQueue, ^{
        if (index >= 0 && index < [_listArr count]) {
            feed = _listArr[index];
        }
    });
    return feed;
}
//更新feed列表
- (void)updateFeedList:(NSArray *)list
{
    dispatch_barrier_async(_loadDataQueue, ^{
        _listArr = [NSMutableArray arrayWithArray:list];
    });
}
//添加列表到现有数组中
- (void)addNewFeedList:(NSArray *)list
{
    dispatch_barrier_async(_loadDataQueue, ^{
        [_listArr addObjectsFromArray:list];
    });
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
    if (!_listArr.count && !_isFirstLoad) {
        return 1;
    }else{
        return [_listArr count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *userProfiles = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (indexPath.section == 0) {
        return [CircleListHeaderCell GetHeaderCellHeight:_isShowNews andLevelName:userProfiles[TX_PROFILE_KEY_RANKING_NAME]];
    }else if (!_listArr.count && !_isFirstLoad){
        return _listTableView.height_ - [CircleListHeaderCell GetHeaderCellHeight:_isShowNews andLevelName:userProfiles[TX_PROFILE_KEY_RANKING_NAME]];
    }else{
        TXFeed *feed = [self feedForListWithIndex:indexPath.row];
        return feed.height.floatValue;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *userProfiles = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];
    if (tableView.tag == 10000) {
        static NSString *Identifier = @"customCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, tableView.width_, 40 * kScale)];
            titleLb.font = kFontMiddle;
            titleLb.textAlignment = NSTextAlignmentCenter;
            titleLb.tag = 100;
            [cell.contentView addSubview:titleLb];
        }
        
        id object = _groupList[indexPath.row];
        NSString *name = nil;
        if ([object isKindOfClass:[NSString class]]) {
            name = @"全部";
        }else{
            TXDepartment *department = object;
            name = department.name;
        }
        UILabel *titleLb = (UILabel *)[cell.contentView viewWithTag:100];
        titleLb.text = name;
        
        if (_selectedIndex == indexPath.row) {
            titleLb.backgroundColor = KColorAppMain;
            titleLb.textColor = kColorWhite;
        }else{
            titleLb.backgroundColor = kColorWhite;
            titleLb.textColor = kColorBlack;
        }
        
        return cell;
    }
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    if (indexPath.section == 0) {
        static NSString *CellIdentifier = kHeaderCellIdentifier;
        CircleListHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[CircleListHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = kColorWhite;
            cell.contentView.backgroundColor = kColorWhite;
        }
        cell.listVC = self;
        cell.newsBtn.hidden = !_isShowNews;
        [cell.newsBtn setTitle:[NSString stringWithFormat:@"  有%@条新消息  ",@(_newsNum)] forState:UIControlStateNormal];
        UIImage *imgArrow = [UIImage imageNamed:@"_newmessage"];
        [cell.newsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgArrow.size.width, 0, imgArrow.size.width)];
        [cell.newsBtn setImageEdgeInsets:UIEdgeInsetsMake(0, cell.newsBtn.titleLabel.bounds.size.width, 0, -cell.newsBtn.titleLabel.bounds.size.width)];
        int level = [userProfiles[TX_PROFILE_KEY_GRADE] intValue];
        NSString *rankStr = @"";
        NSString *rankName = userProfiles[TX_PROFILE_KEY_RANKING_NAME];
        if(rankName && rankName.length)
        {
            rankStr = [NSString stringWithFormat:@"恭喜%@获得活跃达人勋章",rankName];
        }
        [cell setPortrait:user.avatarUrl andNickname:user.nickname andLevel:level andLevelName:rankStr];
        if (!_listArr.count && !_isFirstLoad){
            cell.backgroundColor = kColorWhite;
            cell.contentView.backgroundColor = kColorWhite;
        }else{
            cell.backgroundColor = kColorWhite;
            cell.contentView.backgroundColor = kColorWhite;
        }
        return cell;
    }else if (!_listArr.count && !_isFirstLoad){
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = kColorBackground;
            cell.contentView.backgroundColor = kColorBackground;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIButton *defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            defaultBtn.frame = CGRectMake(0, 0, 140, 140);
            defaultBtn.center = CGPointMake(kScreenWidth/2, (_listTableView.height_ - [CircleListHeaderCell GetHeaderCellHeight:_isShowNews andLevelName:userProfiles[TX_PROFILE_KEY_RANKING_NAME]])/2);
            [defaultBtn setImage:[UIImage imageNamed:@"qzq_mr"] forState:UIControlStateNormal];
            [defaultBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                if (![[CircleUploadCenter shareInstance] isForbiddenAddFeed]) {
                    [self showAddFeedChooseSheet];
                }
            }];
            [cell.contentView addSubview:defaultBtn];
        }
        return cell;
    }
    else{
        static NSString *CellIdentifier = kOtherCellIdentifier;
        CircleListOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[CircleListOtherCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor = kColorWhite;
            cell.contentView.backgroundColor = kColorWhite;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        TXFeed *feed = [self feedForListWithIndex:indexPath.row];
        cell.listVC = self;
        cell.feed = feed;
        
        return cell;
    }
    return nil;
}

#pragma mark - 提前处理赞的列表，避免重绘，造成ui卡顿
+ (NIAttributedLabel *)getNIAttributedLabelWith:(NSArray *)likeList
{
    if (!likeList.count) {
        return nil;
    }
    
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    NSMutableArray *tmpArr = [NSMutableArray array];
    NSMutableString *tmpStr = [NSMutableString string];
    CGSize likeSize = CGSizeZero;
    UIFont *font = kFontSubTitle;
    for (int i = 0;i < [likeList count];++i){
        NSString *userName = nil;
        NSNumber *userId = nil;
        NSMutableString *str = [NSMutableString stringWithString:tmpStr];
        if ([[likeList objectAtIndex:i] isKindOfClass:[NSNumber class]]) {
            userName = user.nickname;
            userId = @(user.userId);
        }else{
            TXComment *like = [likeList objectAtIndex:i];
            userName = like.userNickname;
            userId = @(like.userId);
        }
        
        if (i > 9) {
            break;
        }else if (i != 9) {
            i == 0?[str appendFormat:@"%@,",userName]:[str appendFormat:@"%@,",userName];
            tmpStr = str;
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            if (userName) {
                [dict setValue:userName forKey:@"name"];
            }
            if (userId) {
                [dict setValue:userId forKey:@"userId"];
            }
            [tmpArr addObject:dict];
        }else{
            [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
            [str appendString:@"等,"];
            tmpStr = str;
        }
    }
    
    if (tmpStr.length) {
        [tmpStr deleteCharactersInRange:NSMakeRange(tmpStr.length - 1, 1)];
    }

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:tmpStr];
    [text nimbuskit_setTextColor:kColorGray];
    [text nimbuskit_setFont:font];
    
    NIAttributedLabel *likeLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectZero];
    likeLabel.numberOfLines = 0;
    likeLabel.textColor = kColorGray;
    likeLabel.lineBreakMode = NSLineBreakByCharWrapping;
    likeLabel.backgroundColor = kColorClear;
    likeLabel.attributedText = text;
    likeLabel.autoDetectLinks = YES;
    //下划线
    likeLabel.linksHaveUnderlines = NO;
    
    likeSize = [likeLabel sizeThatFits:CGSizeMake(kScreenWidth - 83 - 24, MAXFLOAT)];
    
    int index = 0;
    for (NSDictionary *dic in tmpArr) {
        NSString *name = [dic objectForKey:@"name"];
        NSString *urlString = [NSString stringWithFormat:@"%@;;%@",[dic objectForKey:@"name"],[dic objectForKey:@"userId"]];
        NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)urlString, NULL, NULL,  kCFStringEncodingUTF8 ));
        [likeLabel addLink:[NSURL URLWithString:encodedString] range:NSMakeRange(index, name.length)];
        index += (name.length + 1);
    }
//    CGSize tmpSize = [UILabel contentSizeForLabelWithText:@"测试" maxWidth:MAXFLOAT font:likeLabel.font];
    likeLabel.linkColor = kColorGray1;
    likeLabel.frame = CGRectMake(25, 10.5, likeSize.width, likeSize.height);
    return likeLabel;
}

#pragma mark- 生成图文混排的label
+ (NSMutableArray *)getAttrobuteLabelArr:(TXFeed *)feed
{
    if (!feed.circleComments.count) {
        feed.hasMore = [NSNumber numberWithBool:NO];
        return nil;
    }
    
    if (feed.circleComments.count > 20) {
        feed.hasMore = [NSNumber numberWithBool:YES];
    }
    
    NSError *error = nil;
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
    NSMutableArray *arr = [NSMutableArray array];
    for (id tmpComment in feed.circleComments) {
        NSUInteger index = [feed.circleComments indexOfObject:tmpComment];
        if (index > 19) {
            break;
        }
        NSString *name = @"";
        NSString *comment = nil;
        NSString *replyName = nil;
        NSNumber *userId = nil;
        NSNumber *toUserId = nil;
        if ([tmpComment isKindOfClass:[NSMutableDictionary class]]) {
            NSDictionary *dic = tmpComment;
            name = user.nickname;
            comment = tmpComment[@"comment"];
            userId = @(user.userId);
            replyName = dic[@"userName"];
            toUserId = dic[@"userId"];

        }else{
            TXComment *pbComment = tmpComment;
            name = pbComment.userNickname;
            comment = pbComment.content;
            replyName = pbComment.toUserNickname;
            userId = @(pbComment.userId);
            toUserId = @(pbComment.toUserId);
        }
        
        NSString *text = nil;
        if (replyName && replyName.length) {
            text = [NSString stringWithFormat:@"%@回复%@: %@",name,replyName,comment];
        }else{
            text = [NSString stringWithFormat:@"%@: %@",name,comment];
        }
        
        MLEmojiLabel *commentLabel = [[MLEmojiLabel alloc]init];
        commentLabel.backgroundColor = kColorClear;
        commentLabel.numberOfLines = 0;
        commentLabel.disableThreeCommon = YES;
        commentLabel.font = kFontSubTitle;
        [commentLabel setTextColor:kColorBlack];
        NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
        [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor clearColor] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
        commentLabel.activeLinkAttributes = mutableActiveLinkAttributes;
        [commentLabel setEmojiText:text];
        commentLabel.isNeedAtAndPoundSign = YES;
        commentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        commentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        commentLabel.customEmojiPlistName = @"emotion.plist";
        CGSize size = [commentLabel sizeThatFits:CGSizeMake(kScreenWidth - 86 - 17, MAXFLOAT)];
        commentLabel.frame = CGRectMake(25, 0, kScreenWidth - 86 - 25, size.height + 7);
        commentLabel.feedComment = tmpComment;
        commentLabel.replyUserName = name;
        commentLabel.feed = feed;
        commentLabel.replyUser = userId;
        [commentLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",userId]] withRange:[text rangeOfString:name]];
        
        if (replyName && replyName.length) {
            [commentLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",toUserId]] withRange:NSMakeRange(name.length + 2, replyName.length)];
        }
        [arr addObject:commentLabel];
    }
    return arr;
}

#pragma mark - TXMessageEmotionViewDelegate methods
//发送表情
- (void)sendEmotionText:(NSString *)text
{
    if (text.length > 0) {
        self.msgInputView.inputTextView.text = @"";
        [self sendComment:text];
        [self.msgInputView.inputTextView resignFirstResponder];
    }
}
//发送文字
- (void)didSendTextAction:(NSString *)text {
    //判断是否是空消息
    NSString *trimString = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimString length] == 0) {
        //Alert提醒不能输入空白消息
        [self showFailedHudWithTitle:@"不能发送空白消息"];
    }else{
        //清空已发送文本
        self.msgInputView.inputTextView.text = @"";
        [self sendComment:text];
        [self.msgInputView.inputTextView resignFirstResponder];
    }
}

//底部insets改变
- (void)onBottomInsetsChanged:(CGFloat)bottom
               isShowKeyboard:(BOOL)isShow
{
    [self setTableViewInsetsWithBottomValue:bottom];
    if (isShow)
        [self scrollToBottomAnimated:NO];
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
//    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
//    _listTableView.contentInset = insets;
//    _listTableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.bottom = bottom;
    return insets;
}
- (void)scrollToBottomAnimated:(BOOL)animated {
    //    NSInteger rows = [self.dataSource numberOfMessages];
    //
    //    if (rows > 0) {
    //        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
    //                                     atScrollPosition:UITableViewScrollPositionBottom
    //                                             animated:animated];
    //    }
    //TODO:
    
//    [_listTableView scrollRectToVisible:_tableView.frame animated:YES];
}
#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScrolling = YES;
    [self.msgInputView associatedScrollViewWillBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        self.isScrolling = NO;
        if (_type == RequestType_Header && _tmpListArr.count &&
            ![_tmpListArr containsObject:@""]) {
            [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED];
            self.type = RequestType_None;
//            self.listArr = [NSMutableArray arrayWithArray:_tmpListArr];
            [self updateFeedList:_tmpListArr];
            [self reloadData];
        }else if (_type == RequestType_Footer && _tmpListArr.count &&
                  ![_tmpListArr containsObject:@""]){
            self.type = RequestType_None;
//            [_listArr addObjectsFromArray:_tmpListArr];
            [self addNewFeedList:_tmpListArr];
            [self reloadData];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.isScrolling = NO;
    if (_type == RequestType_Header && _tmpListArr.count &&
        ![_tmpListArr containsObject:@""]) {
        [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF == %@",@""];
        NSArray *arr = [_tmpListArr filteredArrayUsingPredicate:pre];
        if (arr && arr.count) {
            [_tmpListArr removeObjectsInArray:arr];
        }
        NSArray *array1 = [_tmpListArr sortedArrayUsingComparator:cmptr];
//        self.listArr = [NSMutableArray arrayWithArray:array1];
        [self updateFeedList:array1];
        self.type = RequestType_None;
        [self reloadData];
    }else if (_type == RequestType_Footer && _tmpListArr.count &&
              ![_tmpListArr containsObject:@""]){
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF == %@",@""];
        NSArray *arr = [_tmpListArr filteredArrayUsingPredicate:pre];
        if (arr && arr.count) {
            [_tmpListArr removeObjectsInArray:arr];
        }
        NSArray *array1 = [_tmpListArr sortedArrayUsingComparator:cmptr];
//        [_listArr addObjectsFromArray:array1];
        [self addNewFeedList:array1];
        self.type = RequestType_None;
        [self reloadData];
    }
}

- (void)dealloc
{
    [self unSubscribeAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 刷新UI
NSComparator cmptr = ^(TXFeed *feed1, TXFeed *feed2){
    if (feed1.createdOn > feed2.createdOn) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    
    if (feed1.createdOn < feed2.createdOn) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = UIImageJPEGRepresentation(image, 0.2);
            //获取时间
            UIImage *retImage = [UIImage imageWithData:data];
            //判断picker的sourceType，如果是拍照则保存到相册去
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIImage *saveImage;
                if (editingInfo) {
                    saveImage = [editingInfo objectForKey:UIImagePickerControllerOriginalImage];
                }else{
                    saveImage = image;
                }
                UIImageWriteToSavedPhotosAlbum(saveImage, self, nil, nil);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                CirclePublishViewController *avc = [[CirclePublishViewController alloc] init];
                avc.photoItemsArr = [NSMutableArray arrayWithObject:retImage];
                [self.navigationController pushViewController:avc animated:YES];
            });
        });
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    [picker dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = UIImageJPEGRepresentation(image, 0.2);
            //获取时间
            UIImage *retImage = [UIImage imageWithData:data];
            //判断picker的sourceType，如果是拍照则保存到相册去
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                CirclePublishViewController *avc = [[CirclePublishViewController alloc] init];
                avc.photoItemsArr = [NSMutableArray arrayWithObject:retImage];
                [self.navigationController pushViewController:avc animated:YES];
            });
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self showImageDropdownViewWithoutAnimation];
}

#pragma mark - TXImagePickerControllerDelegate
- (void)imagePickerController:(TXImagePickerController *)picker didFinishPickingImages:(NSArray *)imageArray{
//    NSLog(@"%@",imageArray);
    [super didFinishImagePicker:picker];
    CirclePublishViewController *avc = [[CirclePublishViewController alloc] init];
    avc.photoItemsArr = [NSMutableArray arrayWithArray:imageArray];
    
    [self.navigationController pushViewController:avc animated:YES];
}

- (void)imagePickerControllerDidCancelled:(TXImagePickerController *)picker{
    [self showImageDropdownViewWithoutAnimation];
}

- (void)showImageDropdownViewWithoutAnimation{
    self.btnRight.selected = YES;
    _coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0.6);
    _selectView.maxY = _selectHeight;
    _coverView.hidden = NO;
}

@end
