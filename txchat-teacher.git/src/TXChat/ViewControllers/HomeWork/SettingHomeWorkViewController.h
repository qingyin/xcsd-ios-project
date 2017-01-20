//
//  SettingHomeWorkViewController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/3/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingHomeWorkViewController : BaseViewController
{
    UITableView *_tableView;
}

@property(nonatomic, strong)UITableView *tableView;
@property (nonatomic) int64_t classId;
//显示 无数据提示
-(void)updateNoDataStatus:(BOOL)isShow;
@end
