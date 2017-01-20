//
//  NotifySelectGroupViewController.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^UPDATEDEPARTMENTSSELECTED)(NSArray *selectedDeparments);

@interface NoticeSelectGroupViewController : BaseViewController

@property(nonatomic, strong)UPDATEDEPARTMENTSSELECTED groupSelectedUpdate;

//重新选择接收人
-(id)initWithSelectedDepartments:(NSArray *)selectedDepartments;

@end
