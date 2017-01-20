//
// Created by lingqingwan on 9/22/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDepartmentPhoto.h"


@implementation TXDepartmentPhoto {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _departmentPhotoId = [resultSet longLongIntForColumn:@"department_photo_id"];
    _departmentId = [resultSet longLongIntForColumn:@"department_id"];
    _fileUrl = [resultSet stringForColumn:@"file_url"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBDepartmentPhoto *)txpbDepartmentPhoto
                         departmentId:(int64_t)departmentId {
    _departmentPhotoId = txpbDepartmentPhoto.id;
    _fileUrl = txpbDepartmentPhoto.fileKey;
    _departmentId = departmentId;
    self.createdOn = txpbDepartmentPhoto.createOn;
    return self;
}

@end