//
//  XCSDCalendarWeekModel.h
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCSDCalendarDayModel.h"

@interface XCSDCalendarWeekModel : NSObject
/**
 *  初始化 周信息
 *
 *  @param weekIndex 第几周
 *
 *  @return 自己
 */
-(id)initWithWeekIndex:(NSInteger)weekIndex;

/**
 *  添加周内日期
 *
 *  @param dayInfo 日期信息
 */
-(void)addDays:(XCSDCalendarDayModel *)dayInfo;
/**
 *  获得周顺序
 *
 *  @return 第几周
 */
-(NSInteger)getWeekIndex;

-(NSArray *)getDaysInfo;

@end
