//
//  CircleHomeViewController.h
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface CircleHomeViewController : BaseViewController

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *todayArr;
@property (nonatomic, assign) int64_t userId;
@property (nonatomic, strong) NSString *portraitUrl;
@property (nonatomic, strong) NSString *nickName;

@end
