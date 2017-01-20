//
//  NotifyListBaseViewController.h
//  TXChat
//
//  Created by lyt on 15-6-8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "EventViewController.h"

@interface NoticeListBaseViewController : EventViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
}
@property(nonatomic, strong)UITableView *tableView;
//显示 无数据提示
-(void)updateNoDataStatus:(BOOL)isShow;

@end
