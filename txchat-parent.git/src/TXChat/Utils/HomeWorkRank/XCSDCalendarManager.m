//
//  XCSDCalendarManager.m
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "XCSDCalendarManager.h"
@interface XCSDCalendarManager()
{
    XCSDCalendarView *_calendarView;
}
@end
@implementation XCSDCalendarManager
//单例
+ (instancetype)shareInstance
{
    static XCSDCalendarManager *_instance = nil;
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
        _calendarView = [[XCSDCalendarView alloc] init];
    }
    return self;
}

-(XCSDCalendarView *)getCalendarView
{
    return _calendarView;
}

@end
