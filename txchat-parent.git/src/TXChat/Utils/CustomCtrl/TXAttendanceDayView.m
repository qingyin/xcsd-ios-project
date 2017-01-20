//
//  TXAttendanceDayView.m
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXAttendanceDayView.h"
//出息
#define KAttendanceBgColor RGBCOLOR(0x82, 0xd7, 0xff)
#define KAttendanceTextColor kColorWhite
//请假
#define KLeaveBgColor RGBCOLOR(0xff, 0xc8, 0x69)
#define KLeaveTextColor kColorWhite
//请假
#define KAbsentBgColor RGBCOLOR(0xff, 0x80, 0x80)
#define KAbsentTextColor kColorWhite

//节假日
#define KHolidayBgColor kColorClear
#define KHolidayTextColor RGBCOLOR(0xa4, 0xa4, 0xa4)

//未到日期
#define KNormalBgColor kColorClear
#define KNormalTextColor RGBCOLOR(0x44, 0x44, 0x44)

@interface TXAttendanceDayView()
{
//    UILabel *_dayLabel;
//    UILabel *_todayLabel;
}

@property(nonatomic, strong)UILabel *dayLabel;
@property(nonatomic, strong)UILabel *todayLabel;

@end



@implementation TXAttendanceDayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isToday = NO;
        [self initViews];
    }
    return self;
}

-(void)initViews
{



}

-(UILabel *)dayLabel
{
    if(!_dayLabel)
    {
        _dayLabel = [[UILabel alloc] init];
        _dayLabel.font = [UIFont boldSystemFontOfSize:14];
        _dayLabel.layer.masksToBounds = YES;
        _dayLabel.layer.cornerRadius = 30.0f/2.0f;
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dayLabel];
        [_dayLabel setHidden:YES];
    }
    return _dayLabel;
}


-(UILabel *)todayLabel
{
    if(!_todayLabel)
    {
        _todayLabel = [[UILabel alloc] init];
        _todayLabel.text = @"今天";
        _todayLabel.font = kFontTimeTitle;
        _todayLabel.textColor = KColorSubTitleTxt;
        _todayLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_todayLabel];
        [_todayLabel setHidden:YES];
    }
    return _todayLabel;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.dayLabel.frame = CGRectMake((self.width_-30)/2, 5, 30, 30);
    self.todayLabel.frame = CGRectMake((self.width_-30)/2, 35, 30, 20);

}
-(void)setAttendanceDayType:(TXATTENDANCEDAYTYPE)attendanceDayType
{
    switch (attendanceDayType) {
        case TXATTENDANCEDAYTYPE_ATTENDANCE: {
            {
                self.dayLabel.backgroundColor = KAttendanceBgColor;
                self.dayLabel.textColor = KAttendanceTextColor;
            }
            break;
        }
        case TXATTENDANCEDAYTYPE_NORMAL: {
            {
                self.dayLabel.backgroundColor = KNormalBgColor;
                self.dayLabel.textColor = KNormalTextColor;
            }
            break;
        }
        case TXATTENDANCEDAYTYPE_ABSENT: {
            {
                self.dayLabel.backgroundColor = KAbsentBgColor;
                self.dayLabel.textColor = KAbsentTextColor;
            }
            break;
        }
        case TXATTENDANCEDAYTYPE_LEAVE: {
            {
                self.dayLabel.backgroundColor = KLeaveBgColor;
                self.dayLabel.textColor = KLeaveTextColor;
            }
            break;
        }
        case TXATTENDANCEDAYTYPE_HOLIDAY: {
            {
                self.dayLabel.backgroundColor = KHolidayBgColor;
                self.dayLabel.textColor = KHolidayTextColor;
            }
            break;
        }
        default: {
            break;
        }
    }
}
-(void)setCurrentDay:(NSInteger)currentDay
{
    _currentDay = currentDay;
    self.dayLabel.text = [NSString stringWithFormat:@"%@", @(_currentDay)];
    [self.dayLabel setHidden:NO];
//    [_dayLabel layoutSubviews];
}

-(void)setIsToday:(BOOL)isToday
{
    _isToday = isToday;
    [self.todayLabel setHidden:!_isToday];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
