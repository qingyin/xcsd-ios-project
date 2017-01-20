//
//  MainViewController.h
//  TXChatParent
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "BaseViewController.h"
#import "GaoJuGestureRecognizer.h"
@interface MainViewController : BaseViewController
@property (strong,nonatomic) UIButton *btn;
@property (strong,nonatomic) GaoJuGestureRecognizer * customGesturecognizer;

@property (assign,nonatomic) HomeListType homeListType;
@property (weak,nonatomic) UIViewController * enterVc;
@property (strong,nonatomic) UIWindow *window;
@property (strong,nonatomic) UIButton *button;

-(instancetype)initWithURLString:(NSString*)urlString;

@end
