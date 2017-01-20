//
//  CustomNavigationController.m
//  TXChat
//
//  Created by Cloud on 15/7/20.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [self.view endEditing:YES];
    [super pushViewController:viewController animated:animated];
}



@end
