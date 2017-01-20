//
//  XCSDSendHomework.m
//  Pods
//
//  Created by gaoju on 16/4/6.
//
//

#import "XCSDSendHomework.h"

@implementation XCSDSendHomework
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    _scope=(XCSDPBStudentScope)[resultSet longForColumn:@"scope"];
    _classId=[resultSet longLongIntForColumn:@"classId"];
    return self;
}

- (instancetype)loadValueFromPbObject:(XCSDSendHomework *)homeWork{
    _scope=homeWork.scope;
    _classId=homeWork.classId;
    return self;
}
@end
