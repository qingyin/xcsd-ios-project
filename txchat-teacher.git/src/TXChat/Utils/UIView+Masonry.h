//
//  UIView+Masonry.h
//  TXChatTeacher
//
//  Created by lyt on 15/9/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Masonry)
/**
 *  将若干view等宽布局于容器containerView中
 *
 *  @param views         viewArray
 *  @param containerView 容器view
 *  @param LRpadding     距容器的左右边距
 *  @param viewPadding   各view的左右边距
 */
-(void)makeEqualWidthViews:(NSArray *)views inView:(UIView *)containerView LRpadding:(CGFloat)LRpadding viewPadding :(CGFloat)viewPadding;
@end
