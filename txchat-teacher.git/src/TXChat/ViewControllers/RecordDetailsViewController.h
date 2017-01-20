//
//  RecordDetailsViewController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/4/8.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface RecordDetailsViewController : BaseViewController
@property (nonatomic,assign) HomeListType homeListType;
@property (nonatomic,weak) UIViewController *enterVc;

@property(strong,nonatomic) UIWindow *window;
@property(strong,nonatomic) UIButton *button;
@property (strong,nonatomic) NSString *member_Id;
- (instancetype)initWithURLString:(NSString *)urlString;
@end
