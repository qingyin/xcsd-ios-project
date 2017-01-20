//
//  LoginViewController.h
//  TXChat
//
//  Created by Cloud on 15/6/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

- (void)onLoginResponse:(NSString *)userName andPwd:(NSString *)pwd;

+ (void)loginEaseMob:(NSString *)userName andPwd:(NSString *)pwd;

@end
