//
//  TXPageScrollView.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TXPageScrollViewDelegate;

@interface TXPageScrollView : UIView

@property (nonatomic, weak) id<TXPageScrollViewDelegate> pageScrollDelegate;
@property (nonatomic, strong) UIColor *lineColor;

/**
 *  初始化
 *
 *  @param frame     视图Frame
 *  @param categorys 选项卡列表,是字符串类型
 *  @param nColor    普通状态下的分类按钮颜色
 *  @param sColor    选中状态下的分类按钮颜色
 *
 *  @return 滚动视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame categorys:(NSArray *)categorys normalTabColor:(UIColor *)nColor selectedTabColor:(UIColor *)sColor;

/**
 *  初始化
 *
 *  @param frame     视图Frame
 *  @param categorys 选项卡列表,字符串类型
 *  @param nColor    普通状态下的分类按钮颜色
 *  @param sColor    选中状态下的分类按钮颜色
 *  @param index     当前选中的是第几个选项卡
 *
 *  @return 滚动视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame categorys:(NSArray *)categorys normalTabColor:(UIColor *)nColor selectedTabColor:(UIColor *)sColor selectedPageIndex:(NSInteger)index;

//滚动到第index页
- (void)animateToPageAtIndex:(NSInteger)index;
//滚动到第index页,包含animated选项
- (void)animateToPageAtIndex:(NSInteger)index animated:(BOOL)animated;

@end

@protocol TXPageScrollViewDelegate <NSObject>

- (void)pageScrollView:(TXPageScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index;

@end