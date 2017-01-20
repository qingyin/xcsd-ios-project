//
//  BabyAttendanceViewController.h
//  TXChatParent
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BabyAttendanceViewController : BaseViewController
/**
 *  当月最大天数
 *
 *  @param month 月
 *  @param year  年
 *
 *  @return 当月最大天数
 */
+(NSInteger)getDaysInMonth:(NSInteger)month year:(NSInteger)year;
@end
