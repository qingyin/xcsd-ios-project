//
//  TXMessageZoomViewController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/17.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXMessageZoomViewController.h"

@interface TXMessageZoomViewController ()
{
    UITextView *_textView;
    UIScrollView *_messageScrollView;
    UIView *_contentView;
    UIView *_topView;
    UIView *_bottomView;
    UILabel *_messageLabel;
}
@end

@implementation TXMessageZoomViewController

//- (void)dealloc
//{
//    NSLog(@"%s",__func__);
//}
- (instancetype)initWithDisplayMessage:(NSString *)msg
{
    self = [super init];
    if (self) {
        _displayString = msg;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupDisplayMessageView];
    //添加手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGestureHandled:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGesture];
}
- (void)setupDisplayMessageView
{
    _messageScrollView = [[UIScrollView alloc] init];
    _messageScrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_messageScrollView];
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    [_messageScrollView addSubview:_contentView];
    [_messageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).with.insets(UIEdgeInsetsMake(30, 20, 30, 20));
    }];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_messageScrollView);
        make.width.equalTo(_messageScrollView);
        make.height.greaterThanOrEqualTo(self.view).offset(-60);
    }];
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_topView];
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_bottomView];
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.font = [UIFont systemFontOfSize:40];
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _messageLabel.textColor = [UIColor blackColor];
    _messageLabel.text = _displayString;
    [_contentView addSubview:_messageLabel];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentView);
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.height.lessThanOrEqualTo(self.view).offset(-60);
    }];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.top.equalTo(_topView.mas_bottom);
        make.bottom.equalTo(_bottomView.mas_top);
        make.centerY.equalTo(_contentView);
    }];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.bottom.equalTo(_contentView);
        make.height.lessThanOrEqualTo(self.view).offset(-60);
        make.height.equalTo(_topView);
    }];
}
//设置展示字符串
- (void)setDisplayString:(NSString *)displayString
{
    _displayString = displayString;
    _textView.text = displayString;
}

//点击手势
- (void)onTapGestureHandled:(UITapGestureRecognizer *)gesture
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
