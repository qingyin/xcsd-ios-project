//
//  UIView+AlertView.m
//  TXChat
//
//  Created by Cloud on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UIView+AlertView.h"
#import <objc/runtime.h>

static void *CustomAlertViewKey = (void *)@"CustomAlertViewKey";

@implementation UIView (AlertView)

@dynamic alertView;

- (CustomAlertView *)alertView{
    return objc_getAssociatedObject(self, CustomAlertViewKey);
}

- (void)setAlertView:(CustomAlertView *)alertView
{
    objc_setAssociatedObject(self, CustomAlertViewKey, alertView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - ShowAlertView
- (void)showAlertViewWithError:(NSError *)error andButtonItems:(ButtonItem *)buttonItem, ...{
    if (error.code == TX_STATUS_UNAUTHORIZED ) {
        return;
    }
    
    NSString *message = error.userInfo[kErrorMessage];
    va_list args;
    va_start(args, buttonItem);
    
    NSMutableArray *buttonsArray = [NSMutableArray array];
    if(buttonItem)
    {
        [buttonsArray addObject:buttonItem];
        ButtonItem *nextItem;
        while((nextItem = va_arg(args, ButtonItem *)))
        {
            [buttonsArray addObject:nextItem];
        }
    }
    [self showAlertViewWithMessage:message andButtonItemsArr:buttonsArray];
    
}
- (void)showAlertViewWithError:(NSError *)error andButtonItemsArr:(NSArray *)buttonsArray{
    NSString *message = error.userInfo[kErrorMessage];
    [self showAlertViewWithMessage:message andButtonItemsArr:buttonsArray];
}
- (void)showAlertViewWithMessage:(NSString *)message andButtonItemsArr:(NSArray *)buttonsArray
{
    [self showAlertViewWithMessage:message andButtonItemsArr:buttonsArray isVertical:NO];
}

- (void)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message andButtonItemsArr:(NSArray *)buttonsArray
{
    [self showAlertViewWithTitle:title andMessage:message andButtonItemsArr:buttonsArray isVertical:NO];
}


/**
 *  弹出Alert效果
 *
 *  @param message      标题
 *  @param buttonsArray 按钮数组
 *  @param isVertical   按钮是否是竖着排列
 */
- (void)showAlertViewWithTitle:(NSString *)title
                    andMessage:(NSString *)message
             andButtonItemsArr:(NSArray *)buttonsArray
                    isVertical:(BOOL)isVertical{
    if (self.alertView) {
        [self.alertView removeFromSuperview];
    }
    [self endEditing:YES];
    
    CGFloat alertWidth = kScreenWidth - 80;
    
    UIView *alertBgView = [[UIView alloc] initWithFrame:CGRectZero];
    alertBgView.backgroundColor = kColorWhite;
    alertBgView.clipsToBounds = YES;
    alertBgView.layer.cornerRadius = 3.f;
    
    UILabel *titleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    titleLb.font = kFontLarge_b;
    titleLb.textColor = kColorBlack;
    titleLb.text = title;
    titleLb.textAlignment = NSTextAlignmentCenter;
    [alertBgView addSubview:titleLb];
    [titleLb sizeToFit];
    if (titleLb.height_) {
        titleLb.frame = CGRectMake(22, 20, alertWidth - 44, titleLb.height_);
    }
    
    UILabel *messageLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
    messageLb.font = kFontMiddle;
    messageLb.numberOfLines = 0;
    if (titleLb.height_) {
        messageLb.textColor = kColorGray;
    }else{
        messageLb.textColor = kColorBlack;
    }
    messageLb.textAlignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:7];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [message length])];
    messageLb.attributedText = attributedString;
    [alertBgView addSubview:messageLb];
    CGSize messageSize = [messageLb sizeThatFits:CGSizeMake(alertWidth - 44, MAXFLOAT)];
    if (messageSize.width < alertWidth - 44) {
        if (titleLb.height_) {
            messageLb.frame = CGRectMake((alertWidth - messageSize.width)/2 , 20 + titleLb.height_ + 20, messageSize.width, messageSize.height);
        }else{
            messageLb.frame = CGRectMake((alertWidth - messageSize.width)/2 , 20, messageSize.width, messageSize.height);
        }
    }else{
        if (titleLb.height_) {
            messageLb.frame = CGRectMake(22, 20 + titleLb.height_ + 20, messageSize.width, messageSize.height);
        }else{
            messageLb.frame = CGRectMake(22, 20, messageSize.width, messageSize.height);
        }
    }
    
    if (isVertical) {
        if ([buttonsArray count] == 0) {
            alertBgView.frame = CGRectMake(0, 0, alertWidth, messageLb.maxY + 18);
        }else{
            CGFloat width = messageLb.frame.size.width;
            CGFloat X = messageLb.minX;
            CGFloat Y = messageLb.maxY + 15;
//            __weak typeof(self)tmpObject = self;
            WEAKTEMP
            for(ButtonItem *item in buttonsArray)
            {
                NSInteger index = [buttonsArray indexOfObject:item];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                if (index != buttonsArray.count - 1) {
                    btn.layer.borderColor = kColorLine.CGColor;
                    btn.layer.borderWidth = kLineHeight;
                    [btn setTitleColor:kColorGray forState:UIControlStateNormal];
                    btn.backgroundColor = kColorClear;
                }else{
                    [btn setTitleColor:kColorWhite forState:UIControlStateNormal];
                    btn.backgroundColor = KColorAppMain;
                }
                btn.layer.cornerRadius = 3.f;
                btn.layer.masksToBounds = YES;
                [btn setTitle:item.label forState:UIControlStateNormal];
                btn.titleLabel.font = kFontMiddle;
                btn.frame = CGRectMake(X, Y, width, 34);
                [alertBgView addSubview:btn];
                [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                    [tmpObject.alertView close];
                    if (item.action) {
                        item.action();
                    }
                }];
                Y = btn.maxY + 10;
                alertBgView.frame = CGRectMake(0, 0, alertWidth, btn.maxY + 18);
            }
        }
    }else{
        if ([buttonsArray count] == 0) {
            alertBgView.frame = CGRectMake(0, 0, alertWidth, messageLb.maxY + 18);
        }else{
            CGFloat width = (alertWidth - 15 * (buttonsArray.count + 1))/buttonsArray.count;
            CGFloat X = 15;
//            __weak typeof(self)tmpObject = self;
            WEAKTEMP
            for(ButtonItem *item in buttonsArray)
            {
                NSInteger index = [buttonsArray indexOfObject:item];
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                if (index != buttonsArray.count - 1) {
                    btn.layer.borderColor = kColorLine.CGColor;
                    btn.layer.borderWidth = kLineHeight;
                    [btn setTitleColor:kColorGray forState:UIControlStateNormal];
                    btn.backgroundColor = kColorClear;
                }else{
                    [btn setTitleColor:kColorWhite forState:UIControlStateNormal];
                    btn.backgroundColor = KColorAppMain;
                }
                btn.layer.cornerRadius = 3.f;
                btn.layer.masksToBounds = YES;
                [btn setTitle:item.label forState:UIControlStateNormal];
                btn.titleLabel.font = kFontMiddle;
                btn.frame = CGRectMake(X, messageLb.maxY + 20, width, 34);
                [alertBgView addSubview:btn];
                [btn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
                    [tmpObject.alertView close];
                    if (item.action) {
                        item.action();
                    }
                }];
                X = btn.maxX + 15;
                alertBgView.frame = CGRectMake(0, 0, alertWidth, btn.maxY + 18);
            }
        }
    }
    self.alertView = [[CustomAlertView alloc] init];
    self.alertView.buttonTitles = [NSArray array];
    [self.alertView setContainerView:alertBgView];
    [self.alertView show];
    if ([buttonsArray count] == 0) {
        //1.5秒后消失
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.alertView close];
        });
    }
    self.alertView.dialogView.clipsToBounds = YES;
}
- (void)showAlertViewWithMessage:(NSString *)message
               andButtonItemsArr:(NSArray *)buttonsArray
                      isVertical:(BOOL)isVertical{
    [self showAlertViewWithTitle:nil andMessage:message andButtonItemsArr:buttonsArray isVertical:isVertical];
}

- (void)showAlertViewWithMessage:(NSString *)message andButtonItems:(ButtonItem *)buttonItem, ...{
    va_list args;
    va_start(args, buttonItem);
    
    NSMutableArray *buttonsArray = [NSMutableArray array];
    if(buttonItem)
    {
        [buttonsArray addObject:buttonItem];
        ButtonItem *nextItem;
        while((nextItem = va_arg(args, ButtonItem *)))
        {
            [buttonsArray addObject:nextItem];
        }
    }
    va_end(args);
    [self showAlertViewWithMessage:message andButtonItemsArr:buttonsArray];
}
//添加竖着的按钮alert
- (void)showVerticalAlertViewWithMessage:(NSString *)message andButtonItems:(ButtonItem *)buttonItem, ...{
    va_list args;
    va_start(args, buttonItem);
    
    NSMutableArray *buttonsArray = [NSMutableArray array];
    if(buttonItem)
    {
        [buttonsArray addObject:buttonItem];
        ButtonItem *nextItem;
        while((nextItem = va_arg(args, ButtonItem *)))
        {
            [buttonsArray addObject:nextItem];
        }
    }
    va_end(args);
    [self showAlertViewWithMessage:message andButtonItemsArr:buttonsArray isVertical:YES];
}
@end

@implementation ButtonItem

+(id)item
{
    return [self new];
}

+(id)itemWithLabel:(NSString *)inLabel
{
    ButtonItem *newItem = [self item];
    [newItem setLabel:inLabel];
    return newItem;
}

+(id)itemWithLabel:(NSString *)inLabel andTextColor:(UIColor *)textColor action:(void(^)(void))action
{
    ButtonItem *newItem = [self itemWithLabel:inLabel];
    newItem.textColor = textColor;
    [newItem setAction:action];
    return newItem;
}

@end
