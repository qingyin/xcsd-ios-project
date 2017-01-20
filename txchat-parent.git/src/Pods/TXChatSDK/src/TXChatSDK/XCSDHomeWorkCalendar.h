//
//  XCSDHomeWorkCalendar.h
//  Pods
//
//  Created by gaoju on 16/3/21.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"

@interface XCSDHomeWorkCalendar : TXEntityBase
@property (nonatomic) int32_t unfinished;  //未完成的日期
@property (nonatomic) int32_t finished;   //完成的日期

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDHomeWorkCalendar *)xcsdHomeWorkCalendar;
@end
