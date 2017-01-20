//
//  TXProgressHUD.h
//  TXChat
//
//  Created by Cloud on 15/6/10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MBProgressHUD.h"

@interface TXProgressHUD : MBProgressHUD

+ (TXProgressHUD *)showHUDAddedTo:(UIView *)view withMessage:(NSString *)message;
+ (void)showErrorMessage:(UIView *)view withMessage:(NSString *)message;
- (void)showErrorMessage:(NSString *)message;
@end
