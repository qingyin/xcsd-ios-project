//
//  BaseViewController.m
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "NoNetworkViewController.h"
#import "UILabel+ContentSize.h"
#import "TXCustomAlertWindow.h"
#import "MedicineDetailViewController.h"
#import "ParentsDetailViewController.h"
#import "GroupDetailViewController.h"
#import "HomeViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "CircleHomeViewController.h"
#import "TXParentChatViewController.h"
#import <MMPopupView/MMSheetView.h>
#import <MMPopupView/MMPopupItem.h>
#import <MMPopupView/MMPopupWindow.h>
#import <TXDatePopView.h>
#import <UMOnlineConfig.h>
#import "XCSDDataProto.pb.h"
#import "TXChatClient+Deprecated.h"

@interface BaseViewController ()
<TXImagePickerControllerDelegate>
{
    UIView *_connectView;           //网络状态视图
    UIImageView *_noDataImage;//无数据时显示的默认图
    UILabel *_noDataLabel;//无数据时显示的默认提示语
}

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;

@end

@implementation BaseViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)init{
    self = [super init];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReachabilityStatus:) name:kReachabilityStatus object:nil];
        _navigationBarViewType = NavigationBarTitleViewType;
        _shouldLimitTitleLabelWidth = NO;
        
//        _event = [[XCSDPBEvent alloc] init];
    }
    return self;
}

//网络状态
- (void)onReachabilityStatus:(NSNotification *)notification{
    NSDictionary *dic = notification.object;
    BOOL isConnected = [dic[@"status"] boolValue];
    if (_titleLb && ![_titleLb.text isEqualToString:@"无法连接网络"]) {
        _titleLb.text = isConnected?_titleStr:@"网络未连接";
        if (_connectView) {
            [self.view bringSubviewToFront:_connectView];
            [self.view bringSubviewToFront:_customNavigationView];
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _connectView.minY = isConnected?_customNavigationView.maxY - 44:_customNavigationView.maxY;
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if(self.umengEventText && self.umengEventText.length > 0)
    {
        [MobClick beginLogPageView:self.umengEventText];
    }
    else
    {
        [MobClick beginLogPageView:_titleStr];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.umengEventText && self.umengEventText.length > 0)
    {
        [MobClick endLogPageView:self.umengEventText];
    }
    else{
        [MobClick endLogPageView:_titleStr];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColorBackground;
    // Do any additional setup after loading the view.
    //设置Sheet配置
    [self setupSheetConfigure];
    //禁止滑动返回
    NSString *gesturePopValue = [UMOnlineConfig getConfigParams:@"gesturePop"];
    if (gesturePopValue) {
        self.fd_interactivePopDisabled = [gesturePopValue boolValue];
    }
    //    self.fd_interactivePopDisabled = YES;
}
//添加控件
-(void)addEmptyDataImage:(BOOL)isSupportCreateMsg  showMessage:(NSString *)showMessage
{
    NSString *imageName = @"noedit_default_icon";
//    if(isSupportCreateMsg)
//    {
//        imageName = @"edit_default_icon";
//    }
    _noDataImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    if(isSupportCreateMsg)
    {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewTapEvent:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.cancelsTouchesInView = NO;
        _noDataImage.userInteractionEnabled = YES;
        [_noDataImage addGestureRecognizer:tap];
    }
    [self.view addSubview:_noDataImage];
    CGFloat imageHight = _noDataImage.image.size.height;
    CGFloat margin = 13.0f;
    CGFloat txtHight = 31.0f;
    
    [_noDataImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.centerY.mas_equalTo(self.view).with.offset(+self.customNavigationView.maxY - (imageHight + margin + txtHight)/2);
//        make.top.mas_equalTo(self.view.mas_top).with.offset(self.customNavigationView.maxY + 110);
        make.size.mas_equalTo(_noDataImage.image.size);
    }];
    [_noDataImage setHidden:YES];
    _noDataLabel = [UILabel new];
    [_noDataLabel setFont:kFontLarge];
    [_noDataLabel setTextColor:RGBCOLOR(0xd1, 0xd1, 0xd1)];
    [_noDataLabel setBackgroundColor:[UIColor clearColor]];
    if(showMessage != nil && [showMessage length] > 0)
    {
        [_noDataLabel setText:showMessage];
    }
    else
    {
        [_noDataLabel setText:@""];
    }
    [_noDataLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_noDataLabel];
    [_noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_noDataImage);
        make.top.mas_equalTo(_noDataImage.mas_bottom).with.offset(margin);
        make.size.mas_equalTo(CGSizeMake(300, txtHight));
    }];
    [_noDataLabel setHidden:YES];

}

// 更新无数据的文字显示
- (void)updateEmptyDataText: (NSString *)text{
    
    if (_noDataLabel.hidden || _noDataImage.hidden) {
        
        [self updateEmptyDataImageStatus:YES];
    }
    
    [_noDataLabel setText:text];
}

//更新隐藏显示状态
-(void)updateEmptyDataImageStatus:(BOOL)isShow
{
    [_noDataImage setHidden:!isShow];
    [_noDataImage layoutIfNeeded];
    [_noDataLabel setHidden:!isShow];
}

//更新隐藏显示状态 和显示提示语
-(void)updateEmptyDataImageStatusAndTitle:(BOOL)isShow newShowTitle:(NSString *)title
{
    [_noDataImage setHidden:!isShow];
    [_noDataImage layoutIfNeeded];
    [_noDataLabel setHidden:!isShow];
    if(title && [title length] > 0)
    {
        _noDataLabel.text = title;
    }
}

//点击图片后处理
-(void)ImageViewTapEvent:(UITapGestureRecognizer*)recognizer
{
    
}

- (UIActivityIndicatorView *)loadingIndicatorView
{
    if (!_loadingIndicatorView) {
        _loadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loadingIndicatorView.center = _customNavigationView.center;
        [_customNavigationView addSubview:_loadingIndicatorView];
    }
    return _loadingIndicatorView;
}
- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    _titleLb.text = _titleStr;
    if (_navigationBarViewType == NavigationBarLoadingViewType) {
        //设置位置
        CGFloat width = [UILabel widthForLabelWithText:_titleStr maxHeight:kNavigationHeight font:kFontSuper_b];
        self.loadingIndicatorView.center = CGPointMake(_customNavigationView.width_ / 2 - width / 2 - 20, _customNavigationView.height_ - kNavigationHeight / 2);
    }
}
- (void)setNavigationBarViewType:(NavigationBarViewType)type
{
    if (_navigationBarViewType == type) {
        return;
    }
    _navigationBarViewType = type;
    if (_navigationBarViewType == NavigationBarTitleViewType) {
        [self.loadingIndicatorView stopAnimating];
        self.loadingIndicatorView.hidden = YES;
    }else if (_navigationBarViewType == NavigationBarLoadingViewType) {
        [self.loadingIndicatorView startAnimating];
        self.loadingIndicatorView.hidden = NO;
        //设置位置
        CGFloat width = [UILabel widthForLabelWithText:_titleStr maxHeight:kNavigationHeight font:kFontSuper_b];
        self.loadingIndicatorView.center = CGPointMake(_customNavigationView.width_ / 2 - width / 2 - 20, _customNavigationView.height_ - kNavigationHeight / 2);
    }
}
- (void)createCustomNavBar{
    CGFloat navHeight = IOS7_OR_LATER?kNavigationHeight + kStatusBarHeight:kNavigationHeight;
//    self.customNavigationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, navHeight)];
//    _customNavigationView.userInteractionEnabled = YES;
//    _customNavigationView.contentMode = UIViewContentModeScaleAspectFill;
//    _customNavigationView.clipsToBounds = YES;
//    _customNavigationView.image = [UIImage imageNamed:@"navBar"];
//    [self.view addSubview:_customNavigationView];
    self.customNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, navHeight)];
    _customNavigationView.backgroundColor = [UIColor whiteColor];
    _customNavigationView.userInteractionEnabled = YES;
//    _customNavigationView.clipsToBounds = YES;
    [self.view addSubview:_customNavigationView];

    [self createConnectView];
    
    CGFloat segmentWidth = 100;
    
    // 左按钮
    _btnLeft = [[CustomButton alloc] initWithFrame:CGRectMake(0, _customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight)];
    _btnLeft.showBackArrow = YES;
    _btnLeft.tag = TopBarButtonLeft;
    _btnLeft.adjustsImageWhenHighlighted = NO;
    _btnLeft.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnLeft.titleLabel.font = kFontMiddle;
    _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kEdgeInsetsLeft - 4, 0, 0);
    _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kEdgeInsetsLeft, 0, 0);
    _btnLeft.exclusiveTouch = YES;
    [_btnLeft setTitle:@"返回" forState:UIControlStateNormal];
    [_btnLeft addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnLeft setTitleColor:ColorNavigationTitle forState:UIControlStateNormal];
    [_btnLeft setTitleColor:ColorNavigationTitle forState:UIControlStateDisabled];
    [_customNavigationView addSubview:_btnLeft];
    // 右按钮
    _btnRight = [[CustomButton alloc] initWithFrame:CGRectMake(_customNavigationView.width_ - segmentWidth, _customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight)];
    _btnRight.showBackArrow = NO;
    _btnRight.tag = TopBarButtonRight;
    _btnRight.adjustsImageWhenHighlighted = NO;
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _btnRight.titleLabel.font = kFontMiddle;
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft);
    _btnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft);
    _btnRight.exclusiveTouch = YES;
    [_btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRight setTitleColor:ColorNavigationTitle forState:UIControlStateNormal];
    [_btnRight setTitleColor:kColorGray forState:UIControlStateDisabled];
    [_customNavigationView addSubview:_btnRight];
    
    _titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, _customNavigationView.width_ - _btnLeft.width_ - _btnRight.width_, kNavigationHeight)];
    _titleLb.frame = CGRectMake(0, 0,_shouldLimitTitleLabelWidth ? _customNavigationView.width_ - _btnLeft.width_ - _btnRight.width_ : _customNavigationView.width_, kNavigationHeight);
    _titleLb.center = CGPointMake(_customNavigationView.center.x, _customNavigationView.height_ - kNavigationHeight / 2);
    _titleLb.font = KNavFontSize;
    _titleLb.textColor = kColorNavigationTitle;
    _titleLb.textAlignment = NSTextAlignmentCenter;
    [_customNavigationView addSubview:_titleLb];
    //添加分割线
    self.barLineView = [[UIView alloc] initWithFrame:CGRectMake(0, _customNavigationView.maxY - 0.5, _customNavigationView.width_, 0.5)];
    _barLineView.backgroundColor = RGBCOLOR(0xd8, 0xd8, 0xd8);
    [_customNavigationView addSubview:_barLineView];
    //设置内容
    _titleLb.text = _titleStr;
}
- (void)setupDarkModeNavigationBar
{
    self.view.backgroundColor = RGBCOLOR(3, 3, 3);
    CGFloat navHeight = IOS7_OR_LATER?kNavigationHeight + kStatusBarHeight:kNavigationHeight;
    self.customNavigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, navHeight)];
    _customNavigationView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
    _customNavigationView.userInteractionEnabled = YES;
    //    _customNavigationView.clipsToBounds = YES;
//    _customNavigationView.hidden = YES;
    [self.view addSubview:_customNavigationView];
    
    CGFloat segmentWidth = 100;
    
    // 左按钮
    _btnLeft = [[CustomButton alloc] initWithFrame:CGRectMake(0, _customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight)];
    _btnLeft.showBackArrow = NO;
    _btnLeft.tag = TopBarButtonLeft;
    _btnLeft.adjustsImageWhenHighlighted = NO;
    _btnLeft.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _btnLeft.titleLabel.font = kFontMiddle;
    _btnLeft.titleEdgeInsets = UIEdgeInsetsMake(0, kEdgeInsetsLeft + 5, 0, 0);
    _btnLeft.imageEdgeInsets = UIEdgeInsetsMake(0, kEdgeInsetsLeft, 0, 0);
    _btnLeft.exclusiveTouch = YES;
    [_btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [_btnLeft addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnLeft setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_btnLeft setTitleColor:kColorGray forState:UIControlStateDisabled];
    [_customNavigationView addSubview:_btnLeft];
    // 右按钮
    _btnRight = [[CustomButton alloc] initWithFrame:CGRectMake(_customNavigationView.width_ - segmentWidth, _customNavigationView.height_ - kNavigationHeight, segmentWidth, kNavigationHeight)];
    _btnRight.showBackArrow = NO;
    _btnRight.tag = TopBarButtonRight;
    _btnRight.adjustsImageWhenHighlighted = NO;
    _btnRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _btnRight.titleLabel.font = kFontMiddle;
    _btnRight.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft);
    _btnRight.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kEdgeInsetsLeft);
    _btnRight.exclusiveTouch = YES;
    [_btnRight addTarget:self action:@selector(onClickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRight setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_btnRight setTitleColor:kColorGray forState:UIControlStateDisabled];
    [_customNavigationView addSubview:_btnRight];
    
    _titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, _customNavigationView.width_ - _btnLeft.width_ - _btnRight.width_, kNavigationHeight)];
    _titleLb.frame = CGRectMake(0, 0,_shouldLimitTitleLabelWidth ? _customNavigationView.width_ - _btnLeft.width_ - _btnRight.width_ : _customNavigationView.width_, kNavigationHeight);
    _titleLb.center = CGPointMake(_customNavigationView.center.x, _customNavigationView.height_ - kNavigationHeight / 2);
    _titleLb.font = KNavFontSize;
    _titleLb.textColor = kColorWhite;
    _titleLb.textAlignment = NSTextAlignmentCenter;
    [_customNavigationView addSubview:_titleLb];
    //设置内容
    _titleLb.text = _titleStr;
}
- (void)createConnectView{
    _connectView = [[UIView alloc] initWithFrame:CGRectMake(0,_customNavigationView.maxY - 44, _customNavigationView.width_, 44)];
    _connectView.backgroundColor = [UIColor redColor];
    [self.view insertSubview:_connectView belowSubview:_customNavigationView];
    
    UILabel *connectLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(0, 0, _connectView.width_, _connectView.height_)];
    connectLb.font = kFontNormal;
    connectLb.textAlignment = NSTextAlignmentCenter;
    connectLb.textColor = kColorWhite;
    connectLb.text = @"无法连接服务器，请检查您的网络";
    [_connectView addSubview:connectLb];
    
    UIButton *connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    connectBtn.frame = connectLb.frame;
    [_connectView addSubview:connectBtn];
    WEAKSELF
    [connectBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        NoNetworkViewController *avc = [[NoNetworkViewController alloc] init];
        STRONGSELF
        [strongSelf.navigationController pushViewController:avc animated:YES];
    }];
}

- (void)onClickBtn:(UIButton *)sender{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 毛玻璃模糊效果
/**
 *  添加毛玻璃模糊效果到view上
 *
 *  @param view 需要添加毛玻璃效果的view
 */
- (void)addVisualEffectToView:(UIView *)view
{
    if (IOS8AFTER) {
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = view.bounds;
        [view addSubview:visualEffectView];
        [view addSubview:visualEffectView];
    }
}
#pragma mark - Alert弹窗
- (void)showAlertViewWithMessage:(NSString *)message andButtonItems:(ButtonItem *)buttonItem, ...{
    va_list args;
    va_start(args, buttonItem);
    
    NSMutableArray *buttonsArray = [NSMutableArray array];
    if(buttonItem)
    {
        [buttonsArray addObject:buttonItem];
        ButtonItem *nextItem;
        while((nextItem = va_arg(args, ButtonItem *)))
        {
            [buttonsArray addObject:nextItem];
        }
    }
    va_end(args);
    [self.view showAlertViewWithMessage:message andButtonItemsArr:buttonsArray];
}
//屏蔽特定error的弹窗
- (void)showAlertViewWithError:(NSError *)error andButtonItems:(ButtonItem *)buttonItem, ...{
    va_list args;
    va_start(args, buttonItem);
    
    NSMutableArray *buttonsArray = [NSMutableArray array];
    if(buttonItem)
    {
        [buttonsArray addObject:buttonItem];
        ButtonItem *nextItem;
        while((nextItem = va_arg(args, ButtonItem *)))
        {
            [buttonsArray addObject:nextItem];
        }
    }
    va_end(args);
    [self.view showAlertViewWithError:error andButtonItemsArr:buttonsArray];
}
#pragma mark - 底部弹出框Sheet
- (void)setupSheetConfigure
{
    [[MMPopupWindow sharedWindow] cacheWindow];
    [MMPopupWindow sharedWindow].touchWildToHide = YES;
    
    MMSheetViewConfig *sheetConfig = [MMSheetViewConfig globalConfig];
    sheetConfig.splitColor = RGBCOLOR(236, 237, 239);
    sheetConfig.itemNormalColor = RGBCOLOR(0x44, 0x44, 0x44);
    sheetConfig.defaultTextCancel = @"取消";
}
//弹出普通的Sheet框
- (void)showNormalSheetWithTitle:(NSString *)title
                           items:(NSArray *)items
                    clickHandler:(void(^)(NSInteger index))handler
                      completion:(void(^)(void))completion
{
    //    MMPopupItemHandler block = ^(NSInteger index){
    //        NSLog(@"clickd %@ button",@(index));
    //    };
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
        if (completion) {
            completion();
        }
    };
    NSMutableArray *popItems = [NSMutableArray array];
    [items enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        MMPopupItem *item = MMItemMake(obj, MMItemTypeNormal, handler);
        [popItems addObject:item];
    }];
    //弹出视图
    [[[MMSheetView alloc] initWithTitle:title
                                  items:popItems] showWithBlock:completeBlock];
}
//弹出带高亮的Sheet框
- (void)showHighlightedSheetWithTitle:(NSString *)title
                          normalItems:(NSArray *)normalItems
                     highlightedItems:(NSArray *)highlightedItems
                           otherItems:(NSArray *)otherItems
                         clickHandler:(void(^)(NSInteger index))handler
                           completion:(void(^)(void))completion
{
//    MMPopupItemHandler block = ^(NSInteger index){
//        NSLog(@"clickd %@ button",@(index));
//    };
    MMPopupBlock completeBlock = ^(MMPopupView *popupView){
        if (completion) {
            completion();
        }
    };
    NSMutableArray *popItems = [NSMutableArray array];
    [normalItems enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        MMPopupItem *item = MMItemMake(obj, MMItemTypeNormal, handler);
        [popItems addObject:item];
    }];
    [highlightedItems enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        MMPopupItem *item = MMItemMake(obj, MMItemTypeHighlight, handler);
        [popItems addObject:item];
    }];
    [otherItems enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        MMPopupItem *item = MMItemMake(obj, MMItemTypeNormal, handler);
        [popItems addObject:item];
    }];
    //弹出视图
    [[[MMSheetView alloc] initWithTitle:title
                                  items:popItems] showWithBlock:completeBlock];
}
//弹出日期选择框
- (void)showDatePickerWithCurrentDate:(NSDate *)currentDate
                          minimumDate:(NSDate *)minimumDate
                          maximumDate:(NSDate *)maximumDate
                         selectedDate:(NSDate *)selectedDate
                        selectedBlock:(void(^)(NSDate *selectedDate))selectedBlcok
{
    TXDatePopView *dateView = [TXDatePopView new];
    [dateView setPickerCurrentDate:currentDate minimumDate:minimumDate maximumDate:maximumDate selectedDate:selectedDate selectedBlock:selectedBlcok];
    [dateView showWithBlock:nil];
}
#pragma mark - 图片选择组件
//弹出图片选择器
- (void)showImagePickerController
{
    [self showImagePickerControllerWithCurrentSelectedCount:0];
}
//根据当前已选择的数量弹出图片选择器
- (void)showImagePickerControllerWithCurrentSelectedCount:(NSInteger)count
{
    [self showImagePickerControllerWithMaxSelectionNumber:9 currentSelectedCount:count];
}
//根据当前已选择的数量和最大数量弹出图片选择器
- (void)showImagePickerControllerWithMaxSelectionNumber:(NSInteger)maxCount
                                   currentSelectedCount:(NSInteger)currentCount
{
    [self showImagePickerControllerMaxSelectionNumber:maxCount currentSelectedCount:currentCount animation:YES completion:nil];
}
//根据各个属性弹出图片选择器
- (void)showImagePickerControllerMaxSelectionNumber:(NSInteger)maxCount
                               currentSelectedCount:(NSInteger)currentCount
                                          animation:(BOOL)flag
                                         completion:(void(^)(void))completion
{
    TXImagePickerController *imagePicker = [[TXImagePickerController alloc] init];
    imagePicker.maxSelectionNumber = maxCount;
    imagePicker.currentSelectedCount = currentCount;
    imagePicker.delegate = self;
    [imagePicker showImagePickerBy:self animated:flag completion:completion];
}
//隐藏HUD视图
- (void)hideImagePickerControllerHUD:(TXImagePickerController *)picker
{
    UIView *contentView = [picker currentViewContent];
    [MBProgressHUD hideHUDForView:contentView animated:YES];
}
//弹出超过图片最大选择数的提示HUD
- (void)showReachImageMaxSelectionTipHUD:(TXImagePickerController *)picker
{
    UIView *contentView = [picker currentViewContent];
    MBProgressHUD *failedHud = [[MBProgressHUD alloc] initWithView:contentView];
    failedHud.mode = MBProgressHUDModeNone;
    failedHud.labelText = [NSString stringWithFormat:@"最多只能选择%@张图片",@(picker.maxSelectionNumber)];
    [contentView addSubview:failedHud];
    [failedHud show:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [failedHud hide:YES];
    });
}
//选取图片结束
- (void)didFinishImagePicker:(TXImagePickerController *)picker
{
    [self hideImagePickerControllerHUD:picker];
    [picker dismissImagePickerControllerWithAnimated:YES];
}
#pragma mark - TXImagePickerControllerDelegate
- (void)imagePickerControllerStartProcessingImages:(TXImagePickerController *)picker
{
    UIView *contentView = [picker currentViewContent];
    [MBProgressHUD showHUDAddedTo:contentView animated:YES];
}
- (void)imagePickerController:(TXImagePickerController *)picker didFinishPickingImages:(NSArray *)imageArray
{
    [self didFinishImagePicker:picker];
}
- (void)imagePickerControllerDidCancelled:(TXImagePickerController *)picker
{
    [self didFinishImagePicker:picker];
}
- (void)imagePickerControllerReachMaxSelectNumber:(TXImagePickerController *)picker
{
    [self showReachImageMaxSelectionTipHUD:picker];
}
#pragma mark - 权限弹窗
//显示权限弹窗
- (void)showPermissionAlertWithCameraGranted:(BOOL)isGrantCamera
                           microphoneGranted:(BOOL)isGrantMacrophone
{
    ButtonItem *setItem = [ButtonItem itemWithLabel:@"去设置" andTextColor:kColorBlack action:^{
        TXAsyncRunInMain(^{
            if(__IOS8)
            {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            }
        });
    }];
    NSString *alertTitle;
    if (!isGrantCamera && !isGrantMacrophone) {
        alertTitle = @"没有权限访问您的相机和麦克风,请到“设置-隐私-相机/麦克风”里把“乐学堂”的开关打开即可";
    }else if (isGrantCamera && !isGrantMacrophone) {
        alertTitle = @"没有权限访问您的麦克风,请到“设置-隐私-麦克风”里把“乐学堂”的开关打开即可";
    }else if (isGrantMacrophone && !isGrantCamera) {
        alertTitle = @"没有权限访问您的相机,请到“设置-隐私-相机”里把“乐学堂”的开关打开即可";
    }
    [self showAlertViewWithMessage:alertTitle andButtonItems:setItem, nil];
}
//显示相册权限弹窗
- (void)showPhotoPermissionDeniedAlert
{
    
    ButtonItem *setItem = [ButtonItem itemWithLabel:@"去设置" andTextColor:kColorBlack action:^{
        TXAsyncRunInMain(^{
            
            if(__IOS8)
            {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root"]];
            }
        });
    }];
    NSString *alertTitle = @"没有权限访问您的照片,请到“设置-隐私-照片”里把“乐学堂”的开关打开";
    [self showAlertViewWithMessage:alertTitle andButtonItems:setItem, nil];
}
#pragma mark - Toast弹窗
- (void)showSuccessHudWithTitle:(NSString *)title
{
    [self showSuccessHudWithTitle:title showSuccessImage:NO];
}
- (void)showSuccessHudWithTitle:(NSString *)title
               showSuccessImage:(BOOL)showSuccessImage
{
    //动画
    MBProgressHUD *finishHud = [[MBProgressHUD alloc] initWithView:self.view];
//    finishHud.layer.cornerRadius = 5.f;
//    finishHud.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
//    [self.view addSubview:finishHud];
    [[TXCustomAlertWindow sharedWindow] showWithView:finishHud];
    
    if (showSuccessImage) {
        finishHud.mode = MBProgressHUDModeCustomView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_complete"]];
        finishHud.customView = imageView;
    }else{
        finishHud.mode = MBProgressHUDModeNone;
    }
    
    //    finishHud.delegate = self;
    finishHud.labelText = title;
    
    [finishHud show:YES];
//    [finishHud hide:YES afterDelay:1.5f];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [finishHud hide:YES];
        [[TXCustomAlertWindow sharedWindow] hide];
    });
}
//展示失败动画
- (void)showFailedHudWithError:(NSError *)error
{
    NSString *message = error.userInfo[kErrorMessage];
    NSString *msgWithCode = nil;
    if(error.code > 0)
    {
        msgWithCode = [NSString stringWithFormat:@"%@(%@)",message, @(error.code)];
    }
    else
    {
        msgWithCode = message;
    }
    [self showFailedHudWithTitle:msgWithCode showSuccessImage:NO];
}
- (void)showFailedHudWithTitle:(NSString *)title
{
    [self showFailedHudWithTitle:title showSuccessImage:NO];
}
//展示失败动画
- (void)showFailedHudWithTitle:(NSString *)title
              showSuccessImage:(BOOL)showSuccessImage
{
    MBProgressHUD *failedHud = [[MBProgressHUD alloc] initWithView:self.view];
//    failedHud.layer.cornerRadius = 5.f;
//    failedHud.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
//    [self.view addSubview:failedHud];
    [[TXCustomAlertWindow sharedWindow] showWithView:failedHud];
    
    //    finishHud.customView = customView;
    if (showSuccessImage) {
        failedHud.mode = MBProgressHUDModeCustomView;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_failed"]];
        failedHud.customView = imageView;
    }else{
        failedHud.mode = MBProgressHUDModeNone;
    }
    
    //    finishHud.delegate = self;
    failedHud.labelText = title;
    
    [failedHud show:YES];
//    [failedHud hide:YES afterDelay:1.5f];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [failedHud hide:YES];
        [[TXCustomAlertWindow sharedWindow] hide];
    });
}


- (void)reportEvent:(XCSDPBEventType)eventType bid:(NSString *)bid {
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KDataReport object:@ {KDataReport : event}];
    [[TXChatClient sharedInstance].dataReportManager reportEventBid:eventType bid:bid];
}

@end

@implementation CustomButton

- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    if (self.showBackArrow) {
        [self setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    }else{
        [self setImage:nil forState:UIControlStateNormal];
    }
    [super setTitle:title forState:state];
}

@end



