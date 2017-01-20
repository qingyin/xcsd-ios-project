//
//  EditGuardianViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "EditGuardianViewController.h"

@interface EditGuardianViewController ()<UITextFieldDelegate>
{
    UIButton *_sureBtn;
}

@property (nonatomic, strong) UIButton *btnCloseKeyboard;   // 关闭键盘
@property (nonatomic) CGFloat keyboardHeight;               // 键盘高度
@property (nonatomic, strong) UITextField *codeTextField;

@end

@implementation EditGuardianViewController

- (id)initWithDetailDic:(NSMutableDictionary *)detailDic{
    self = [super init];
    if (self) {
        self.detailDic = detailDic;
        // 键盘监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"云卫士卡号";
    [self createCustomNavBar];
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)initView{
    UILabel *topLb = [[UILabel alloc] initClearColorWithFrame:CGRectMake(15, self.customNavigationView.maxY, self.view.width_ - 30, 32)];
    topLb.font = kFontMiddle;
    topLb.textColor = kColorLightGray;
    topLb.textAlignment = NSTextAlignmentLeft;
    topLb.text = [NSString stringWithFormat:@"%@的卡号",_detailDic[@"name"]];
    [self.view addSubview:topLb];
    
    UIView *codeBgView = [[UIView alloc] initWithFrame:CGRectMake(0, topLb.maxY, self.view.width_, 51)];
    codeBgView.backgroundColor = kColorWhite;
    [self.view addSubview:codeBgView];
    
    NSString *codeStr = _detailDic[@"code"];
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, codeBgView.width_ - 30, codeBgView.height_)];
    _codeTextField.placeholder = @"请输入8位云卫士卡号";
    _codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_codeTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_codeTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_codeTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    _codeTextField.font = kFontMiddle;
    _codeTextField.delegate = self;
    _codeTextField.textColor = kColorBlack;
    [codeBgView addSubview:_codeTextField];
    _codeTextField.text = codeStr;
    
    [_codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureBtn.frame = CGRectMake(15, codeBgView.maxY + 15, codeBgView.width_ - 30, 40);
    _sureBtn.titleLabel.font = kFontLarge_1_b;
    _sureBtn.backgroundColor = KColorAppMain;
    _sureBtn.layer.cornerRadius = 5.f;
    _sureBtn.layer.masksToBounds = YES;
    [_sureBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_sureBtn setTitleColor:kColorWhite forState:UIControlStateNormal];
    [self.view addSubview:_sureBtn];
    
    [_sureBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
        __weak typeof(self)tmpObject = self;
        NSNumber *parentId = _detailDic[@"parentId"];
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
        [[TXChatClient sharedInstance] bindCard:_codeTextField.text userId:parentId.integerValue onCompleted:^(NSError *error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"绑定", nil] counter:1];
                [tmpObject showFailedHudWithError:error];
            }else {
                [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"绑定", nil] counter:1];
                [tmpObject.detailDic setValue:tmpObject.codeTextField.text forKey:@"code"];
                [tmpObject.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
    //初始不修改值 不需要保存 值有变化才需要保存
//    _sureBtn.hidden = _codeTextField.text.length == 8?NO:YES;
    _sureBtn.hidden = YES;
    self.btnRight.hidden = _codeTextField.text.length == 8?NO:YES;

    
    // 键盘关闭按钮
    UIImage *imgClose = [UIImage imageNamed:@"keboard_off_btn"];
    _btnCloseKeyboard = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width_ - imgClose.size.width, self.view.height_, imgClose.size.width + 10, imgClose.size.height + 10)];
    [_btnCloseKeyboard setImage:imgClose forState:UIControlStateNormal];
    [_btnCloseKeyboard addTarget:self action:@selector(onClickCloseKeyboard) forControlEvents:UIControlEventTouchUpInside];
    _btnCloseKeyboard.alpha = 0;
    [self.view addSubview:_btnCloseKeyboard];

}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnRight setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    self.btnRight.hidden = YES;
}

- (void)onLossBtn{
    __weak typeof(self)tmpObject = self;
    NSNumber *parentId = _detailDic[@"parentId"];
    [self showAlertViewWithMessage:@"您确定要挂失吗?" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
        [[TXChatClient sharedInstance] reportLossCard:_detailDic[@"code"] userId:parentId.integerValue onCompleted:^(NSError *error) {
            if (error) {
                [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"挂失", nil] counter:1];
                [tmpObject showFailedHudWithError:error];
            }else {
                [MobClick event:@"mime_card" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"挂失", nil] counter:1];
                [tmpObject.detailDic setValue:@"" forKey:@"code"];
                [tmpObject.navigationController popViewControllerAnimated:YES];
            }
        }];
    }], nil];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        if (![_codeTextField.text isEqualToString:_detailDic[@"code"]]){
            //取消
            __weak typeof(self)tmpObject = self;
            [self showAlertViewWithMessage:@"您确定要放弃此编辑吗?" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:nil],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [tmpObject.navigationController popViewControllerAnimated:YES];
            }], nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];

        }
    }else{
        [self showNormalSheetWithTitle:nil items:@[@"挂失"] clickHandler:^(NSInteger index) {
            if (!index) {
                [self onLossBtn];
            }
        } completion:nil];
//        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"挂失", nil];
//        [sheet showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//            if (!buttonIndex) {
//                [self onLossBtn];
//            }
//        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 限制输入字数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (![unicodeStr isEqualToString:string]) {
        return NO;
    }
    if (textField.text.length > 8) {
        return NO;
    }
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.markedTextRange == nil && textField.text.length > 8) {
        textField.text = [textField.text substringToIndex:8];
    }
    
    NSString *codeStr = _detailDic[@"code"];
    if (textField.text.length == 8) {
        _sureBtn.hidden = [textField.text isEqualToString:codeStr];
        if (codeStr && codeStr.length) {
         self.btnRight.hidden = NO;
        }
    }else{
        self.btnRight.hidden = YES;
        _sureBtn.hidden = YES;
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
    if (vFirstResponder) {
        [UIView animateWithDuration:animateSpeed animations:^{
            _btnCloseKeyboard.maxY = self.view.height_ - keyboardHeight + 5;
            _btnCloseKeyboard.alpha = 1;
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
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
