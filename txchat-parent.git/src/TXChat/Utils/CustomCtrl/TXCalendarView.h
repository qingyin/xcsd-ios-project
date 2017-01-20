//
//  TXCalendarView.h
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXCalendarView : UIView
/**
 *  根据信息刷新界面
 *
 *  @param weekInfos 出席信息
 */
-(void)refreshViews:(NSArray *)weekInfos;

-(void)hiddenWeeks;

-(CGFloat)getTotalHight;
@end
