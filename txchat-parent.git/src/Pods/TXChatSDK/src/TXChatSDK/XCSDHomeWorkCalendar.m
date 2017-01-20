//
//  XCSDHomeWorkCalendar.m
//  Pods
//
//  Created by gaoju on 16/3/21.
//
//

#import "XCSDHomeWorkCalendar.h"

@implementation XCSDHomeWorkCalendar
-(instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    _unfinished=[resultSet intForColumn:@"unfinished"];
    _finished=[resultSet intForColumn:@"finished"];

    return self;
}
-(instancetype)loadValueFromPbObject:(XCSDHomeWorkCalendar *)xcsdHomeWorkCalendar{
    _unfinished= xcsdHomeWorkCalendar.unfinished;
    _finished= xcsdHomeWorkCalendar.finished;
    
    return self;
    
}
@end
