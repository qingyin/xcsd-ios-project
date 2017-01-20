//
//  LoginViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "LoginViewController.h"
#import "ActiveViewController.h"
#import "AppDelegate.h"
#import <TXChatSDK/TXChatSDK.h>
#import "TXEaseMobHelper.h"
#import "TXSystemManager.h"
#import "XGPush.h"
#import "ActiveViewController.h"
#import "UMessage.h"
#import "DebugViewController.h"
#import <UIImageView+Utils.h>

#import "GameManager.h"
@interface LoginViewController ()<UITextFieldDelegate>
{
    UIView *_contentView;
}

@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIScrollView *mainView;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度

@end

@implementation LoginViewController

- (id)init{
    self = [super init];
    if (self) {
        // 键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColorBackground;
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, self.view.height_)];
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_mainView];
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.bottom.mas_equalTo(self.view);
    }];
    
    _contentView = [[UIView alloc] init];
    [_mainView addSubview:_contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_mainView);
        make.width.mas_equalTo(_mainView.mas_width);
    }];
    
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)initView{
    
    BOOL isPlus = SDiPhoneVersion.deviceSize ==iPhone55inch?YES:NO;
    UIImage *logoImg = [UIImage imageNamed:@"logo_teacher"];
    UIImageView *logoImgView = [[UIImageView alloc] initWithImage:logoImg];
    [_contentView addSubview:logoImgView];
    [logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(isPlus?118:(92 * kScale));
        make.width.mas_equalTo(logoImg.size.width);
        make.height.mas_equalTo(logoImg.size.height);
    }];
    
    //输入框背景
    UIView *loginView =[[UIView alloc] initWithFrame:CGRectZero];
    loginView.backgroundColor = kColorWhite;
    [_contentView addSubview:loginView];
    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(logoImgView.mas_bottom).offset(isPlus?82:(64 * kScale));
        make.height.mas_equalTo(isPlus?112:90);
    }];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = kColorLine;
    [loginView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(kLineHeight);
    }];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView1.backgroundColor = kColorLine;
    [loginView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(loginView.mas_bottom).offset(-kLineHeight);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(kLineHeight);
    }];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
    lineView2.backgroundColor = kColorLine;
    [loginView addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(isPlus?28:23);
        make.centerY.mas_equalTo(loginView.mas_centerY);
        make.right.mas_equalTo(isPlus?-28:-23);
        make.height.mas_equalTo(kLineHeight);
    }];
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _nameTextField.textColor = kColorBlack;
    _nameTextField.delegate = self;
    _nameTextField.returnKeyType = UIReturnKeyDone;
    _nameTextField.placeholder = @"手机号/帐号";
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_nameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_nameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _nameTextField.font = kFontMiddle;
    [loginView addSubview:_nameTextField];
    [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(lineView2.mas_left);
        make.right.mas_equalTo(lineView2.mas_right);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(lineView2.mas_bottom);
    }];
    
    _pwdTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _pwdTextField.placeholder = @"密码";
    _pwdTextField.delegate = self;
    _pwdTextField.returnKeyType = UIReturnKeyDone;
    _pwdTextField.textColor = kColorBlack;
    _pwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_pwdTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_pwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_pwdTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _pwdTextField.secureTextEntry = YES;
    _pwdTextField.font = kFontMiddle;
    _pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    [loginView addSubview:_pwdTextField];
    [_pwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_nameTextField.mas_left);
        make.right.mas_equalTo(_nameTextField.mas_right);
        make.top.mas_equalTo(_nameTextField.mas_bottom);
        make.height.mas_equalTo(_nameTextField.mas_height);
    }];
    
    //登录按钮
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.titleLabel.font = kFontLarge;
    _loginBtn.layer.cornerRadius = 4.f;
    _loginBtn.layer.masksToBounds = YES;
    _loginBtn.enabled = NO;
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImageView createImageWithColor:ColorNavigationTitle] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImageView createImageWithColor:kColorType1] forState:UIControlStateHighlighted];
    [_contentView addSubview:_loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(isPlus?28:23);
        make.right.mas_equalTo(isPlus?-28:-23);
        make.top.mas_equalTo(loginView.mas_bottom).offset(isPlus?56:(44 * kScale));
        make.height.mas_equalTo(isPlus?53:40);
    }];
    
    WEAKSELF;
    [_loginBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [weakSelf onLoginResponse:weakSelf.nameTextField.text andPwd:weakSelf.pwdTextField.text];
    }];
    
    //激活按钮
    UIButton *activeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    activeBtn.titleLabel.font = kFontMiddle;
    activeBtn.layer.cornerRadius = 4.f;
    activeBtn.layer.masksToBounds = YES;
    activeBtn.layer.borderColor = ColorNavigationTitle.CGColor;
    activeBtn.layer.borderWidth = kLineHeight;
    [activeBtn setBackgroundImage:[UIImageView createImageWithColor:kColorBackground] forState:UIControlStateNormal];
    [activeBtn setBackgroundImage:[UIImageView createImageWithColor:RGBCOLOR(138, 143, 255)] forState:UIControlStateHighlighted];
    [activeBtn setTitle:@"注册" forState:UIControlStateNormal];
    [activeBtn setTitleColor:ColorNavigationTitle forState:UIControlStateNormal];
    [activeBtn addTarget:self action:@selector(onActiveBtn) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:activeBtn];
    [activeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.loginBtn.mas_left);
        make.right.mas_equalTo(weakSelf.loginBtn.mas_right);
        make.top.mas_equalTo(weakSelf.loginBtn.mas_bottom).offset(isPlus?20:(15 * kScale));
        make.height.mas_equalTo(weakSelf.loginBtn.mas_height);
    }];
    
    
    //找回密码
    UIButton *findPwdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    findPwdBtn.titleLabel.font = kFontMiddle;
    [findPwdBtn setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [findPwdBtn setTitleColor:kColorLightBlack forState:UIControlStateNormal];
    [_contentView addSubview:findPwdBtn];
    [findPwdBtn sizeToFit];
    [findPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(activeBtn.mas_bottom).offset(isPlus?38:(30 * kScale));
        make.width.mas_equalTo(findPwdBtn.width_);
        make.height.mas_equalTo(findPwdBtn.height_);
        make.centerX.mas_equalTo(weakSelf.view.mas_centerX);
    }];
    [findPwdBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        ActiveViewController *avc = [[ActiveViewController alloc] init];
        avc.isPwd = YES;
        [weakSelf.navigationController pushViewController:avc animated:YES];
    }];
    
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(findPwdBtn.mas_bottom);
    }];
    
    //添加debug功能
    if ([TXSystemManager sharedManager].isDevVersion) {
        UIButton *debugBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        debugBtn.titleLabel.font = kFontMiddle;
        [debugBtn setTitle:@"切换环境" forState:UIControlStateNormal];
        [debugBtn setTitleColor:kColorLightBlack forState:UIControlStateNormal];
        [self.view addSubview:debugBtn];
        [debugBtn sizeToFit];
        [debugBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.bottom.mas_equalTo(weakSelf.view.mas_bottom).offset(-10);
            make.height.mas_equalTo(findPwdBtn.height_);
        }];
        [debugBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            DebugViewController *debugVc = [[DebugViewController alloc] init];
            [weakSelf presentViewController:debugVc animated:YES completion:nil];
        }];
    }
    
    //默认注销后保存用户名
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kLocalUserName];
    if (userName) {
        _nameTextField.text = userName;
    }
}

- (void)onLoginResponse:(NSString *)userName andPwd:(NSString *)pwd{
    
    DDLogDebug(@"userName:%@, pwd:%@", userName, pwd);
    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
    [TXProgressHUD showHUDAddedTo:appdelegate.window withMessage:@""];
    __weak typeof(self)tmpObject = self;
    [[TXChatClient sharedInstance] loginWithUsername:userName password:pwd onCompleted:^(NSError *error, TXUser *txUser) {
        DDLogDebug(@"login result error:%@", error);
        [TXProgressHUD hideHUDForView:appdelegate.window animated:NO];
        if (error) {
            [tmpObject showFailedHudWithError:error];
        }else if (!txUser.isInit){
            ActiveViewController *avc = [[ActiveViewController alloc] init];
            avc.isPwd = NO;
            avc.password = pwd;
            [tmpObject.navigationController pushViewController:avc animated:YES];
        }
        else{
            
            [[TXChatClient sharedInstance].dataReportManager reportEvent:XCSDPBEventTypeAppLogin];
            
            [UMessage addTag:[NSString stringWithFormat:@"%@%lld", KXGGARDENTAG, txUser.gardenId] response:nil];
            AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
            dispatch_async(dispatch_get_main_queue(), ^{
                [appdelegate createTabBarView];
            });
            //更改状态值
            [TXEaseMobHelper sharedHelper].connectStatus = TXServerConnectedLoginedStatus;
            //登录环信服务器
            [LoginViewController loginEaseMob:[NSString stringWithFormat:@"%@",@(txUser.userId)] andPwd:pwd];
            //保存到UserDefaults
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@",@(txUser.userId)] forKey:kEaseMobUserName];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstInstall];
            [[NSUserDefaults standardUserDefaults] setValue:userName forKey:kLocalUserName];
            [[NSUserDefaults standardUserDefaults] setValue:pwd forKey:kLocalPassword];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
            [[NSUserDefaults standardUserDefaults] synchronize];
			
			[[GameManager getInstance] resetData];
        }
    }];
}

+ (void)loginEaseMob:(NSString *)userName andPwd:(NSString *)pwd{
    DDLogDebug(@"环信userName:%@, pwd:%@", userName, pwd);
    [[TXEaseMobHelper sharedHelper] autoLoginEaseMobServerWithUserName:userName password:pwd completion:^(NSDictionary *loginInfo, EMError *error) {
        if (!error) {
            DDLogDebug(@"登录环信server成功:%@",loginInfo);
            [[TXSystemManager sharedManager] setupAppLaunchActions];
        }else{
            DDLogDebug(@"登录环信server失败:%@",error);
        }
        //创建视图
//        AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
//        [TXProgressHUD hideHUDForView:appdelegate.window animated:YES];
        //        [appdelegate createTabBarView];
    }];
}


//激活
- (void)onActiveBtn{
    ActiveViewController *avc = [[ActiveViewController alloc] init];
    [self.navigationController pushViewController:avc animated:YES];
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 过滤重复
    if (_keyboardHeight == keyboardHeight)
        return;
    _keyboardHeight = keyboardHeight;
    
    UIView *vFirstResponder = [self.view subviewWithFirstResponder];
    CGRect vFirstResponderRect = [_mainView convertRect:vFirstResponder.frame fromView:vFirstResponder.superview];
    vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _mainView.contentOffset.y; // 标题栏占位偏移
    
    if (vFirstResponder) {
        [UIView animateWithDuration:animateSpeed animations:^{
            _mainView.contentInset = UIEdgeInsetsMake(_mainView.contentInset.top, 0, keyboardHeight, 0);
            _mainView.scrollIndicatorInsets = _mainView.contentInset;
            CGFloat offsetHeight = _mainView.height_ - keyboardHeight - (vFirstResponderRect.origin.y + vFirstResponderRect.size.height);
            if(offsetHeight < 0)
                _mainView.contentOffset = CGPointMake(0, _mainView.contentOffset.y - offsetHeight); // 标题栏占位偏移
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (_keyboardHeight == 0)
        return;
    
    // 获取键盘高度 和 动画速度
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animateSpeed = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    _keyboardHeight = 0;
    
    [UIView animateWithDuration:animateSpeed animations:^{
        _mainView.contentInset = UIEdgeInsetsMake(_mainView.contentInset.top, 0, 0, 0);
        _mainView.scrollIndicatorInsets = _mainView.contentInset;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self onClickCloseKeyboard];
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if ([textField isEqual:_nameTextField] && textField.markedTextRange == nil && textField.text.length > 15) {
        textField.text = [textField.text substringToIndex:15];
    }
    if (_nameTextField.text.length && _pwdTextField.text.length) {
        _loginBtn.enabled = YES;
    }else{
        _loginBtn.enabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _pwdTextField) {
        return YES;
    }
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if (textField.text.length > 15) {
        return NO;
    }
    return YES;
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
