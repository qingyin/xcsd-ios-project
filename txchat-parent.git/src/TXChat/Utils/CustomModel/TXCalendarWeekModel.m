//
//  TXCalendarWeekModel.m
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXCalendarWeekModel.h"

@interface TXCalendarWeekModel()
{
    NSMutableArray *_daysByWeek;
    NSInteger _weekIndex;
}

@end

@implementation TXCalendarWeekModel

-(id)initWithWeekIndex:(NSInteger)weekIndex
{
    self = [super init];
    if(self)
    {
        _daysByWeek = [NSMutableArray arrayWithCapacity:1];
        _weekIndex = weekIndex;
    }
    
    return self;
}
//添加日期
-(void)addDays:(TXCalendarDayModel *)dayInfo
{
    @synchronized(_daysByWeek)
    {
        [_daysByWeek addObject:dayInfo];
    }
    NSArray *sortedArray = [_daysByWeek sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TXCalendarDayModel *first = (TXCalendarDayModel *)obj1;
        TXCalendarDayModel *last = (TXCalendarDayModel *)obj2;
        NSComparisonResult result;
//        if(first.weekDay == 7)
//        {
//            result = NSOrderedDescending;
//        }
//        else if(last.weekDay == 7)
//        {
//            result = NSOrderedAscending;
//        }
//        else
        {
            result = first.weekDay > last.weekDay?NSOrderedDescending:NSOrderedAscending;
        }
        return result;
    }];
    @synchronized(_daysByWeek)
    {
        _daysByWeek = [NSMutableArray arrayWithArray:sortedArray];
    }
}

-(NSInteger)getWeekIndex
{
    return _weekIndex;
}

-(NSArray *)getDaysInfo
{
    return [NSArray arrayWithArray:_daysByWeek];
}

@end
