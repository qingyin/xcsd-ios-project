//
//  GxqBackgroundView.m
//  自定义弹出框
//
//  Created by 高盛通 on 16/2/16.
//  Copyright © 2016年 Big Nerd Ranch. All rights reserved.
//

#import "GxqAlertView.h"
#define screenH  [UIScreen mainScreen].bounds.size.height
#define screenW  [UIScreen mainScreen].bounds.size.width
@implementation GxqAlertView

+ (void)showWithTipText:(NSString *)tipText descText:(NSString *)descText LeftText:(NSString *)leftText second:(NSInteger)seconds rightText:(NSString *)rightText LeftBlock:(GxqLeftBlock)leftBlock RightBlock:(GxqRightBlock)rightBlock
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;

    GxqAlertView *selfView = [[self alloc]initWithFrame:[UIScreen mainScreen].bounds];
    selfView.backgroundColor = [UIColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:0.5];
    //selfView.alpha = 0.2;
    [keyWindow addSubview:selfView];
    
    //弹出框
    [selfView contentViewWithTipText:tipText descText:descText LeftText:leftText second:seconds rightText:rightText leftBlock:leftBlock RightBlock:rightBlock];
}

+ (void)dismiss
{
    
}

- (void)contentViewWithTipText:(NSString *)tipText descText:(NSString *)descText LeftText:(NSString *)leftText second:(NSInteger)seconds rightText:(NSString *)rightText leftBlock:(GxqLeftBlock)leftBlock RightBlock:(GxqRightBlock)rightBlock
{
    self.leftBlock = leftBlock;
    self.rightBlock = rightBlock;
    self.seconds = seconds + 1;
    CGFloat alertViewW = screenW * 0.8;
    CGFloat alertViewH = 150;
    UIView *alertView = [UIView new];
    
    alertView.alpha = 0;
    alertView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.25f animations:^{
        alertView.alpha = 1.0;
        alertView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];

    
    alertView.frame = CGRectMake((screenW - alertViewW) * 0.5, (screenH - alertViewH) * 0.5, alertViewW, alertViewH);
    alertView.backgroundColor=[UIColor groupTableViewBackgroundColor];
    //alertView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1];
    alertView.layer.masksToBounds=YES;
    alertView.layer.cornerRadius=7;
    
    [self addSubview:alertView];
    
    
    UILabel *tipLabel = [UILabel new];
    tipLabel.frame = CGRectMake(0, 20, alertView.frame.size.width, 30);
    tipLabel.text = tipText;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
    tipLabel.textColor = [UIColor colorWithRed:72/255 green:72/255 blue:72/255 alpha:1];
    
    [alertView addSubview:tipLabel];
    
    UILabel *descLabel = [UILabel new];
    descLabel.frame = CGRectMake(0, 50, alertView.frame.size.width, 30);
    descLabel.textAlignment = NSTextAlignmentCenter;
    descLabel.text = descText;
    descLabel.font = [UIFont systemFontOfSize:15];
    descLabel.textColor = [UIColor colorWithRed:72/255 green:72/255 blue:72/255 alpha:1];
    [alertView addSubview:descLabel];
    
//    UIView *lineHView = [UIView new];
//    lineHView.frame = CGRectMake(0, 100, alertView.frame.size.width, 0.5);
//    lineHView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.87 alpha:1];
//    [alertView addSubview:lineHView];
//    
//    UIView *lineVView = [UIView new];
//    lineVView.frame = CGRectMake(alertView.frame.size.width * 0.5, CGRectGetMaxY(lineHView.frame), 0.5, alertView.frame.size.height -CGRectGetMaxY(lineHView.frame));
//    lineVView.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.87 alpha:1];
//    [alertView addSubview:lineVView];
    
    UILabel *cancelLabel = [[UILabel alloc]init];
    cancelLabel.frame = CGRectMake(0, 100, alertView.frame.size.width/4 + 10, 40);
    cancelLabel.text = leftText;
    cancelLabel.font = [UIFont systemFontOfSize:15];
    cancelLabel.textColor = [UIColor colorWithRed:0.19 green:0.62 blue:0.78 alpha:1];
    cancelLabel.textAlignment = NSTextAlignmentRight;
    [alertView addSubview:cancelLabel];
    
    UILabel *timeLabel = [UILabel new];
    timeLabel.frame = CGRectMake(alertView.frame.size.width/4 + 10, 115, self.frame.size.width / 4 - 5, 12);
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor redColor];
    self.timeLabel = timeLabel;
    //timeLabel.text = [NSString stringWithFormat:@"(%zd%@)",1,@"s"];
   // [alertView addSubview:timeLabel];
    
   // NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(btnChange:) userInfo:nil repeats:YES];
    //_timer = timer;
    //[timer fire];
    
    UIButton *sureBtn = [UIButton new];
    sureBtn.frame = CGRectMake((alertView.frame.size.width-45 )* 0.5+30 , 100, (alertView.frame.size.width-45 )* 0.5, 40);
    [sureBtn addTarget:self action:@selector(sureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitle:rightText forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    sureBtn.backgroundColor=[UIColor colorWithRed:65/255.0 green:195/255.0 blue:255/255.0 alpha:1];
    sureBtn.layer.masksToBounds=YES;
    sureBtn.layer.cornerRadius=7;
    sureBtn.layer.borderWidth=1;
    sureBtn.layer.borderColor=[UIColor colorWithRed:65/255.0 green:195/255.0 blue:255/255.0 alpha:1].CGColor;
    [alertView addSubview:sureBtn];
    
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.frame = CGRectMake(15, 100, (alertView.frame.size.width-45 )* 0.5, 40);
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitle:leftText forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.layer.masksToBounds=YES;
    cancelBtn.layer.cornerRadius=7;
    cancelBtn.layer.borderWidth=1;
    cancelBtn.layer.borderColor=[UIColor whiteColor].CGColor;

    [alertView addSubview:cancelBtn];
}

- (void)sureBtnClick:(UIButton *)btn
{
    NSLog(@"点击了确定按钮");
    self.rightBlock();
    [self closeView];
}

- (void)cancelBtnClick:(UIButton *)btn
{
    NSLog(@"点击了取消按钮");
    self.leftBlock();
    [self closeView];
}

- (void)btnChange:(UIButton *)btn
{
    _seconds--;
    //    [_leftBtn setTitle:[NSString stringWithFormat:@"取消(%zds)",_seconds] forState:UIControlStateNormal];
    _timeLabel.text = [NSString stringWithFormat:@"(%zd%@)",_seconds,@"s"];
    if (_seconds == 0) {
        [_timer invalidate];
        [self closeView];
        self.leftBlock();
  }
}


-(void)closeView
{
    [UIView animateWithDuration:0.3f animations:^{
        [self.subviews objectAtIndex:0].alpha = 0;
        [self.subviews objectAtIndex:0].transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
