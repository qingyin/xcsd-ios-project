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
@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;
@property (strong,nonatomic) NSString *ChildName;
@property (nonatomic) int64_t childId;
- (instancetype)initWithURLString:(NSString *)urlString;
@property (strong,nonatomic)  GaoJuGestureRecognizer *customGesturecognizer;
@end
