//
//  XCSDCalendarManager.h
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCSDCalendarView.h"
@interface XCSDCalendarManager : NSObject
//单例
+ (instancetype)shareInstance;

-(XCSDCalendarView *)getCalendarView;
@end
