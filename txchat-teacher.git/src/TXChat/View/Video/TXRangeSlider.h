//
//  TXRangeSlider.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/6/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXRangeSlider : UIControl

@property(assign, nonatomic, readonly) CGFloat value;
//默认为0.0
@property(assign, nonatomic) CGFloat minimumValue;

//默认为1.0
@property(assign, nonatomic) CGFloat maximumValue;

//默认为0.0，左侧和右侧的最小距离
@property(assign, nonatomic) CGFloat minimumRange;

//默认为0.0，左侧的值
@property(assign, nonatomic) CGFloat lowerValue;

//默认为1.0，右侧的值
@property(assign, nonatomic) CGFloat upperValue;

//左侧control按钮的center
@property(readonly, nonatomic) CGPoint lowerCenter;

//右侧control按钮的center
@property(readonly, nonatomic) CGPoint upperCenter;

//左侧thumb最大值
@property(assign, nonatomic) CGFloat lowerMaximumValue;

//右侧thumb最小值
@property(assign, nonatomic) CGFloat upperMinimumValue;

@property (assign, nonatomic) UIEdgeInsets lowerTouchEdgeInsets;
@property (assign, nonatomic) UIEdgeInsets upperTouchEdgeInsets;

@property (strong, nonatomic) UIImage* lowerHandleImage;

@property (strong, nonatomic) UIImage* upperHandleImage;

//设置完属性后调用该方法初始化界面
- (void)setup;

@end
