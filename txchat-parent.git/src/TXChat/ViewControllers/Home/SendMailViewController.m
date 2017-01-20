//
//  SendMailViewController.m
//  TXChat
//
//  Created by lyt on 15-6-30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SendMailViewController.h"
#import "CHSCharacterCountTextView.h"
#import <TXChatClient.h>

#define KMaxMailNumber 200//园长信箱输入文字最大长度

@interface SendMailViewController ()<CHSCharacterCountTextViewDelegate>
{
    CHSCharacterCountTextView *_textView;//反馈内容
    UISwitch *_isAnonymousSwitch;//是否匿名开关
    BOOL _isInputMailContent;//是否输入园长信箱内容
}
@end

@implementation SendMailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isInputMailContent = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    [self createCustomNavBar];
    [self.btnRight setTitle:@"发送" forState:UIControlStateNormal];
    [self.btnRight setEnabled:NO];
    self.btnLeft.showBackArrow = NO;
    [self.btnLeft setTitle:@"取消" forState:UIControlStateNormal];
    self.titleStr = @"园长信箱";
    [self setupViews];
    [self updateRightBtnStatus];
}

-(void)setupViews
{
    UIView *superview = self.view;
    
    CGFloat margin = 5.0f;
    //输入
    UIView *inputBackground = [UIView new];
    [inputBackground setBackgroundColor:kColorWhite];
    inputBackground.userInteractionEnabled = YES;
    [superview addSubview:inputBackground];
    
    [inputBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview).with.offset(self.customNavigationView.maxY +margin);
        make.left.mas_equalTo(superview);
        make.right.mas_equalTo(superview);
        make.height.mas_equalTo(120.0f);        
    }];
    
    _textView = [[CHSCharacterCountTextView alloc] initWithMaxNumber:KMaxMailNumber placeHoder:@"输入您的问题和对学校的建议"];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.userInteractionEnabled = YES;
    _textView.delegate = self;
    [inputBackground addSubview:_textView];
    
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(inputBackground).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(inputBackground).with.offset(margin);
        make.right.mas_equalTo(inputBackground).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(100.0f);
    }];
    
    UIView *anonymousBackground = [UIView new];
    [anonymousBackground setBackgroundColor:kColorWhite];
    [superview addSubview:anonymousBackground];
    [anonymousBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(superview);
        make.top.mas_equalTo(inputBackground.mas_bottom).with.offset(margin);
        make.right.mas_equalTo(superview);
        make.height.mas_equalTo(45.0f);
    }];
    
    UILabel *anonymousTitles = [UILabel new];
    [anonymousTitles setText:@"匿名反馈"];
    [anonymousTitles setFont:kFontNormal];
    [anonymousTitles setTextColor:kColorBlack];
    [anonymousBackground addSubview:anonymousTitles];
    [anonymousTitles setBackgroundColor:[UIColor clearColor]];
    [anonymousTitles mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(anonymousBackground).with.offset(kEdgeInsetsLeft);
        make.centerY.mas_equalTo(anonymousBackground);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    UISwitch *anonymousSwitch = [[UISwitch alloc] init];
    _isAnonymousSwitch = anonymousSwitch;
    [anonymousSwitch setOnTintColor:KColorAppMain];
    [anonymousBackground addSubview:anonymousSwitch];
    [anonymousSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(anonymousBackground).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(anonymousBackground);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDown:)];
    [tapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGesture];
}



- (void)onClickBtn:(UIButton *)sender{
    [super onClickBtn:sender];
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //去除键盘
        [_textView resignFirstResponder];
        [self sendMail];
    }
}

-(void)sendMail
{
    [TXProgressHUD showHUDAddedTo:self.view withMessage:@""];
//    WEAKSELF
    WEAKSELF
    [[TXChatClient sharedInstance] sendGardenMail:[_textView.getContent trim] isAnonymous:_isAnonymousSwitch.isOn onCompleted:^(NSError *error, int64_t gardenMailId) {
        DDLogDebug(@"error:%@ gardenMailId:%lld",  error, gardenMailId);
        [TXProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(!error)
        {
            [MobClick event:@"create_newmessage" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"成功", @"园长信箱", nil] counter:1];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_MAILS object:nil];
            });
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MobClick event:@"create_newmessage" attributes:[NSDictionary dictionaryWithObjectsAndKeys:@"失败", @"园长信箱", nil] counter:1];
//            ButtonItem *confirm = [ButtonItem itemWithLabel:@"确定" andTextColor:kColorBlack action:^{
//            
//            }];
//            [weakSelf showAlertViewWithMessage:@"发送失败，请重新发送" andButtonItems:confirm, nil];
            [weakSelf showFailedHudWithTitle:@"发送失败，请重新发送"];
        }
    }];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self rdv_tabBarController] setTabBarHidden:YES animated:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [_textView resignFirstResponder];
}

#pragma mark - CHSCharacterCountTextViewDelegate
-(void)characterCountTextViewIsShowPlaceholder:(BOOL)isShowPlaceholder
{
    if([_textView.getContent trim].length == 0)
    {
        _isInputMailContent = NO;
    }
    else 
    {
        _isInputMailContent = !isShowPlaceholder;
    }
    [self updateRightBtnStatus];
}

-(void)updateRightBtnStatus
{
    [self.btnRight setEnabled:_isInputMailContent];
}

@end
