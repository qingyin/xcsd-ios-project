//
//  UnifyHomeWorkViewController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/4/7.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "GaoJuGestureRecognizer.h"
@interface UnifyHomeWorkViewController : BaseViewController
@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;
@property (nonatomic) int64_t classId;
@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;
@property (strong,nonatomic)  GaoJuGestureRecognizer *customGesturecognizer;
- (instancetype)initWithURLString:(NSString *)urlString;

@end
