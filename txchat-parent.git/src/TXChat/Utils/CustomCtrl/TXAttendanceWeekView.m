//
//  TXAttendanceWeekView.m
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXAttendanceWeekView.h"
#import "TXAttendanceDayView.h"

@interface TXAttendanceWeekView()
{
    NSMutableArray *_daysArray;
    TXCalendarWeekModel *_weekInfo;
}
@end


@implementation TXAttendanceWeekView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _daysArray = [NSMutableArray arrayWithCapacity:1];
        [self initViews];
    }
    return self;
}


-(void)initViews
{
    for(NSInteger i = 0; i < 7; i++)
    {
        TXAttendanceDayView *dayView = [[TXAttendanceDayView alloc] init];
        dayView.weekDay = 1 + i;
        [self addSubview:dayView];
        [_daysArray addObject:dayView];
    }
    [self layoutDaysViews:_daysArray];
}


-(void)layoutDaysViews:(NSMutableArray *)titlesViews
{
    
    if(titlesViews == nil || [titlesViews count] == 0)
    {
        return;
    }
    
    CGFloat viewWidth = 30;
    CGFloat viewHight = 55;
    CGFloat margin = 10;
    CGFloat middleMargin = (kScreenWidth- 2*margin -titlesViews.count * viewWidth)/(titlesViews.count-1);
    
    for(NSInteger i = 0; i < titlesViews.count; i++)
    {
        UIView *dayView = titlesViews[i];
        dayView.frame = CGRectMake(margin+i*(middleMargin+viewWidth), 0, viewWidth, viewHight);
    }
}
//界面是否可见
-(BOOL)isWeekVisible
{
    BOOL isAllDayViewsVisible = NO;
    for(UIView *dayView in _daysArray)
    {
        if(!dayView.isHidden)
        {
            isAllDayViewsVisible = YES;
            break;
        }
    }
    return isAllDayViewsVisible;
}

-(void)setWeekViewIndex:(NSInteger)weekViewIndex
{
    _weekViewIndex = weekViewIndex;
    if(weekViewIndex >= 5)
    {
        for(UIView *dayView in _daysArray)
        {
            [dayView setHidden:YES];
        }
    }

}


-(void)refreshByWeekInfo:(TXCalendarWeekModel *)weekInfo
{
    if(weekInfo == nil || weekInfo.getDaysInfo.count == 0 )
    {
        return;
    }
    _weekInfo = weekInfo;
    NSArray *dayInfos = weekInfo.getDaysInfo;
    NSInteger modelIndex = 0;
    for(NSInteger index = 0; index < _daysArray.count; index++)
    {
        TXAttendanceDayView *dayView = _daysArray[index];
        if(modelIndex >= dayInfos.count)
        {
            dayView.hidden = YES;
        }
        else
        {
            TXCalendarDayModel *dayInfo = dayInfos[modelIndex];
            if(dayView.weekDay == dayInfo.weekDay)
            {
                dayView.currentDay = dayInfo.day;
                dayView.isToday = dayInfo.isToday;
                dayView.attendanceDayType = dayInfo.attendanceDayType;
                dayView.hidden = NO;
                [dayView setNeedsLayout];
                modelIndex ++;
            }
            else
            {
                dayView.hidden = YES;
            }
        }

    }
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
