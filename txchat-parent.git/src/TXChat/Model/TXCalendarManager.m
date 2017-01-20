//
//  TXCalendarManager.m
//  TXChatParent
//
//  Created by lyt on 15/12/16.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXCalendarManager.h"

@interface TXCalendarManager()
{
    TXCalendarView *_calendarView;
}
@end

@implementation TXCalendarManager

//单例
+ (instancetype)shareInstance
{
    static TXCalendarManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init
{
    self = [super init];
    {
        _calendarView = [[TXCalendarView alloc] init];
    }
    return self;
}

-(TXCalendarView *)getCalendarView
{
    return _calendarView;
}
@end
