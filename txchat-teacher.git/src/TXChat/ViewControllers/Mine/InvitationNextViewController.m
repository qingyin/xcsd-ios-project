//
//  InvitationNextViewController.m
//  TXChat
//
//  Created by Cloud on 15/7/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "InvitationNextViewController.h"
#import "NSString+ParentType.h"
#import "ZLPeoplePickerViewController.h"
#import "AppDelegate.h"
#import "InvitationListViewController.h"
#import "TXContactManager.h"
#import "NoCopyTextField.h"

#define kPhoneTextFieldTag              232231
#define kCodeTextFieldTag               238293
#define kPwdTextFieldTag                232311

@interface InvitationNextViewController ()<ZLPeoplePickerViewControllerDelegate,UITextFieldDelegate>
{
    UIScrollView *_mainView;
    UIButton *_btnCloseKeyboard;
    UITextField *_phoneTextField;
    UILabel *_codeTipLb;
    UIButton *_codeBtn;
    NoCopyTextField *_codeTextField;
    UITextField *_pwdTextField;
    NSTimer *_timer;
}

@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, assign) int num;
@property (nonatomic, strong) UIView *voiceView;
@property (nonatomic, strong) UILabel *voiceTipLb;

@end

@implementation InvitationNextViewController

- (id)init{
    self = [super init];
    if (self) {
        // 键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
        _addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
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
    self.titleStr = @"邀请家人";
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

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
    self.btnRight.enabled = NO;
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)initView{
    //手机号
    UIView *phoneBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, _mainView.width_, 45)];
    phoneBgView.backgroundColor = kColorWhite;
    [_mainView addSubview:phoneBgView];
    
    UIButton *callListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callListBtn.frame = CGRectMake(kScreenWidth - 100, 7, 86, 31);
    callListBtn.layer.cornerRadius = 5.f;
    callListBtn.layer.masksToBounds = YES;
    callListBtn.layer.borderColor = kColorLine.CGColor;
    callListBtn.layer.borderWidth = kLineHeight;
    [callListBtn setTitleColor:kColorGray forState:UIControlStateNormal];
    [callListBtn setTitle:@"通讯录" forState:UIControlStateNormal];
    callListBtn.titleLabel.font = kFontSmall;
    [phoneBgView addSubview:callListBtn];
    
    __weak typeof(self)tmpObject = self;
    [callListBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        ZLPeoplePickerViewController *avc = [[ZLPeoplePickerViewController alloc] init];
        avc.delegate = tmpObject;
        [tmpObject.navigationController pushViewController:avc
                                             animated:YES];
    }];
    
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, callListBtn.minX - 28, 45)];
    _phoneTextField.placeholder = @"请输入手机号";
    _phoneTextField.delegate = self;
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
    [_codeBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        tmpObject.voiceView.hidden = NO;
        [tmpObject onGetCodeBtn:NO];
    }];
    
    _codeTextField = [[NoCopyTextField alloc] initWithFrame:CGRectMake(14, 0, _codeBtn.minX - 28, 45)];
    _codeTextField.placeholder = @"请输入验证码";
    _codeTextField.delegate = self;
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
    pwdBgView.backgroundColor = kColorWhite;
    [_mainView addSubview:pwdBgView];
    
    _pwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, pwdBgView.width_ - 28, 45)];
    _pwdTextField.placeholder = [NSString stringWithFormat:@"为%@%@",[NSString getParentTypeStr:_type], KPasswordInvitePlaceholder];
    _pwdTextField.delegate = self;
    [_pwdTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_pwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_pwdTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _pwdTextField.font = kFontMiddle;
    _pwdTextField.tag = kPwdTextFieldTag;
    _pwdTextField.keyboardType = UIKeyboardTypeASCIICapable;
    [pwdBgView addSubview:_pwdTextField];
    
    [_pwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.btnRight.enabled = NO;
    
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
    
    _voiceView.frame = CGRectMake(0, pwdBgView.maxY + 10, voiceBtn.maxX, voiceBtn.height_);
    _voiceView.centerX = kScreenWidth/2;
    
    _voiceTipLb.minY = _voiceView.maxY + 10;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (_pwdTextField.text.length < KMinPasswordLen) {
            [self showFailedHudWithTitle:KPasswordFormatError];
//            [self showAlertViewWithMessage:@"密码长度过短" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
        }else{
            [self.view endEditing:YES];
            [self bindMobilePhoneNumber];
        }
    }
}

//绑定手机号
- (void)bindMobilePhoneNumber{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
    __weak typeof(self)tmpObject = self;
    NSString *phone = _phoneTextField.text;
    NSString *pwd = _pwdTextField.text;
    [[TXChatClient sharedInstance] activeInviteUser:phone verifyCode:_codeTextField.text parentType:_type password:pwd onCompleted:^(NSError *error, TXUser *txUser) {
        if (error) {
            [MobClick event:@"mime_invite" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"邀请家人", nil] counter:1];
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            [tmpObject showFailedHudWithError:error];
        }else{
            [MobClick event:@"mime_invite" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"邀请家人", nil] counter:1];
            [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
            [tmpObject.invitationVC onInvitationSuccess];
            [tmpObject.invitationVC showSuccessHudWithTitle:@"邀请成功"];
            [tmpObject.navigationController popViewControllerAnimated:YES];
        }
    }];
}


- (void)onGetCodeBtn:(BOOL)isVoice{
    if ([NSString isValidateMobile:[_phoneTextField.text trim]]) {
        if (!isVoice) {
            [self onTimer];
        }
        [_codeTextField becomeFirstResponder];
        __weak typeof(self)tmpObject = self;
        [[TXChatClient sharedInstance] sendVerifyCodeBySMS:[_phoneTextField.text trim] type:TXPBSendSmsCodeTypeInvitationActivate isVoice:isVoice onCompleted:^(NSError *error) {
            if (error) {
                [tmpObject showFailedHudWithError:error];
                tmpObject.num = 0;
                [tmpObject recoveryVerificationCode];
            }else{
                if (isVoice) {
                    [tmpObject showSuccessHudWithTitle:[NSString stringWithFormat:@"语音验证码已经发送到%@的手机，请%@注意查收。",[NSString getParentTypeStr:_type],[NSString getParentTypeStr:_type]]];
                }else{
                    [tmpObject showSuccessHudWithTitle:[NSString stringWithFormat:@"短信验证码已经发送到%@的手机，请%@注意查收。",[NSString getParentTypeStr:_type],[NSString getParentTypeStr:_type]]];
                }
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


#pragma mark -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if (textField.tag == kCodeTextFieldTag) {
        if (textField.text.length > KMaxVerifyCode ) {
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
        
        if (textField.text.length && _phoneTextField.text.length == 11 && _pwdTextField.text.length >= 1) {
            self.btnRight.enabled = YES;
        }else{
            self.btnRight.enabled = NO;
        }
    }else if (textField.tag == kPhoneTextFieldTag){
        if (textField.markedTextRange == nil && textField.text.length > 11) {
            textField.text = [textField.text substringToIndex:11];
        }
        if (textField.text.length == 11 &&
            _codeTextField.text.length &&
            _pwdTextField.text.length >= 1) {
            self.btnRight.enabled = YES;
        }else{
            self.btnRight.enabled = NO;
        }
    }else if (textField.tag == kPwdTextFieldTag){
        if (textField.markedTextRange == nil && textField.text.length > KMaxPasswordLen) {
            textField.text = [textField.text substringToIndex:KMaxPasswordLen];
        }
        if (textField.text.length >= 6 &&
            _codeTextField.text.length &&
            _phoneTextField.text.length == 11) {
            self.btnRight.enabled = YES;
        }else{
            self.btnRight.enabled = NO;
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
    CGRect vFirstResponderRect = [_mainView convertRect:vFirstResponder.frame fromView:vFirstResponder.superview];
    vFirstResponderRect.origin.y = vFirstResponderRect.origin.y - _mainView.contentOffset.y ; // 标题栏占位偏移
    
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

#pragma mark - ZLPeoplePickerViewControllerDelegate
- (void)peoplePickerViewController:(ZLPeoplePickerViewController *)peoplePicker
                   didSelectPerson:(NSNumber *)recordId {
    ABRecordRef person = [self recordRefFromRecordId:recordId];
    ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phoneNumbers) {
        CFIndex count = ABMultiValueGetCount(phoneNumbers);
        if (count > 1) {
            NSMutableArray *arr = [NSMutableArray array];
            for (int i =0; i < count; i ++) {
                NSString *number = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [arr addObject:number];
            }
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            [arr addObject:@"取消"];
            [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                [actionSheet addButtonWithTitle:obj];
            }];
            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            dispatch_async(dispatch_get_main_queue(), ^{
                __weak typeof(self)tmpObject = self;
                [actionSheet showInView:appdelegate.window withCompletionHandler:^(NSInteger buttonIndex) {
                    if (buttonIndex == arr.count - 1) {
                    }else{
                        tmpObject.phoneTextField.text = arr[buttonIndex];
                        [peoplePicker.navigationController popViewControllerAnimated:YES];
                    }
                }];
            });
            CFRelease(phoneNumbers);
        }else{
            NSString *number = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
            _phoneTextField.text = number;
            CFRelease(phoneNumbers);
            [peoplePicker.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (ABRecordRef)recordRefFromRecordId:(NSNumber *)recordId {
    return ABAddressBookGetPersonWithRecordID(self.addressBookRef,
                                              [recordId intValue]);
}

@end
