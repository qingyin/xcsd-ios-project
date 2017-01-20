//
//  TXAttendanceDayView.h
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXCalendarDayModel.h"
/**
 *  考勤 日期显示
 */

@interface TXAttendanceDayView : UIView
@property(nonatomic, assign)TXATTENDANCEDAYTYPE attendanceDayType;
@property(nonatomic, assign)NSInteger currentDay;
@property(nonatomic, assign)NSInteger weekDay;
@property(nonatomic, assign)BOOL isToday;
@end
