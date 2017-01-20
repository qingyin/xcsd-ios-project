//
//  UpdateMobileViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UpdateMobileViewController.h"
#import "NoCopyTextField.h"
#import "SecureListViewController.h"

#define kPhoneTextFieldTag          2313111
#define kCodeTextFieldTag           8932938

@interface UpdateMobileViewController ()<UITextFieldDelegate>
{
    UIScrollView *_listView;
    UILabel *_codeTipLb;
    UIButton *_codeBtn;
    NoCopyTextField *_codeTextField;
    NSTimer *_timer;
    UIView *_voiceView;
}

@property (nonatomic, strong) UIButton *btnCloseKeyboard;   // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, assign) int num;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIView *voiceView;
@property (nonatomic, strong) UILabel *voiceTipLb;

@end

@implementation UpdateMobileViewController

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"更换手机号";
    [self createCustomNavBar];
    
    _listView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, self.view.width_, self.view.height_ - self.customNavigationView.maxY)];
    _listView.showsHorizontalScrollIndicator = NO;
    _listView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_listView];
    
    [self initView];
    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    _btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width_ - imgClose.size.width, self.view.height_, imgClose.size.width + 10, imgClose.size.height + 10)];
    [_btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [_btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnCloseKeyboard.alpha = 0;
    [self.view addSubview:_btnCloseKeyboard];
}

- (void)initView{
    UILabel *tipsLb = [[UILabel alloc] initWithFrame:CGRectZero];
    tipsLb.font = kFontMiddle;
    tipsLb.numberOfLines = 0;
    tipsLb.textColor = kColorGray;
    tipsLb.textAlignment = NSTextAlignmentLeft;
    tipsLb.text = @"更换手机号后，下次登录要用新的手机号登录";
    [_listView addSubview:tipsLb];
    CGSize size = [tipsLb sizeThatFits:CGSizeMake(kScreenWidth - 30, MAXFLOAT)];
    tipsLb.frame = CGRectMake((kScreenWidth - size.width)/2, 10, size.width, size.height);
    
    //手机号
    UIView *phoneBgView = [[UIView alloc] initWithFrame:CGRectMake(0, tipsLb.maxY + 10, _listView.width_, 45)];
    phoneBgView.backgroundColor = kColorWhite;
    [_listView addSubview:phoneBgView];
    
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, phoneBgView.width_ - 28, 45)];
    _phoneTextField.delegate = self;
    _phoneTextField.placeholder = @"输入手机号";
    _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_phoneTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_phoneTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_phoneTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _phoneTextField.font = kFontMiddle;
    _phoneTextField.tag = kPhoneTextFieldTag;
    [_phoneTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [phoneBgView addSubview:_phoneTextField];
    
    //激活码
    UIView *codeBgView = [[UIView alloc] initWithFrame:CGRectMake(0, phoneBgView.maxY + 5, _listView.width_, 45)];
    codeBgView.backgroundColor = kColorWhite;
    [_listView addSubview:codeBgView];
    
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
    _codeTextField.placeholder = @"输入短信收到的验证码";
    _codeTextField.delegate = self;
    [_codeTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_codeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_codeTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _codeTextField.font = kFontMiddle;
    _codeTextField.tag = kCodeTextFieldTag;
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [codeBgView addSubview:_codeTextField];
    
    [_codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    _voiceView = [[UIView alloc] initWithFrame:CGRectZero];
    _voiceView.hidden = YES;
    [_listView addSubview:_voiceView];
    
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
    [_listView addSubview:_voiceTipLb];
    
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
    
    _voiceView.frame = CGRectMake(0, codeBgView.maxY + 10, voiceBtn.maxX, voiceBtn.height_);
    _voiceView.centerX = kScreenWidth/2;
    
    _voiceTipLb.minY = _voiceView.maxY + 10;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
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
        [[TXChatClient sharedInstance] sendVerifyCodeBySMS:[_phoneTextField.text trim] type:TXPBSendSmsCodeTypeUpdateMobile isVoice:isVoice onCompleted:^(NSError *error) {
            if (error) {
                [tmpObject showFailedHudWithError:error];
                
                tmpObject.num = 0;
                [_timer invalidate];
                [tmpObject recoveryVerificationCode];
            }

        }];
        if (isVoice) {
            _voiceTipLb.hidden = NO;
            [self showSuccessHudWithTitle:@"电话拨打中..."];
        }
    }else{
        [self showFailedHudWithTitle:@"您输入的手机不正确哦"];
//        [self showAlertViewWithMessage:@"请输入正确的手机号" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
    }
}

//计时器开始计时
- (void)onTimer
{
    _num = 60;
    // 获取验证码按钮置灰
    _codeBtn.enabled = NO;
    _codeBtn.layer.borderColor = kColorLightGray.CGColor;
    if (!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getIdentifys:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
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


- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
//        __weak typeof(self)tmpObject = self;
        // by mey
        __weak __typeof(&*self) tmpObject=self;
        if (_phoneTextField.text.length || _codeTextField.text.length) {
            [self showAlertViewWithMessage:@"确定放弃此操作吗？" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [tmpObject.view endEditing:YES];
                [tmpObject.navigationController popViewControllerAnimated:YES];
                //                [tmpObject dismissViewControllerAnimated:YES completion:nil];
            }], nil];

        }else{
            [self.view endEditing:YES];
            [tmpObject.navigationController popViewControllerAnimated:YES];
//            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
        if (![NSString isValidateMobile:[_phoneTextField.text trim]])
        {
            [self showFailedHudWithTitle:@"您输入的手机不正确哦"];
        }else if (!_codeTextField.text || _codeTextField.text.length == 0) {
            [self showFailedHudWithTitle:@"请输入验证码"];
        }else if (_codeTextField.text.length > KMaxVerifyCode) {
            [self showFailedHudWithTitle:@"请输入正确的验证码"];
        }else{
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//            __weak typeof(self)tmpObject = self;
            // by mey
            __weak __typeof(&*self) tmpObject=self;
            [[TXChatClient sharedInstance] changeMobilePhoneNumber:_phoneTextField.text verifyCode:_codeTextField.text onCompleted:^(NSError *error) {
                [TXProgressHUD hideHUDForView:self.view animated:YES];
                if (error) {
                    [MobClick event:@"mime_safe" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"修改手机号", nil] counter:1];
                    [tmpObject showFailedHudWithError:error];
                }else{
                    [MobClick event:@"mime_safe" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"修改手机号", nil] counter:1];
                    [[NSUserDefaults standardUserDefaults] setValue:tmpObject.phoneTextField.text forKey:kLocalUserName];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tmpObject.view endEditing:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUseInfo object:nil];
                        [tmpObject.mobileVC  showSuccessHudWithTitle:@"更换成功"];
                        [tmpObject.navigationController popViewControllerAnimated:YES];
//                        [tmpObject dismissViewControllerAnimated:YES completion:nil];
                    });
                }
            }];
        }
    }
}
- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.showBackArrow = NO;
//    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnRight setTitle:@"提交" forState:UIControlStateNormal];
}

#pragma mark -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if (textField.tag == kCodeTextFieldTag) {
        if ((textField.text.length > KMaxVerifyCode && string.length > range.length)) {
            return NO;
        }
        return YES;
    }else if (textField.tag == kPhoneTextFieldTag){
        if (textField.text.length > 11) {
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
    CGRect vFirstResponderRect = [_listView convertRect:vFirstResponder.frame fromView:vFirstResponder.superview];
    vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _listView.contentOffset.y; // 标题栏占位偏移
    
    if (vFirstResponder) {
        [UIView animateWithDuration:animateSpeed animations:^{
            _btnCloseKeyboard.maxY = self.view.height_ - keyboardHeight + 5;
            _btnCloseKeyboard.alpha = 1;
            
            _listView.contentInset = UIEdgeInsetsMake(_listView.contentInset.top, 0, keyboardHeight, 0);
            _listView.scrollIndicatorInsets = _listView.contentInset;
            CGFloat offsetHeight = _listView.height_ - keyboardHeight - (vFirstResponderRect.origin.y + vFirstResponderRect.size.height);
            if(offsetHeight < 0)
                _listView.contentOffset = CGPointMake(0, _listView.contentOffset.y - offsetHeight); // 标题栏占位偏移
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
        
        _listView.contentInset = UIEdgeInsetsMake(_listView.contentInset.top, 0, 0, 0);
        _listView.scrollIndicatorInsets = _listView.contentInset;
    }];
}



@end
