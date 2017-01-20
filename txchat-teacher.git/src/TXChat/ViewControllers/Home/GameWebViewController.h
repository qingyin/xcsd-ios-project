//
//  GameWebViewController.h
//  TXChatParent
//
//  Created by yi.meng on 16/2/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "GaoJuGestureRecognizer.h"
@interface GameWebViewController : BaseViewController

@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;
@property (strong,nonatomic) UIButton *btn;
@property (strong,nonatomic)  GaoJuGestureRecognizer *customGesturecognizer;
- (instancetype)initWithURLString:(NSString *)urlString;

@end
