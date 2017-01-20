//
//  NotifySelectMembersViewController.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^UPDATEMEMEBERSELECTED)(NSArray *userArray, int64_t departmentId);


@interface MuteSelectMembersViewController : BaseViewController
@property(nonatomic, strong)UPDATEMEMEBERSELECTED updateMemberSelected;

//根据 选择的人和部门 初始化选择列表
-(id)initWithDepartmentId:(int64_t)departmentId selectedUsers:(NSArray *)selectedUsers;

-(id)initWithDepartmentId:(int64_t)departmentId;
@end
