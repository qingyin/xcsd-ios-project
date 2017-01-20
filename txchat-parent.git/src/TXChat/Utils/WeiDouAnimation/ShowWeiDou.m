//
//  RcvWBean.m
//  TXChatTeacher
//
//  Created by lyt on 15/10/19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ShowWeiDou.h"
#import "CNPPopupController.h"
#import "AppDelegate.h"

const CGFloat sizeWidth = 35.0f;
#define KViewTag     0x1990001
@interface ShowWeiDou()<CNPPopupControllerDelegate>
@end

@implementation ShowWeiDou

+ (instancetype)sharedManager
{
    static ShowWeiDou *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc ] init];
    });
    return _sharedManager;
}



-(void)showRcvWeiDou:(NSInteger)weiDouNumber
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.tag = KViewTag;
    
    UIView *backView = [UIView new];
    backView.backgroundColor = RGBCOLOR(0xff, 0xbb, 0x38);
    backView.layer.cornerRadius = sizeWidth/2.0f;
    backView.layer.masksToBounds = YES;
    [contentView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(contentView).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    UILabel *numberLabel = [UILabel new];
    [numberLabel setText:[NSString stringWithFormat:@"+%@", @(weiDouNumber)]];
    [numberLabel setTextColor:kColorWhite];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    numberLabel.font = kFontTiny;
    [backView addSubview:numberLabel];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backView);
        make.top.mas_equalTo(backView).with.offset(3);
        make.right.mas_equalTo(backView);
        make.height.mas_equalTo(@(sizeWidth/2.0f));
    }];
    
    UILabel *textLabel = [UILabel new];
    [textLabel setText:@"微豆"];
    [textLabel setTextColor:kColorWhite];
    textLabel.font = kFontTimeTitle;
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    [backView addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(backView);
        make.top.mas_equalTo(numberLabel.mas_bottom).with.offset(-5);
        make.right.mas_equalTo(backView);
        make.height.mas_equalTo(@(sizeWidth/2.0f));
    }];
    
    contentView.frame = CGRectMake(kScreenWidth/2-sizeWidth/2.0f, kScreenHeight/2-sizeWidth/2.0f, sizeWidth, sizeWidth);
    [appDelegate.window addSubview:contentView];
//    [UIView beginAnimations:@"KCBasicAnimation" context:nil];
//    [UIView setAnimationDuration:3.0];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
//    contentView.center = CGPointMake(kScreenWidth/2, -sizeWidth/2.0f);
//    
//    //开始动画
    [UIView commitAnimations];
    contentView.alpha = 0.f;
    CGAffineTransform transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [contentView setTransform:transform];
    [UIView animateWithDuration:0.5f animations:^{
        contentView.alpha = 1.f;
        CGAffineTransform tr = CGAffineTransformIdentity;
        [contentView setTransform:tr];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect rect = contentView.frame;
            rect.origin.y -= 100;
            contentView.frame = rect;
            contentView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [contentView removeFromSuperview];
        }];
    }];
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"animation is over ...");
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *content = [appDelegate.window viewWithTag:KViewTag];
    if(content)
    {
        [content removeFromSuperview];
    }
    
}



@end
