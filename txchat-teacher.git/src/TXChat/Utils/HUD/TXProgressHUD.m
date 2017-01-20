//
//  TXProgressHUD.m
//  TXChat
//
//  Created by Cloud on 15/6/10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXProgressHUD.h"

@implementation TXProgressHUD

+ (TXProgressHUD *)showHUDAddedTo:(UIView *)view withMessage:(NSString *)message{
    TXProgressHUD *hud = (TXProgressHUD *)[TXProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    if (message && [message length]) {
        hud.labelText = message;
    }
    return hud;
}

+ (void)showErrorMessage:(UIView *)view withMessage:(NSString *)message{
    TXProgressHUD *hud = (TXProgressHUD *)[TXProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeNone;
    if (message && [message length]) {
        hud.labelText = message;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TXProgressHUD hideHUDForView:view animated:YES];
    });
    
}

- (void)showErrorMessage:(NSString *)message{
    self.mode = MBProgressHUDModeNone;
    if (message && [message length]) {
        self.labelText = message;
    }
    [self hide:YES afterDelay:2.f];
}

+ (TXProgressHUD *)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:[TXProgressHUD class]]) {
            return (TXProgressHUD *)subview;
        }
    }
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
