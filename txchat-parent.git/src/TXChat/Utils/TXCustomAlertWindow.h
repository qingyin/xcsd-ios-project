//
//  TXCustomAlertWindow.h
//  TXChat
//
//  Created by 陈爱彬 on 15/7/14.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXCustomAlertWindow : UIWindow

+ (TXCustomAlertWindow *)sharedWindow;

- (void)showWithView:(UIView *)view;

- (void)hide;

@end
