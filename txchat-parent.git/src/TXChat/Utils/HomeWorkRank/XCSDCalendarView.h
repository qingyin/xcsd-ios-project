//
//  XCSDCalendarView.h
//  TXChatParent
//
//  Created by gaoju on 16/3/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCSDCalendarView : UIView
/**
 *  根据信息刷新界面
 *
 *  @param weekInfos 出席信息
 */
-(void)refreshViews:(NSArray *)weekInfos;

-(void)hiddenWeeks;

-(CGFloat)getTotalHight;
@end
