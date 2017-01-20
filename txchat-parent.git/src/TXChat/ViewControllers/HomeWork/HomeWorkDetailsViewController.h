//
//  HomeWorkDetailsViewController.h
//  TXChatParent
//
//  Created by gaoju on 16/3/10.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "HomeWorkListViewController.h"
#import "GaoJuGestureRecognizer.h"
@protocol LHRAlertViewDelegate;
@interface HomeWorkDetailsViewController : BaseViewController
@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;
@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;
@property (nonatomic,copy) NSString *backH5code;
@property (strong,nonatomic) UIButton *btn;
@property (strong,nonatomic)  GaoJuGestureRecognizer *customGesturecognizer;
- (instancetype)initWithURLString:(NSString *)urlString;

@end
