//
//  XCSDCalendarDayModel.h
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XCSDATTENDANCEDAYTYPE)
{
    XCSDATTENDANCEDAYTYPE_ATTENDANCE = 0, //完成作业的日期
    XCSDATTENDANCEDAYTYPE_NORMAL, // 正常 今天以后的日期
    XCSDATTENDANCEDAYTYPE_ABSENT, //未完成作业的日期
    XCSDATTENDANCEDAYTYPE_LEAVE, //请假
    XCSDATTENDANCEDAYTYPE_HOLIDAY, //节假日
};
@interface XCSDCalendarDayModel : NSObject
//几号
@property(nonatomic, assign)NSInteger day;
//星期几
@property(nonatomic, assign)NSInteger weekDay;
//今天日期的状态
@property(nonatomic, assign)XCSDATTENDANCEDAYTYPE attendanceDayType;
//是不是今天
@property(nonatomic, assign)BOOL isToday;
@end
