//
//  EditViewController.m
//  TXChat
//
//  Created by Cloud on 15/6/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "EditViewController.h"
#import <TXChatCommon/PlaceholderTextView.h>
#import "InfoViewController.h"
#import "IdentityViewController.h"
#import "TXContactManager.h"

@interface EditViewController ()<UITextFieldDelegate>
{
    UITextField *_textField;
}

@property (nonatomic, copy) NSString *tmpName;

@end

@implementation EditViewController

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleStr = @"姓名";
    [self createCustomNavBar];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY + 10, self.view.width_, 45)];
    bgView.backgroundColor = kColorWhite;
    [self.view addSubview:bgView];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, bgView.width_ - 20, 45)];
    _textField.text = _name;
    _textField.delegate = self;
    _textField.font = kFontMiddle;
    _textField.textColor = kColorBlack;
    [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [bgView addSubview:_textField];
    
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [_textField becomeFirstResponder];
    // Do any additional setup after loading the view.
}

- (void)onClickCloseKeyboard{
    [self.view endEditing:YES];
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        if (_textField.text.length && ![_textField.text isEqualToString:_name]) {
            //取消
            [self showAlertViewWithMessage:@"您确定要放弃此编辑吗?" andButtonItems:[ButtonItem itemWithLabel:@"取消" andTextColor:kColorBlack action:^{
                [_textField becomeFirstResponder];
            }],[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
                [self.navigationController popViewControllerAnimated:YES];
            }], nil];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        if (![_textField.text trim].length) {
            [self showFailedHudWithTitle:@"姓名不能为空"];
//            [self showAlertViewWithMessage:@"姓名不能为空" andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
            return;
        }
        [self.view endEditing:YES];
        
        if ([_presentVC isKindOfClass:[IdentityViewController class]]) {
            IdentityViewController *avc = (IdentityViewController *)_presentVC;
            [avc updateName:_textField.text];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
        __weak typeof(self)tmpObject = self;
        NSError *error = nil;
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
        self.tmpName = user.realName;
        user.realName =[_textField.text trim];
        
        [[TXChatClient sharedInstance] updateUserInfo:user onCompleted:^(NSError *error) {
            [TXProgressHUD hideHUDForView:tmpObject.view animated:YES];
            if (error) {
                user.realName = tmpObject.tmpName;
//                [tmpObject showAlertViewWithError:error andButtonItems:[ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:nil], nil];
                [tmpObject showFailedHudWithError:error];
            }else{
                [[TXContactManager shareInstance] notifyAllGroupsUserInfoUpdate:TXCMDMessageType_ProfileChange];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshUseInfo object:nil];
                    InfoViewController *infoVC = (InfoViewController *)tmpObject.presentVC;
                    [infoVC reloadData];
                    [tmpObject.navigationController popViewControllerAnimated:YES];
                });
                
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate method
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSString *unicodeStr = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    if (![unicodeStr isEqualToString:string]) {
//        return NO;
//    }
    if (textField.text.length > 15) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.markedTextRange == nil && textField.text.length > 15) {
        textField.text = [textField.text substringToIndex:15];
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
