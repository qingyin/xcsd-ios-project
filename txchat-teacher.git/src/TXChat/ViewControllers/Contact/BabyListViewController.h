//
//  BabyListViewController.h
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface BabyListViewController : BaseViewController

//根据 departmentid初始化 孩子列表
-(id)initWithDepartmentId:(int64_t )departmentId;

@end
