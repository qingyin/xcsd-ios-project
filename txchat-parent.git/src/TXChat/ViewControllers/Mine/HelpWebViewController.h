//
//  HelpWebViewController.h
//  TXChatParent
//
//  Created by gaoju on 16/4/16.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface HelpWebViewController : BaseViewController
@property (strong,nonatomic) UIButton *btn;


@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;

- (instancetype)initWithURLString:(NSString *)urlString;
@end
