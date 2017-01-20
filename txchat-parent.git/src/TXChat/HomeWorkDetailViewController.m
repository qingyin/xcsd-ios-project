//
//  HomeWorkDetailViewController.m
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeWorkDetailViewController.h"
#import "HomeworkListView.h"
#import "HomeworkDescriptionView.h"

@interface HomeWorkDetailViewController ()
{
    HomeworkListView *_homeworkListView;
    HomeworkDescriptionView *_descriotionView;
}


@end

@implementation HomeWorkDetailViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI{
    
    _homeworkListView = [[HomeworkListView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight / 2)];
    _descriotionView = [[HomeworkDescriptionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight / 2)];
    [self.view addSubview:_homeworkListView];
    [self.view addSubview:_descriotionView];
}

@end
