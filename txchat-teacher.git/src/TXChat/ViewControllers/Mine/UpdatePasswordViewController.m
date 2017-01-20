//
//  UpdatePasswordViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UpdatePasswordViewController.h"
#import "TXEaseMobHelper.h"

@interface UpdatePasswordViewController ()<UITextFieldDelegate>
{
    UIScrollView *_listView;
    UITextField *_currentPwdTextField;
    UITextField *_newPwdTextField;
    UITextField *_rePwdTextField;
}

@property (nonatomic, strong) UIButton *btnCloseKeyboard;   // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度

@end

@implementation UpdatePasswordViewController

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleStr = @"修改密码";
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
    //手机号
    UIView *currentPwdBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, _listView.width_, 45)];
    currentPwdBgView.backgroundColor = kColorWhite;
    [_listView addSubview:currentPwdBgView];
    
    _currentPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, currentPwdBgView.width_ - 28, 45)];
    _currentPwdTextField.delegate = self;
    _currentPwdTextField.placeholder = @"当前密码";
    _currentPwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_currentPwdTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_currentPwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_currentPwdTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _currentPwdTextField.secureTextEntry = YES;
    _currentPwdTextField.font = kFontMiddle;
    [_currentPwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [currentPwdBgView addSubview:_currentPwdTextField];
    
    //新密码
    UIView *newPwdBgView = [[UIView alloc] initWithFrame:CGRectMake(0, currentPwdBgView.maxY + 5, _listView.width_, 45)];
    newPwdBgView.backgroundColor = kColorWhite;
    [_listView addSubview:newPwdBgView];
    
    _newPwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, newPwdBgView.width_ - 28, 45)];
    _newPwdTextField.delegate = self;
    _newPwdTextField.placeholder = @"新密码";
    _newPwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_newPwdTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_newPwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_newPwdTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _newPwdTextField.secureTextEntry = YES;
    _newPwdTextField.font = kFontMiddle;
    [_newPwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [newPwdBgView addSubview:_newPwdTextField];
    
    //重复
    UIView *rePwdBgView = [[UIView alloc] initWithFrame:CGRectMake(0, newPwdBgView.maxY + 5, _listView.width_, 45)];
    rePwdBgView.backgroundColor = kColorWhite;
    [_listView addSubview:rePwdBgView];
    
    _rePwdTextField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, newPwdBgView.width_ - 28, 45)];
    _rePwdTextField.delegate = self;
    _rePwdTextField.placeholder = @"再次输入新密码";
    _rePwdTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_rePwdTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_rePwdTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_rePwdTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _rePwdTextField.secureTextEntry = YES;
    _rePwdTextField.font = kFontMiddle;
    [_rePwdTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [rePwdBgView addSubview:_rePwdTextField];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnLeft setTitle:@"返回" forState:UIControlStateNormal];
    [self.btnRight setTitle:@"提交" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    [self.view endEditing:YES];
    if (sender.tag == TopBarButtonLeft) {
        __weak typeof(self)tmpObject = self;
        if (_currentPwdTextField.text.length ||
            _newPwdTextField.text.length ||
            _rePwdTextField.text.length) {
            [self showAlertViewWithMessage:@"确定放弃此操作吗？" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [tmpObject.view endEditing:YES];
                [tmpObject.navigationController popViewControllerAnimated:YES];
            }], nil];
            
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        if (!_currentPwdTextField.text.length) {
            [self showFailedHudWithTitle:@"当前密码不能为空"];
        }else if (_newPwdTextField.text.length < KMinPasswordLen){
            [self showFailedHudWithTitle:KPasswordFormatError];
        }else if (![_newPwdTextField.text isEqualToString:_rePwdTextField.text]) {
            [self showFailedHudWithTitle:@"两次输入密码不一致"];
        }else{
            [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
            __weak typeof(self)tmpObject = self;
            [[TXChatClient sharedInstance] changePassword:_currentPwdTextField.text newPassword:_newPwdTextField.text onCompleted:^(NSError *error) {
                [TXProgressHUD hideHUDForView:self.view animated:YES];
                if (error) {
                    [MobClick event:@"mime_safe" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"修改密码", nil] counter:1];
//                    [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
                    [tmpObject showFailedHudWithError:error];
                }else{
                    [MobClick event:@"mime_safe" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"修改密码", nil] counter:1];
                    [tmpObject showSuccessHudWithTitle:@"修改密码成功"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [tmpObject.view endEditing:YES];
                        [[NSUserDefaults standardUserDefaults] setValue:_newPwdTextField.text forKey:kLocalPassword];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        //重新登录环信
                        [[TXEaseMobHelper sharedHelper] reLoginWhenChangePassword];
                        [tmpObject.navigationController popViewControllerAnimated:YES];
                    });

                }
            }];
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

#pragma mark -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if ([textField isEqual:_currentPwdTextField]) {
        if (textField.text.length > KMaxPasswordLen) {
            return NO;
        }
        return YES;
    }else if ([textField isEqual:_newPwdTextField]){
        if (textField.text.length > KMaxPasswordLen) {
            return NO;
        }
        return YES;
    }else if ([textField isEqual:_rePwdTextField]){
        if (textField.text.length > KMaxPasswordLen) {
            return NO;
        }
        return YES;
    }
    return YES;
    
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if ([textField isEqual:_currentPwdTextField]) {
        if (textField.markedTextRange == nil && textField.text.length > KMaxPasswordLen) {
            textField.text = [textField.text substringToIndex:KMaxPasswordLen];
        }
    }else if ([textField isEqual:_newPwdTextField]){
        if (textField.markedTextRange == nil && textField.text.length > KMaxPasswordLen) {
            textField.text = [textField.text substringToIndex:KMaxPasswordLen];
        }
    }else{
        if (textField.markedTextRange == nil && textField.text.length > KMaxPasswordLen) {
            textField.text = [textField.text substringToIndex:KMaxPasswordLen];
        }
    }
}


@end
