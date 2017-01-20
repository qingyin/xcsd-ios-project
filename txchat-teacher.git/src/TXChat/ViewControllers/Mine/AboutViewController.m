//
//  AboutViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/5.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "AboutViewController.h"
#import "TXSystemManager.h"

#define KAboutBgColor RGBCOLOR(0xf3, 0xf3, 0xf3)
#define KAboutTxtColor RGBCOLOR(0x60, 0x60, 0x60)
@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.titleStr = @"关于";
    [self createCustomNavBar];
    self.view.backgroundColor = KAboutBgColor;
    // Do any additional setup after loading the view.
    [self setupView];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
//    self.customNavigationView.image = nil;
    self.customNavigationView.backgroundColor = [UIColor clearColor];
    self.barLineView.hidden = YES;
    self.customNavigationView.backgroundColor = KAboutBgColor;
}



-(void)setupView
{
    UIImage *img = [UIImage imageNamed:@"about_appIcon"];
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tipView];
    
    //公司 图标
    UIImageView *imageView = [UIImageView new];
    [imageView setImage:img];
    imageView.frame = CGRectMake((kScreenWidth - img.size.width)/2, 0, img.size.width, img.size.height);
    [tipView addSubview:imageView];
    
    //版本号
    UILabel *versionLabel = [UILabel new];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *app_buildVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    if([TXSystemManager sharedManager].isDevVersion)
    {
        versionLabel.text = [NSString stringWithFormat:@"版本号:%@ (build:%@)" ,app_Version, app_buildVersion] ;
    }
    else
    {
        versionLabel.text = [NSString stringWithFormat:@"版本号:%@" ,app_Version] ;
    }
    [versionLabel setFont:kFontSmall];
    [versionLabel setTextColor:KAboutTxtColor];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    [tipView addSubview:versionLabel];
    [versionLabel sizeToFit];
    versionLabel.frame = CGRectMake(0, imageView.maxY + 10, kScreenWidth, versionLabel.height_);
    
    tipView.frame = CGRectMake(0, 0, kScreenWidth, versionLabel.maxY);
    tipView.centerY = self.view.height_/2 - self.customNavigationView.maxY;
//    tipView.minY = self.customNavigationView.maxY + 96*kScale;
    
//    //显示devicetoken
//    UILabel *devicetokenLabel = [UILabel new];
//    [devicetokenLabel setFont:kFontSmall];
//    [devicetokenLabel setTextColor:kColorWhite];
//    devicetokenLabel.text = [USER_DEFAULT objectForKey:KDeviceTokenKey];
//    [devicetokenLabel setTextAlignment:NSTextAlignmentCenter];
//    [self.view addSubview:devicetokenLabel];
//    [devicetokenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(tipView.mas_bottom).with.offset(10);
//        make.centerX.mas_equalTo(self.view);
//        make.width.equalTo(self.view);
//        make.height.equalTo(@44);
//    }];
    
    //公司
    UILabel *companyLabel = [UILabel new];
    [companyLabel setFont:kFontChildSection];
    [companyLabel setTextColor:KAboutTxtColor];
    companyLabel.text = @"北京携成尚德教育科技有限责任公司";
    [companyLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:companyLabel];
    CGFloat bottomMargin = 17.0f;
    [companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-bottomMargin);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 44));
    }];
    
}


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
