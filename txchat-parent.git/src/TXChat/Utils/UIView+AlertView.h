//
//  UIView+AlertView.h
//  TXChat
//
//  Created by Cloud on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertView.h"

@interface ButtonItem : NSObject

@property (retain, nonatomic) NSString *label;
@property (nonatomic, strong) UIColor *textColor;
@property (copy, nonatomic) void (^action)();
+(id)item;
+(id)itemWithLabel:(NSString *)inLabel;
+(id)itemWithLabel:(NSString *)inLabel andTextColor:(UIColor *)textColor action:(void(^)(void))action;
@end

@class ButtonItem;

@interface UIView (AlertView)

@property (nonatomic, strong) CustomAlertView *alertView;

- (void)showAlertViewWithMessage:(NSString *)message andButtonItems:(ButtonItem *)buttonItem, ...NS_REQUIRES_NIL_TERMINATION;
- (void)showVerticalAlertViewWithMessage:(NSString *)message andButtonItems:(ButtonItem *)buttonItem, ...NS_REQUIRES_NIL_TERMINATION;
//屏蔽特定error的弹窗
- (void)showAlertViewWithError:(NSError *)error andButtonItems:(ButtonItem *)buttonItem, ...NS_REQUIRES_NIL_TERMINATION;
- (void)showAlertViewWithMessage:(NSString *)message andButtonItemsArr:(NSArray *)buttonsArray;
- (void)showAlertViewWithError:(NSError *)error andButtonItemsArr:(NSArray *)buttonsArray;


@end
