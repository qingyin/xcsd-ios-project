//
//  XCSDClassHomework.m
//  Pods
//
//  Created by gaoju on 16/4/5.
//
//

#import "XCSDClassHomework.h"

@implementation XCSDClassHomework
-(instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
   
    _homeworkId=[resultSet longLongIntForColumn:@"homeworkId"];
    _className=[resultSet stringForColumn:@"className"];
    _title=[resultSet stringForColumn:@"title"];
    _type=(XCSDPBHomeworkType) [resultSet longForColumn:@"type"];
    _sendTime=[resultSet longLongIntForColumn:@"sendTime"];
    _finishedCount=[resultSet intForColumn:@"finishedCount"];
    _totalCount=[resultSet intForColumn:@"totalCount"];
    
    return self;
}
-(instancetype)loadValueFromPbObject:(XCSDPBClassHomework *)classHomework{
    _homeworkId=classHomework.homeworkId;
    _className=classHomework.className;
    _title=classHomework.title;
    _type=classHomework.type;
    _sendTime=classHomework.sendTime;
    _finishedCount=classHomework.finishedCount;
    _totalCount=classHomework.totalCount;
    
    return self;
}

@end
