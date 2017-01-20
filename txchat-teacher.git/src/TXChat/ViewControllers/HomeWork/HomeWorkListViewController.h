//
//  HomeWorkListViewController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "EventViewController.h"

@interface HomeWorkListViewController : EventViewController
{
    UITableView *_tableView;
}
@property(nonatomic, strong)UITableView *tableView;
//显示 无数据提示
-(void)updateNoDataStatus:(BOOL)isShow;

@end
