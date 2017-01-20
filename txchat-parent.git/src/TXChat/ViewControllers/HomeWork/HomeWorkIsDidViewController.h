//
//  HomeWorkIsDidViewController.h
//  TXChatParent
//
//  Created by gaoju on 16/3/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeWorkIsDidViewController : BaseViewController
@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;

- (instancetype)initWithURLString:(NSString *)urlString;
@end
