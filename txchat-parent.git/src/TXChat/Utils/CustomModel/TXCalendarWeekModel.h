//
//  TXCalendarWeekModel.h
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXCalendarDayModel.h"

@interface TXCalendarWeekModel : NSObject

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
-(void)addDays:(TXCalendarDayModel *)dayInfo;
/**
 *  获得周顺序
 *
 *  @return 第几周
 */
-(NSInteger)getWeekIndex;

-(NSArray *)getDaysInfo;

@end
