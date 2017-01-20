//
//  XCSDAttendanceWeekView.h
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCSDCalendarWeekModel.h"
@interface XCSDAttendanceWeekView : UIView
@property(nonatomic, assign)NSInteger weekViewIndex;//第几周

//界面是否可见
-(BOOL)isWeekVisible;

-(void)refreshByWeekInfo:(XCSDCalendarWeekModel *)weekInfo;
@end
