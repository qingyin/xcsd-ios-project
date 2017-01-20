//
//  MobileViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MobileViewController.h"
#import "UpdateMobileViewController.h"

@interface MobileViewController ()
{
    UILabel *_mobileLb;
}

@end

@implementation MobileViewController

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRefreshUserInfo:) name:kRefreshUseInfo object:nil];
    }
    return self;
}

- (void)onRefreshUserInfo:(NSNotification *)notification{
    NSError *error = nil;
    TXUser *txUser = [[TXChatClient sharedInstance] getCurrentUser:&error];
    _mobileLb.text = txUser.mobilePhoneNumber;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"绑定手机号";
    [self createCustomNavBar];
    
    UIView *mobileView = [[UIView alloc] initWithFrame:CGRectMake(10, self.customNavigationView.maxY + 20, self.view.width_ - 20, 45)];
    mobileView.layer.borderWidth = kLineHeight;
    mobileView.layer.borderColor = kColorLine.CGColor;
    mobileView.backgroundColor = kColorWhite;
    [self.view addSubview:mobileView];
    
    UILabel *label = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    label.text = @"当前手机号";
    label.textAlignment = NSTextAlignmentLeft;
    label.font = kFontMiddle;
    label.textColor = kColorGray;
    [mobileView addSubview:label];
    label.frame = CGRectMake(10, 0, mobileView.width_, mobileView.height_);
    
    NSError *error = nil;
    TXUser *txUser = [[TXChatClient sharedInstance] getCurrentUser:&error];
    _mobileLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    _mobileLb.text = txUser.mobilePhoneNumber;
    _mobileLb.textAlignment = NSTextAlignmentRight;
    _mobileLb.font = kFontMiddle;
    _mobileLb.textColor = kColorGray;
    [mobileView addSubview:_mobileLb];
    _mobileLb.frame = CGRectMake(10, 0, mobileView.width_ - 20 , mobileView.height_);
    
    UILabel *tipsLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    tipsLb.font = kFontSmall;
    tipsLb.textColor = kColorGray;
    tipsLb.text = @"手机号可用于登录和修改密码。";
    [self.view addSubview:tipsLb];
    [tipsLb sizeToFit];
    tipsLb.frame = CGRectMake(mobileView.minX, mobileView.maxY + 5, tipsLb.width_, tipsLb.height_);
    
    UIButton *updateMobileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    updateMobileBtn.frame = CGRectMake(13, tipsLb.maxY + 10, self.view.width_ - 26, 40);
    updateMobileBtn.titleLabel.font = kFontLarge_1_b;
    updateMobileBtn.backgroundColor = KColorAppMain;
    updateMobileBtn.layer.cornerRadius = 5.f;
    updateMobileBtn.layer.masksToBounds = YES;
    [updateMobileBtn setTitle:@"更换手机号" forState:UIControlStateNormal];
    [updateMobileBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.view addSubview:updateMobileBtn];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    [updateMobileBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        UpdateMobileViewController *presentViewController = [[UpdateMobileViewController alloc] init];
        presentViewController.mobileVC = self;
        [tmpObject.navigationController pushViewController:presentViewController animated:YES];
    }];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
