//
//  XCSDHomeWork.m
//  Pods
//
//  Created by gaoju on 16/3/15.
//
//

#import "XCSDHomeWork.h"

@implementation XCSDHomeWork
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _HomeWorkId = [resultSet longLongIntForColumn:@"HomeWorkId"];
    _memberId = [resultSet longLongIntForColumn:@"memberId"];
    _title = [resultSet stringForColumn:@"title"];
    _sendUserId = [resultSet longLongIntForColumn:@"sendUserId"];
    _senderName = [resultSet stringForColumn:@"senderName"];
    _senderAvatar = [resultSet stringForColumn:@"senderAvatar"];
    _targetName = [resultSet stringForColumn:@"targetName"];
    
   _status = (XCSDPBHomeworkStatus) [resultSet longForColumn:@"status"];
    _hasRead = [resultSet boolForColumn:@"hasRead"];
    _sendTime = [resultSet longLongIntForColumn:@"sendTime"];
    

    
    return self;
}
- (instancetype)loadValueFromPbObject:(XCSDPBHomework *)xcsdHomeWork {
    
    _HomeWorkId=xcsdHomeWork.id;
    _memberId=xcsdHomeWork.memberId;
    _title=xcsdHomeWork.title;
    _sendUserId=xcsdHomeWork.sendUserId;
    _senderName=xcsdHomeWork.senderName;
    _senderAvatar=xcsdHomeWork.senderAvatar;
    _targetName=xcsdHomeWork.targetName;
    _status=xcsdHomeWork.status;
    _hasRead=xcsdHomeWork.hasRead;
    _sendTime=xcsdHomeWork.sendTime;
    
    return self;
}

@end
