//
//  HomeWorkListBaseViewController.h
//  TXChatParent
//
//  Created by yi.meng on 16/2/18.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "EventViewController.h"

@interface HomeWorkListBaseViewController : EventViewController
{
    UITableView *_tableView;
}
@property(nonatomic, strong)UITableView *tableView;
//显示 无数据提示
-(void)updateNoDataStatus:(BOOL)isShow;
@end
