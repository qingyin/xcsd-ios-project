//
//  NoticeSelectedModel.h
//  TXChat
//
//  Created by lyt on 15-6-23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoticeSelectedModel : NSObject
@property(nonatomic, assign)int64_t departmentId;//部门id 选中用户列表为nil是全选
@property(nonatomic, strong)NSArray *selectedUsers;//选中用户列表
@property(nonatomic, assign)NSInteger allDepartmentUsersCount;//整个班级组人员数
@property(nonatomic, assign)TXPBDepartmentType departmentType;//群类型
@property(nonatomic, strong)NSString *departmentName;//部门名字
@end
