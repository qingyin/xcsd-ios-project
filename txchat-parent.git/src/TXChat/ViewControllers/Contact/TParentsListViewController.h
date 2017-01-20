//
//  TParentsListViewController.h
//  TXChatTeacher
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface TParentsListViewController : BaseViewController
//根据 departmentid初始化 宝宝列表
-(id)initWithDepartmentId:(int64_t )departmentId;
@end
