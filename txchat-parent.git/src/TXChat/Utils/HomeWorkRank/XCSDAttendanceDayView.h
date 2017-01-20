//
//  XCSDAttendanceDayView.h
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCSDCalendarDayModel.h"
/**
 *  考勤 日期显示
 */
@interface XCSDAttendanceDayView : UIView
@property(nonatomic, assign)XCSDATTENDANCEDAYTYPE attendanceDayType;
@property(nonatomic, assign)NSInteger currentDay;
@property(nonatomic, assign)NSInteger weekDay;
@property(nonatomic, assign)BOOL isToday;

@end
