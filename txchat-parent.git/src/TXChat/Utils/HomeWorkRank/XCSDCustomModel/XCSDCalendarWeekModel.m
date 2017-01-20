//
//  XCSDCalendarWeekModel.m
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "XCSDCalendarWeekModel.h"

@interface XCSDCalendarWeekModel()
{
    NSMutableArray *_daysByWeek;
    NSInteger _weekIndex;
}

@end
@implementation XCSDCalendarWeekModel
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
-(void)addDays:(XCSDCalendarDayModel *)dayInfo
{
    @synchronized(_daysByWeek)
    {
        [_daysByWeek addObject:dayInfo];
    }
    NSArray *sortedArray = [_daysByWeek sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        XCSDCalendarDayModel *first = (XCSDCalendarDayModel *)obj1;
        XCSDCalendarDayModel *last = (XCSDCalendarDayModel *)obj2;
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
