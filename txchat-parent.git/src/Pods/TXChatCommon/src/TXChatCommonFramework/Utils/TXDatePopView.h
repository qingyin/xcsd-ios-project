//
//  TXDatePopView.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/4.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <MMPopupView.h>

typedef void(^PickerSelectedDateBlock)(NSDate *selectedDate);

@interface TXDatePopView : MMPopupView

//设置时间
- (void)setPickerCurrentDate:(NSDate *)currentDate
                 minimumDate:(NSDate *)minimumDate
                 maximumDate:(NSDate *)maximumDate
                selectedDate:(NSDate *)selectedDate
               selectedBlock:(PickerSelectedDateBlock)selectedBlcok;

@end
