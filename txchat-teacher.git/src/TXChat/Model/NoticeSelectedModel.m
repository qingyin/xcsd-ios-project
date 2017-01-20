//
//  NoticeSelectedModel.m
//  TXChat
//
//  Created by lyt on 15-6-23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NoticeSelectedModel.h"

@implementation NoticeSelectedModel

-(id)init
{
    self = [super init];
    if(self)
    {
        _departmentId = 0;
        _selectedUsers = nil;
        _allDepartmentUsersCount = 0;
    }
    return self;
}

@end
