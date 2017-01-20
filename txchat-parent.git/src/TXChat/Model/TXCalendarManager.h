//
//  TXCalendarManager.h
//  TXChatParent
//
//  Created by lyt on 15/12/16.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXCalendarView.h"
@interface TXCalendarManager : NSObject
//单例
+ (instancetype)shareInstance;

-(TXCalendarView *)getCalendarView;

@end
