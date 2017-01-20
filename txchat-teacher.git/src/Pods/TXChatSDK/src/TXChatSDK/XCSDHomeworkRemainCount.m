//
//  XCSDHomeworkRemainCount.m
//  Pods
//
//  Created by gaoju on 16/4/9.
//
//

#import "XCSDHomeworkRemainCount.h"

@implementation XCSDHomeworkRemainCount
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    _classId=[resultSet longLongIntForColumn:@"classId"];
    return self;
}

- (instancetype)loadValueFromPbObject:(XCSDHomeworkRemainCount *)remain{
    _classId=remain.classId;
    return  self;
}

@end
