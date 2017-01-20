//
//  SignInAnimation.m
//  TXChatTeacher
//
//  Created by lyt on 15/10/19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SignInAnimation.h"
//#import "CNPPopupController.h"
#import "AppDelegate.h"
#define KViewTag     0x1980001
#define KPhotoWidth 585.0f/2.0f
#define KPhotoHight  539.0f/2.0f


@interface SignInAnimation()
//@property (nonatomic, strong) CNPPopupController *popupController;
@end


@implementation SignInAnimation
+ (instancetype)sharedManager
{
    static SignInAnimation *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc ] init];
    });
    return _sharedManager;
}

-(void)showSignInAnimation:(NSInteger)weiDouNumber
{
//    [self.popupController dismissPopupControllerAnimated:NO];
    
//    UIView *backgroundView = [[UIView alloc] init];
//    backgroundView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3f);
//    
//    
//    UIView *contentView = [[UIView alloc] init];
//    contentView.backgroundColor = [UIColor clearColor];
//
//    [backgroundView addSubview:contentView];
//    
//    UIImageView *imageView = [UIImageView new];
//    [imageView setImage:[UIImage imageNamed:@"weidou_signin"]];
//    [contentView addSubview:imageView];
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(contentView);
//        make.size.mas_equalTo(CGSizeMake(KPhotoWidth, KPhotoHight));
//    }];
//    
//    UILabel *numberLabel = [UILabel new];
//    [numberLabel setText:[NSString stringWithFormat:@"+%@", @(weiDouNumber)]];
//    [numberLabel setTextColor:RGBCOLOR(0xfc, 0xa0, 0x29)];
//    [numberLabel setTextAlignment:NSTextAlignmentRight];
//    numberLabel.font = kFontSuper_b;
//    [contentView addSubview:numberLabel];
//    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(contentView).with.offset(140.0f);
//        make.right.mas_equalTo(contentView.centerX).with.offset(-140);
//        make.height.mas_equalTo(@(30));
//        make.width.mas_equalTo(@(100));
//    }];
//    
//    UILabel *textLabel = [UILabel new];
//    [textLabel setText:@"微豆"];
//    [textLabel setTextColor:RGBCOLOR(0xfc, 0xa0, 0x29)];
//    textLabel.font = kFontSubTitle;
//    [textLabel setTextAlignment:NSTextAlignmentLeft];
//    [contentView addSubview:textLabel];
//    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(numberLabel.mas_right);
//        make.top.mas_equalTo(numberLabel.mas_top);
//        make.right.mas_equalTo(contentView);
//        make.height.mas_equalTo(@(30));
//    }];
//    
//    
//    contentView.frame = CGRectMake(kScreenWidth/2-KPhotoWidth/2.0f, kScreenHeight/2- KPhotoHight/2.0f, KPhotoWidth, KPhotoHight);
//    
//    
//    backgroundView.tag = KViewTag;
//    
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTab:)];
//    tap.numberOfTapsRequired = 1;
//    tap.numberOfTouchesRequired = 1;
//    tap.cancelsTouchesInView = NO;
//    contentView.userInteractionEnabled = YES;
//    imageView.userInteractionEnabled = YES;
//    backgroundView.userInteractionEnabled = YES;
//    [imageView addGestureRecognizer:tap];
//    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate.window addSubview:backgroundView];
//    
//    backgroundView.alpha = 0.0f;
//    backgroundView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//    CGAffineTransform  transform;
//    transform = CGAffineTransformScale(contentView.transform,0.5,0.5);
//    [contentView setTransform:transform];
//    contentView.frame = CGRectMake(kScreenWidth/2, kScreenHeight/2, KPhotoWidth/2, KPhotoHight/2);
//    contentView.center = CGPointMake(kScreenWidth/2,  kScreenHeight/2);
//    [UIView animateWithDuration:0.5f animations:^{
//        
//        backgroundView.alpha = 1.0f;
//        CGAffineTransform  newTransform;
//        newTransform = CGAffineTransformScale(contentView.transform,2,2);
//        [contentView setTransform:newTransform];
//        contentView.frame = CGRectMake(kScreenWidth/2-KPhotoWidth/2.0f, kScreenHeight/2- KPhotoHight/2.0f, KPhotoWidth, KPhotoHight);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.5f delay:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            
//            backgroundView.alpha = 0.0f;
//        } completion:^(BOOL finished) {
//            [backgroundView removeFromSuperview];
//        }];
//        
//    }];
    
    
    
    
//    self.popupController = [[CNPPopupController alloc] initWithContents:@[contentView]];
//    CNPPopupTheme *customTheme = [CNPPopupTheme defaultTheme];
//    customTheme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    customTheme.backgroundColor = RGBACOLOR(0, 0, 0, 0.3f);
//    customTheme.contentVerticalPadding = 0.0f;
//    customTheme.maxPopupWidth = 585.0f/2.0f;
//    customTheme.maskType = CNPPopupMaskTypeDimmed;
//    self.popupController.theme = customTheme;
//    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
//    self.popupController.theme.presentationStyle = CNPPopupPresentationStyleFadeIn;
//    self.popupController.delegate = self;
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTab:)];
//    tap.numberOfTapsRequired = 1;
//    tap.numberOfTouchesRequired = 1;
//    tap.cancelsTouchesInView = NO;
//    contentView.userInteractionEnabled = YES;
//    [contentView addGestureRecognizer:tap];
//    
//    [self.popupController presentPopupControllerAnimated:YES];

}

-(void)dismissTab:(UITapGestureRecognizer*)recognizer
{
//    [self.popupController dismissPopupControllerAnimated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *content = [appDelegate.window viewWithTag:KViewTag];
    if(content)
    {
        [content removeFromSuperview];
    }
}


//#pragma mark - CNPPopupController Delegate
//
//- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
//    NSLog(@"Dismissed with button title: %@", title);
//}
//
//- (void)popupControllerDidPresent:(CNPPopupController *)controller {
//    NSLog(@"Popup controller presented.");
//}

@end
