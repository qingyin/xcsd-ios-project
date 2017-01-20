//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDepartment.h"


@implementation TXDepartment {

}

- (instancetype)init {
    if (self = [super init]) {
        [self.transientProperties addObject:@"nameFirstLetter"];
        [self.transientProperties addObject:@"parentId"];
    }
    return self;
}

- (NSString *)tableName {
    return @"department";
}

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    return [self loadValueFromFMResultSetInner:resultSet];

    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _name = [resultSet stringForColumn:@"name"];
    _avatarUrl = [resultSet stringForColumn:@"avatar_url"];
    _departmentId = [resultSet longForColumn:@"department_id"];
    _groupId = [resultSet stringForColumn:@"group_id"];
    _showParent = [resultSet boolForColumn:@"show_parent"];
    _departmentType = (TXPBDepartmentType) [resultSet intForColumn:@"department_type"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBDepartment *)txpbDepartment {
    _departmentId = txpbDepartment.id;
    _name = txpbDepartment.name;
    _avatarUrl = txpbDepartment.classPhoto;
    _groupId = txpbDepartment.groupId;
    _showParent = txpbDepartment.showParent;
    _parentId = txpbDepartment.parentId;
    _departmentType = txpbDepartment.type;
    return self;
}


@end