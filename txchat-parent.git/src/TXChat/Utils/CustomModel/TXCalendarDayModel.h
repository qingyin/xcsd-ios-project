//
//  TXCalendarDayModel.h
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, TXATTENDANCEDAYTYPE)
{
    TXATTENDANCEDAYTYPE_ATTENDANCE = 0, //出席
    TXATTENDANCEDAYTYPE_NORMAL, // 正常 今天以后的日期
    TXATTENDANCEDAYTYPE_ABSENT, //缺席
    TXATTENDANCEDAYTYPE_LEAVE, //请假
    TXATTENDANCEDAYTYPE_HOLIDAY, //节假日
};
@interface TXCalendarDayModel : NSObject
//几号
@property(nonatomic, assign)NSInteger day;
//星期几
@property(nonatomic, assign)NSInteger weekDay;
//今天日期的状态
@property(nonatomic, assign)TXATTENDANCEDAYTYPE attendanceDayType;
//是不是今天
@property(nonatomic, assign)BOOL isToday;
@end
