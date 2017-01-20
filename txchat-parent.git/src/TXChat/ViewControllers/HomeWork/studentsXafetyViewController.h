//
//  studentsXafetyViewController.h
//  TXChatParent
//
//  Created by gaoju on 16/3/25.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "EventViewController.h"

@interface studentsXafetyViewController : EventViewController
@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;

- (instancetype)initWithURLString:(NSString *)urlString;
@end
