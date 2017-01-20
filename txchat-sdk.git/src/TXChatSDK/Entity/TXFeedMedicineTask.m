//
// Created by lingqingwan on 6/29/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXFeedMedicineTask.h"


@implementation TXFeedMedicineTask {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _feedMedicineTaskId = [resultSet longLongIntForColumn:@"feed_medicine_task_id"];
    _content = [resultSet stringForColumn:@"content"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    _attaches = attaches.length == 0
            ? [NSMutableArray array]
            : [[attaches componentsSeparatedByString:@","] mutableCopy];
    _parentUserId = [resultSet longLongIntForColumn:@"parent_user_id"];
    _parentUsername = [resultSet stringForColumn:@"parent_user_name"];
    _parentAvatarUrl = [resultSet stringForColumn:@"parent_user_avatar_url"];
    _classId = [resultSet longLongIntForColumn:@"class_id"];
    _className = [resultSet stringForColumn:@"class_name"];
    _classAvatarUrl = [resultSet stringForColumn:@"class_avatar_url"];
    _beginDate = [resultSet intForColumn:@"begin_date"];
    _isRead = [resultSet boolForColumn:@"is_read"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBFeedMedicineTask *)txpbFeedMedicineTask {
    _feedMedicineTaskId = txpbFeedMedicineTask.id;
    _classId = txpbFeedMedicineTask.classId;
    _className = txpbFeedMedicineTask.className;
    _classAvatarUrl = txpbFeedMedicineTask.classAvatarUrl;
    _parentUserId = txpbFeedMedicineTask.parentUserId;
    _parentUsername = txpbFeedMedicineTask.parentName;
    _parentAvatarUrl = txpbFeedMedicineTask.parentAvatarUrl;
    _beginDate = txpbFeedMedicineTask.beginDate;
    self.createdOn = txpbFeedMedicineTask.createdOn;
    _content = txpbFeedMedicineTask.desc;
    _attaches = [[NSMutableArray alloc] init];
    for (uint i = 0; i < txpbFeedMedicineTask.attaches.count; ++i) {
        TXPBAttach *txpbAttach = txpbFeedMedicineTask.attaches[i];
        [_attaches addObject:txpbAttach.fileurl];
    }
    self.updatedOn = txpbFeedMedicineTask.updateOn;
    _isRead = txpbFeedMedicineTask.hasRead;
    return self;
}


@end