//
//  TXAttendanceWeekView.h
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXCalendarWeekModel.h"

@interface TXAttendanceWeekView : UIView
@property(nonatomic, assign)NSInteger weekViewIndex;//第几周

//界面是否可见
-(BOOL)isWeekVisible;

-(void)refreshByWeekInfo:(TXCalendarWeekModel *)weekInfo;

@end
