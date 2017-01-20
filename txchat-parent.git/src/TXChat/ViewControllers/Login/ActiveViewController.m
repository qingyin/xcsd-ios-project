//
//  ActiveViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ActiveViewController.h"
#import "IdentityViewController.h"
#import <TXChatSDK/TXChatSDK.h>
#import "PublishmentDetailViewController.h"
#import "NoCopyTextField.h"
#import "AppDelegate.h"
#import "XGPush.h"
#import "TXEaseMobHelper.h"
#import "LoginViewController.h"
#import "GameManager.h"
#define kCodeTextFieldTag                   1000
#define kPhoneTextFieldTag                  1001
#define kPwdTextFieldTag                    1002
#define kRePwdTextFieldTag                  1003

@interface ActiveViewController ()<UITextFieldDelegate>
{
    UIScrollView *_mainView;
    UIButton *_codeBtn;
    UILabel *_codeTipLb;
    UITextField *_phoneTextField;
    NoCopyTextField *_codeTextField;
    UITextField *_pwdTextField;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) int num;
@property (nonatomic, strong) UIButton *btnCloseKeyboard;   // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, strong) UIView *voiceView;
@property (nonatomic, strong) UILabel *voiceTipLb;

@end

@implementation ActiveViewController

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
    
    if (_isPwd) {
        self.titleStr = @"重置密码";
    }else{
        self.titleStr = (_password && _password.length)?@"绑定手机号":@"注册";
    }
    [self createCustomNavBar];
    
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.height_)];
    _mainView.showsHorizontalScrollIndicator = NO;
    _mainView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_mainView];
    
    [self initView];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    _btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width_ - imgClose.size.width, self.view.height_, imgClose.size.width + 10, imgClose.size.height + 10)];
    [_btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [_btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnCloseKeyboard.alpha = 0;
    [self.view addSubview:_btnCloseKeyboard];
    
    // Do any additional setup after loading the view.
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    if (_isPwd) {
        [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
    }else{
        [self.btnRight setTitle:@"下一步" forState:UIControlStateNormal];
    }
}

//创建激活码视图
- (void)initView{
    //手机号
    UIView *phoneBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, _mainView.width_, 45)];
    phoneBgView.backgroundColor = kColorWhite;
    [_mainView addSubview:phoneBgView];
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, phoneBgView.width_ - 28, 45)];
    _phoneTextField.delegate = self;
    _phoneTextField.placeholder = _isPwd?@"请输入已激活的手机号":((_password && _password.length)?@"输入手机号":@"输入预留手机号");
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_phoneTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_phoneTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _phoneTextField.font = kFontMiddle;
    _phoneTextField.tag = kPhoneTextFieldTag;
    [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [phoneBgView addSubview:_phoneTextField];
    
    //激活码
    UIView *codeBgView = [[UIView alloc] initWithFrame:CGRectMake(0, phoneBgView.maxY + 5, _mainView.width_, 45)];
    codeBgView.backgroundColor = kColorWhite;
    [_mainView addSubview:codeBgView];
    
    _codeTipLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(kScreenWidth - 100, 7, 86, 31)];
    _codeTipLb.font = kFontSmall;
    _codeTipLb.textAlignment = NSTextAlignmentCenter;
    _codeTipLb.textColor = KColorAppMain;
    _codeTipLb.text = @"获取验证码";
    [codeBgView addSubview:_codeTipLb];
    
    _codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame = _codeTipLb.frame;
    _codeBtn.layer.cornerRadius = 5.f;
    _codeBtn.layer.masksToBounds = YES;
    _codeBtn.layer.borderColor = KColorAppMain.CGColor;
    _codeBtn.layer.borderWidth = kLineHeight;
    [codeBgView addSubview:_codeBtn];
//    __weak typeof(self)tmpObject = self;
    // by mey
    __weak __typeof(&*self) tmpObject=self;
    [_codeBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        tmpObject.voiceView.hidden = NO;
        [tmpObject onGetCodeBtn:NO];
    }];
    
    _codeTextField = [[NoCopyTextField alloc] initWithFrame:CGRectMake(14, 0, _codeBtn.minX - 28, 45)];
    _codeTextField.delegate = self;
    _codeTextField.placeholder = _isPwd?@"请输入短信验证码":@"输入短信收到的激活码";
    [_codeTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_codeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_codeTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _codeTextField.font = kFontMiddle;
    _codeTextField.tag = kCodeTextFieldTag;
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [codeBgView addSubview:_codeTextField];
    
    [_codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //密码
    UIView *pwdBgView = [[UIView alloc] initWithFrame:CGRectMake(0, codeBgView.maxY + 5, _mainView.width_, 45)];
    pwdBgView.clipsToBounds = YES;
    pwdBgView.backgroundColor = kColorWhite;
    [_mainView addSubview:pwdBgView];
    
    _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, pwdBgView.width_ - 28, 45)];
    _pwdTextField.delegate = self;
    _pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _pwdTextField.placeholder = KPasswordPlaceholder;
    [_pwdTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_pwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_pwdTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    _pwdTextField.font = kFontMiddle;
    _pwdTextField.tag = kPwdTextFieldTag;
    [pwdBgView addSubview:_pwdTextField];
    
    if (_password && _password.length) {
        _pwdTextField.text = _password;
        pwdBgView.height_ = 0;
    }
    
    [_pwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _voiceView = [[UIView alloc] initWithFrame:CGRectZero];
    _voiceView.hidden = YES;
    [_mainView addSubview:_voiceView];
    
    NSString *str = @"电话拨打中...请留意来自400-xxx的电话";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString addAttribute:NSForegroundColorAttributeName value:KColorAppMain range:[str rangeOfString:@"400-xxx"]];
    _voiceTipLb = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 30, 30)];
    _voiceTipLb.font = kFontSmall;
    _voiceTipLb.textAlignment = NSTextAlignmentCenter;
    _voiceTipLb.layer.borderWidth = kLineHeight;
    _voiceTipLb.layer.borderColor = kColorLightGray.CGColor;
    _voiceTipLb.backgroundColor = kColorWhite;
    _voiceTipLb.hidden = YES;
    _voiceTipLb.textColor = kColorLightGray;
    _voiceTipLb.attributedText = attributedString;
    [_mainView addSubview:_voiceTipLb];
    
    UILabel *voiceLb = [[UILabel alloc] initWithFrame:CGRectZero];
    voiceLb.font = kFontSmall;
    voiceLb.text = @"收不到短信？使用";
    voiceLb.textColor = kColorLightGray;
    [_voiceView addSubview:voiceLb];
    [voiceLb sizeToFit];
    voiceLb.frame = CGRectMake(0, 0, voiceLb.width_, voiceLb.height_);
    
    UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [voiceBtn setTitleColor:KColorAppMain forState:UIControlStateNormal];
    [voiceBtn setTitle:@"语音验证码" forState:UIControlStateNormal];
    voiceBtn.titleLabel.font = kFontSmall;
    [_voiceView addSubview:voiceBtn];
    [voiceBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        [tmpObject onGetCodeBtn:YES];
    }];
    [voiceBtn sizeToFit];
    voiceBtn.frame = CGRectMake(voiceLb.maxX, 0, voiceBtn.width_, voiceBtn.height_);
    voiceLb.height_ = voiceBtn.height_;
    
    if (_isPwd) {
        _voiceView.frame = CGRectMake(0, pwdBgView.maxY + 20, voiceBtn.maxX, voiceBtn.height_);
        _voiceView.centerX = kScreenWidth/2;
        
        _voiceTipLb.minY = _voiceView.maxY + 10;
        
        return;
    }
    
    UIView *agreementView = [[UIView alloc] initWithFrame:CGRectZero];
    agreementView.hidden = (_password && _password.length)?YES:NO;
    [_mainView addSubview:agreementView];
    
    
    UILabel *agreementLb = [[UILabel alloc] initWithFrame:CGRectZero];
    agreementLb.font = kFontSmall;
    agreementLb.text = @"激活即表示同意";
    agreementLb.textColor = kColorLightGray;
    [agreementView addSubview:agreementLb];
    [agreementLb sizeToFit];
    agreementLb.frame = CGRectMake(0, 0, agreementLb.width_, agreementLb.height_);
    
    UIButton *agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreementBtn setTitleColor:KColorAppMain forState:UIControlStateNormal];
    [agreementBtn setTitle:@"《乐学堂服务协议》" forState:UIControlStateNormal];
    agreementBtn.titleLabel.font = kFontSmall;
    [agreementBtn addTarget:self action:@selector(onClickAgreementBtn:) forControlEvents:UIControlEventTouchUpInside];
    [agreementView addSubview:agreementBtn];
    [agreementBtn sizeToFit];
    agreementBtn.frame = CGRectMake(agreementLb.maxX, 0, agreementBtn.width_, agreementBtn.height_);
    agreementLb.height_ = agreementBtn.height_;
    
    agreementView.frame = CGRectMake(0, pwdBgView.maxY + 20, agreementBtn.maxX, agreementBtn.height_);
    agreementView.centerX = kScreenWidth/2;
    
    _voiceView.frame = CGRectMake(0, agreementView.maxY + 10, voiceBtn.maxX, voiceBtn.height_);
    _voiceView.centerX = kScreenWidth/2;
    
    _voiceTipLb.minY = _voiceView.maxY + 10;
}
      
- (void)onGetCodeBtn:(BOOL)isVoice{
    if ([NSString isValidateMobile:[_phoneTextField.text trim]]) {
        if (!isVoice) {
            [self onTimer];
        }
        [_codeTextField becomeFirstResponder];
//        __weak typeof(self)tmpObject = self;
        // by mey
        __weak __typeof(&*self) tmpObject=self;
        [[TXChatClient sharedInstance] sendVerifyCodeBySMS:[_phoneTextField.text trim] type:_isPwd?TXPBSendSmsCodeTypeForgetPassword:TXPBSendSmsCodeTypeActivate isVoice:isVoice  onCompleted:^(NSError *error) {
            if (error) {
                [tmpObject showFailedHudWithError:error];
                tmpObject.num = 0;
                [tmpObject recoveryVerificationCode];
            }
        }];
        if (isVoice) {
            _voiceTipLb.hidden = NO;
            [self showSuccessHudWithTitle:@"电话拨打中..."];
        }
    }else{
        [self showFailedHudWithTitle:@"您输入的手机不正确哦"];
    }
}

//计时器开始计时
- (void)onTimer
{
    _num = 60;
    // 获取验证码按钮置灰
    _codeBtn.enabled = NO;
    _codeBtn.layer.borderColor = kColorLine.CGColor;
    if (!_timer)
        _timer = [[NSTimer alloc] init];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getIdentifys:) userInfo:nil repeats:YES];
    [_timer fire];
}


//短信倒计时
- (void)getIdentifys:(NSTimer *)timer
{
    _num -= 1;
    NSString *numStr = [NSString stringWithFormat:@"%d\"后可重获", _num];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:numStr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kColorLightGray range:NSMakeRange(numStr.length - 4, 4)];
    _codeTipLb.attributedText = attributedString;
    if (_num == 0) {
        [self recoveryVerificationCode];
    }
}

- (void)recoveryVerificationCode
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _codeBtn.enabled = YES;
    NSString *numStr = @"获取验证码";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:numStr];
    [attributedString addAttribute:NSForegroundColorAttributeName value:KColorAppMain range:NSMakeRange(0, numStr.length)];
    _codeTipLb.attributedText = attributedString;
    _codeBtn.layer.borderColor = KColorAppMain.CGColor;
}

//服务协议
- (void)onClickAgreementBtn:(UIButton *)sender{
    //跳转到网页链接
    PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:KSERVERAGREEMENTURL];
    detailVc.postType = TXHomePostType_ServiceAgreement;
    [self.navigationController pushViewController:detailVc animated:YES];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        //返回
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (![NSString isValidateMobile:[_phoneTextField.text trim]]) {
            [self showFailedHudWithTitle:@"您输入的手机不正确哦"];
        }else if (!_codeTextField.text || _codeTextField.text.length == 0) {
            [self showFailedHudWithTitle:@"请输入验证码"];
        }else if (_codeTextField.text.length > KMaxVerifyCode) {
            [self showFailedHudWithTitle:@"请输入正确的验证码"];
        }else if (_pwdTextField.text.length < KMinPasswordLen && !_password) {
            [self showFailedHudWithTitle:KPasswordFormatError];
        }else{
            [self.view endEditing:YES];
            if (_isPwd) {
                [self changePassword];
            }else{
                [self bindMobilePhoneNumber];
            }
        }
    }
}

- (void)changePassword{
    
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak typeof(self)tmpObject = self;
    // by mey
    WEAKTEMP
    NSString *pwd = _pwdTextField.text;
    [[TXChatClient sharedInstance] changePassword:pwd mobilePhoneNumber:_phoneTextField.text verifyCode:_codeTextField.text onCompleted:^(NSError *error) {
        [TXProgressHUD hideHUDForView:tmpObject.view animated:NO];
        if (error) {
            //            [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            [tmpObject showFailedHudWithError:error];
        }else{
            
            DDLogDebug(@"userName:%@, pwd:%@", _phoneTextField.text, _pwdTextField.text);
            AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
            [TXProgressHUD showHUDAddedTo:appdelegate.window withMessage:@""];
//            __weak typeof(self)tmpObject = self;
            WEAKTEMP
            [[TXChatClient sharedInstance] loginWithUsername:_phoneTextField.text password:_pwdTextField.text onCompleted:^(NSError *error, TXUser *txUser) {
                DDLogDebug(@"login result error:%@", error);
                if (error) {
                    [TXProgressHUD hideHUDForView:appdelegate.window animated:NO];
                    [tmpObject showFailedHudWithError:error];
                }else if (!txUser.isInit){
                    [TXProgressHUD hideHUDForView:appdelegate.window animated:YES];
                    ActiveViewController *avc = [[ActiveViewController alloc] init];
                    avc.isPwd = NO;
                    avc.password = pwd;
                    [tmpObject.navigationController pushViewController:avc animated:YES];
                }
                else{
                    [XGPush setTag:[NSString stringWithFormat:@"%@%lld", KXGGARDENTAG, txUser.gardenId]];
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
                    [[NSUserDefaults standardUserDefaults] setValue:_phoneTextField.text forKey:kLocalUserName];
                    [[NSUserDefaults standardUserDefaults] setValue:_pwdTextField.text forKey:kLocalPassword];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsCanAutoLogin];
                    [[NSUserDefaults standardUserDefaults] synchronize];
					
					[[GameManager getInstance] resetData];
                }
            }];
            
            
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据请求
//绑定手机号
- (void)bindMobilePhoneNumber{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    __weak typeof(self)tmpObject = self;
    WEAKTEMP
    NSString *phone = _phoneTextField.text;
    NSString *pwd = _pwdTextField.text;
    
    if (_password && _password.length) {
        [[TXChatClient sharedInstance] changeMobilePhoneNumber:_phoneTextField.text verifyCode:_codeTextField.text onCompleted:^(NSError *error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [tmpObject showFailedHudWithError:error];
            }else{
                //激活
                TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
                IdentityViewController *avc = [[IdentityViewController alloc] init];
                avc.txUser = user;
                avc.pwd = pwd;
                avc.userName = phone;
                [tmpObject.navigationController pushViewController:avc animated:YES];
            }
        }];
    }else{
        [[TXChatClient sharedInstance] activeUser:_phoneTextField.text verifyCode:_codeTextField.text password:_pwdTextField.text onCompleted:^(NSError *error, TXUser *txUser) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [tmpObject showFailedHudWithError:error];
                
            }else{
                
                //激活
                [[TXChatClient sharedInstance] fetchChild:^(NSError *error, TXUser *childUser) {
                    
                    if (error) {
                        
                        [tmpObject showFailedHudWithError:error];
                        [MobClick event:@"login_active" label:@"失败"];
                    }else{
                        
                        [MobClick event:@"login_active" label:@"成功"];
                        
                        IdentityViewController *avc = [[IdentityViewController alloc] init];
                        avc.child = childUser;
                        avc.txUser = txUser;
                        avc.pwd = pwd;
                        avc.userName = phone;
                        [tmpObject.navigationController pushViewController:avc animated:YES];
                    }
                }];
            }
        }];
    }
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
            _btnCloseKeyboard.maxY = self.view.height_ - keyboardHeight + 5;
            _btnCloseKeyboard.alpha = 1;
            
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
        _btnCloseKeyboard.maxY = self.view.height_;
        _btnCloseKeyboard.alpha = 0;
        
        _mainView.contentInset = UIEdgeInsetsMake(_mainView.contentInset.top, 0, 0, 0);
        _mainView.scrollIndicatorInsets = _mainView.contentInset;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if (textField.tag == kCodeTextFieldTag) {
        if (textField.text.length > KMaxVerifyCode &&string.length > range.length) {
            return NO;
        }
        return YES;
    }else if (textField.tag == kPhoneTextFieldTag){
        if (textField.text.length > 11) {
            return NO;
        }
        return YES;
    }else if (textField.tag == kPwdTextFieldTag){
        if (textField.text.length > KMaxPasswordLen) {
            return NO;
        }
        return YES;
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.tag == kCodeTextFieldTag) {
        if (textField.markedTextRange == nil && textField.text.length > KMaxVerifyCode) {
            textField.text = [textField.text substringToIndex:KMaxVerifyCode];
        }
    }else if (textField.tag == kPhoneTextFieldTag){
        if (textField.markedTextRange == nil && textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
    }else if (textField.tag == kPwdTextFieldTag){
        if (textField.markedTextRange == nil && textField.text.length > KMaxPasswordLen) {
            textField.text = [textField.text substringToIndex:KMaxPasswordLen];
        }
    }

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
