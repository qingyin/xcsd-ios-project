//
//  HomeWorkRecordViewController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/3/29.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeWorkRecordViewController : BaseViewController

{
    UITableView *_tableView;
} 
@property(nonatomic, strong)UITableView *tableView;
//显示 无数据提示

@property (nonatomic) int64_t  hkId;
-(void)updateNoDataStatus:(BOOL)isShow;

@end
