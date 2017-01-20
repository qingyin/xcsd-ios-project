//
//  HomeWorkTestViewController.h
//  TXChatParent
//
//  Created by gaoju on 16/3/10.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "GaoJuGestureRecognizer.h"
@interface HomeWorkTestViewController : BaseViewController

@property (strong,nonatomic) UIButton *btn;
@property (strong,nonatomic)  GaoJuGestureRecognizer *customGesturecognizer;

@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;

- (instancetype)initWithURLString:(NSString *)urlString;

@end
