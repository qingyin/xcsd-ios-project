//
//  LeaveDetailViewController.m
//  TXChatTeacher
//
//  Created by Cloud on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "EditDetailViewController.h"
#import "UIImageView+EMWebCache.h"
#import "UIViewController+STPopup.h"
#import "STPopup.h"
#import "editDetailView.h"
#import "BroadcastInfoViewController.h"

@interface EditDetailViewController () <UITextViewDelegate>

@property (nonatomic,strong) editDetailView *editView;

@end

@implementation EditDetailViewController

- (id)initWithLeave:(TXPBLeave *)leave{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTapBackgroundView) name:@"TapBackgroundView" object:nil];
        
        self.editView = [[NSBundle mainBundle] loadNibNamed:@"editDetailView" owner:nil options:nil][0];
        self.editView.frame = CGRectMake(0, 0, kScreenWidth - 60, ceilf((kScreenWidth - 60)*300/260));
        
        self.contentSizeInPopup = CGSizeMake(kScreenWidth - 60, self.editView.height_);
        
        self.editView.commitBtn.layer.masksToBounds = YES;
        self.editView.commitBtn.layer.cornerRadius = 4;
        
        self.editView.textView.layer.masksToBounds = YES;
        self.editView.textView.layer.cornerRadius = 1;
        self.editView.textView.layer.borderWidth = 0.5;
        self.editView.textView.layer.borderColor = kColorBorder.CGColor;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardDown:)];
        [self.editView addGestureRecognizer:tap];
        [self.view addSubview:self.editView];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChanged) name:UITextViewTextDidChangeNotification object:self.editView.textView];
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onPlayer" object:nil userInfo:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTapBackgroundView{
    if ([self.editView.textView isFirstResponder]) {
        [self.editView.textView resignFirstResponder];
    }else{
        [self.popupController dismiss];
    }
}

- (void)textDidChanged
{
    if (self.editView.textView.text.length != 0) {
        self.editView.hodleLable.hidden = YES;
    }else{
        self.editView.hodleLable.hidden = NO;
    }
    if (self.editView.textView.text.length >= 500) {
        self.editView.textView.text = [self.editView.textView.text substringToIndex:500];
        return;
    }
}

- (void)keyboardDown:(UITapGestureRecognizer *)recognizer
{
    //去除键盘
    [self.editView.textView resignFirstResponder];
}

@end
