//
//  IdentityViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/4.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "IdentityViewController.h"
#import "SelectIdentityViewController.h"
#import "NSString+ParentType.h"
#import "AppDelegate.h"
#import "TXEaseMobHelper.h"
#import "TXSystemManager.h"
#import "AppDelegate.h"
#import "EditViewController.h"
#import "NSDate+TuXing.h"
#import "TXContactManager.h"

#define kIdentityBaseTag            12231231

@interface IdentityViewController ()
{
    UIScrollView *_mainView;
    UILabel *_identilyDetailLb;
}

@property (nonatomic, assign) NSInteger selectedType;
@property (nonatomic, strong) TXUser *childUser;
@property (nonatomic, strong) UILabel *birthdayDetailLb;
@property (nonatomic, strong) UILabel *nameDetailLb;

@end

@implementation IdentityViewController

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"选择身份";
    
    self.selectedType = -1;
    
    [self createCustomNavBar];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_)];
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_mainView];
    
    [self fetchChild];
    
    // Do any additional setup after loading the view.
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)fetchChild{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] fetchChild:^(NSError *error, TXUser *childUser) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
//            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            [tmpObject initView:childUser];
        }
    }];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    if (!_pwd.length) {
        self.btnLeft.hidden = YES;
    }
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)initView:(TXUser *)childUser{
    self.childUser = childUser;
    __block CGFloat Y = 5;
    __weak typeof(self)tmpObject = self;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, Y, kScreenWidth, 45 * 4)];
    bgView.backgroundColor = kColorWhite;
    [_mainView addSubview:bgView];
    
    UILabel *chileLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    chileLb.text = @"小朋友";
    chileLb.textColor = kColorLightGray;
    chileLb.font = kFontMiddle;
    [bgView addSubview:chileLb];
    [chileLb sizeToFit];
    chileLb.frame = CGRectMake(14, 0, chileLb.width_, 45);
    
    UILabel *chileNameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    chileNameLb.text = childUser.realName;
    chileNameLb.textColor = kColorLightGray;
    chileNameLb.font = kFontMiddle;
    [bgView addSubview:chileNameLb];
    [chileNameLb sizeToFit];
    chileNameLb.frame = CGRectMake(bgView.width_ - 14 - chileNameLb.width_, 0, chileNameLb.width_, 45);
    
    [bgView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(14, 45 - kLineHeight, kScreenWidth - 28, kLineHeight)]];
    
    UILabel *birthdayLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    birthdayLb.text = @"孩子生日";
    birthdayLb.textColor = kColorLightGray;
    birthdayLb.font = kFontMiddle;
    [bgView addSubview:birthdayLb];
    [birthdayLb sizeToFit];
    birthdayLb.frame = CGRectMake(14, chileLb.maxY, birthdayLb.width_, 45);
    
    _birthdayDetailLb = [[UILabel alloc] initWithFrame:CGRectMake(0, birthdayLb.minY, kScreenWidth - 35, birthdayLb.height_)];
    _birthdayDetailLb.textAlignment = NSTextAlignmentRight;
    _birthdayDetailLb.font = kFontMiddle;
    _birthdayDetailLb.textColor = kColorBlack;
    [bgView addSubview:_birthdayDetailLb];
    
    UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow"]];
    arrowImgView.frame = CGRectMake(bgView.width_ - 24, 15 + birthdayLb.minY, 10, 15);
    [bgView addSubview:arrowImgView];
    
    UIButton *birthdayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    birthdayBtn.frame = CGRectMake(0, birthdayLb.minY, kScreenWidth, 45);
    [bgView addSubview:birthdayBtn];
    
    [birthdayBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        //选择生日
        NSDate *minDate = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%@", @( [NSDate date].timeIntervalSince1970 - 60 * 60 * 24 * 365*10)] doubleValue]];
        [self showDatePickerWithCurrentDate:[NSDate date] minimumDate:minDate maximumDate:[NSDate date] selectedDate:[NSDate getDateThreeYearsAgo] selectedBlock:^(NSDate *selectedDate) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            if (selectedDate) {
                tmpObject.birthdayDetailLb.text = [dateFormatter stringFromDate: selectedDate];
            }
        }];
    }];

    [bgView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(14, birthdayLb.maxY - kLineHeight, kScreenWidth - 28, kLineHeight)]];

    
    UILabel *identilyLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    identilyLb.text = @"选择身份";
    identilyLb.textColor = kColorLightGray;
    identilyLb.font = kFontMiddle;
    [bgView addSubview:identilyLb];
    [identilyLb sizeToFit];
    identilyLb.frame = CGRectMake(14, birthdayLb.maxY, identilyLb.width_, 45);
    
    _identilyDetailLb = [[UILabel alloc] initWithFrame:CGRectMake(0, identilyLb.minY, kScreenWidth - 35, identilyLb.height_)];
    _identilyDetailLb.textAlignment = NSTextAlignmentRight;
    _identilyDetailLb.font = kFontMiddle;
    _identilyDetailLb.textColor = kColorBlack;
    [bgView addSubview:_identilyDetailLb];

    UIImageView *arrowImgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow"]];
    arrowImgView1.frame = CGRectMake(bgView.width_ - 24, 15 + identilyLb.minY, 10, 15);
    [bgView addSubview:arrowImgView1];

    UIButton *identilyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    identilyBtn.frame = CGRectMake(0, identilyLb.minY, kScreenWidth, 45);
    [bgView addSubview:identilyBtn];

    [identilyBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        SelectIdentityViewController *avc = [[SelectIdentityViewController alloc] init];
        avc.selected = tmpObject.selectedType;
        avc.parentVC = tmpObject;
        [tmpObject.navigationController pushViewController:avc animated:YES];
    }];
    
    [bgView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(14, identilyLb.maxY - kLineHeight, kScreenWidth - 28, kLineHeight)]];

    
    UILabel *nameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    nameLb.text = @"监护人";
    nameLb.textColor = kColorLightGray;
    nameLb.font = kFontMiddle;
    [bgView addSubview:nameLb];
    [nameLb sizeToFit];
    nameLb.frame = CGRectMake(14, identilyLb.maxY, nameLb.width_, 45);
    
    _nameDetailLb = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLb.minY, kScreenWidth - 35, nameLb.height_)];
    _nameDetailLb.textAlignment = NSTextAlignmentRight;
    _nameDetailLb.font = kFontMiddle;
    _nameDetailLb.textColor = kColorGray;
    _nameDetailLb.text = @"请输入真实姓名";
    [bgView addSubview:_nameDetailLb];
    
    UIImageView *arrowImgView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow"]];
    arrowImgView2.frame = CGRectMake(bgView.width_ - 24, 15 + nameLb.minY, 10, 15);
    [bgView addSubview:arrowImgView2];
    
    UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nameBtn.frame = CGRectMake(0, nameLb.minY, kScreenWidth, 45);
    [bgView addSubview:nameBtn];
    
    [nameBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        //填写监护人
        EditViewController *avc = [[EditViewController alloc] init];
        if (![tmpObject.nameDetailLb.text isEqualToString:@"请输入真实姓名"]) {
            avc.name = tmpObject.nameDetailLb.text;
        }
        avc.presentVC = self;
        [tmpObject.navigationController pushViewController:avc animated:YES];
    }];
}

- (void)updateName:(NSString *)name{
    _nameDetailLb.text = name;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (_selectedType == -1) {
            [self showFailedHudWithTitle:@"请选择身份"];
        }else if(!_nameDetailLb.text.length || [_nameDetailLb.text isEqualToString:@"请输入真实姓名"]){
            [self showFailedHudWithTitle:@"请填写真实姓名"];
        }else if (!_birthdayDetailLb.text.length){
            [self showFailedHudWithTitle:@"请选择孩子生日"];
        }
        else{
            [self onBlind];
        }
    }
}

- (void)onBlind{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:_birthdayDetailLb.text];
    [[TXChatClient sharedInstance] bindChild:_childUser.userId parentType:(TXPBParentType)_selectedType birthday:destDate.timeIntervalSince1970*1000 guarder:_nameDetailLb.text onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
        if (error) {
            [tmpObject showFailedHudWithError:error];
            [MobClick event:@"login_active_Identity" label:@"失败"];
        }else{
            [MobClick event:@"login_active_Identity" label:@"成功"];
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
            if (tmpObject.pwd.length) {
                [tmpObject onSuccess];
            }else{
                [tmpObject dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
}

- (void)onSuccess{
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    [appdelegate createTabBarView];
    //更改状态值
    [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLoginedStatus;
    //登录环信服务器
    [IdentityViewController loginEaseMob:[NSString stringWithFormat
                                          :@"%@",@(_txUser.userId)] andPwd:_pwd];
    //保存到UserDefaults
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",@(_txUser.userId)] forKey:kEaseMobUserName];
    [[NSUserDefaults standardUserDefaults] setValue:_userName forKey:kLocalUserName];
    [[NSUserDefaults standardUserDefaults] setValue:_pwd forKey:kLocalPassword];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

+ (void)loginEaseMob:(NSString *)userName andPwd:(NSString *)pwd{
    DDLogDebug(@"userName:%@, pwd:%@", userName, pwd);
    [[TXEaseMobHelper sharedHelper] autoLoginEaseMobServerWithUserName:userName password:pwd completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error) {
            DDLogDebug(@"激活时登录环信server成功:%@",loginInfo);
//            [[TXSystemManager sharedManager] setupAppLaunchActions];
        }else{
            DDLogDebug(@"激活时登录环信server失败:%@",error);
        }
        //创建视图
        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
        [TXProgressHUD hideHUDForView:appdelegate.window animated:YES];
    }];
    
    [[TXSystemManager sharedManager] setupAppLaunchActions];
}


- (void)updateParentType:(NSInteger)type{
    if (type == -1) {
        return;
    }
    _selectedType = type;
    _identilyDetailLb.text = [NSString getParentTypeStr:(TXPBParentType)type];
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
