//
//  TXPageScrollViewController.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@protocol TXPagerScrollViewControllerDataSource;
@protocol TXPagerScrollViewControllerDelegate;

@interface TXPageScrollViewController : BaseViewController

@property (nonatomic, weak) id<TXPagerScrollViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<TXPagerScrollViewControllerDelegate> delegate;

- (void)reloadData;
- (NSInteger)selectedIndex;

- (void)selectTabbarIndex:(NSInteger)index;
- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation;

@end

@protocol TXPagerScrollViewControllerDataSource <NSObject>

@required
//一共有几个子选项视图
- (NSInteger)numberOfViewControllers;
//子选项视图
- (UIViewController *)viewControllerForIndex:(NSInteger)index;
//顶部选项卡列表
- (NSArray *)titleTabList;

@optional
- (CGFloat)tabHeight;
- (UIColor *)normalTitleColor;
- (UIColor *)selectedTitleColor;

@end

@protocol TXPagerScrollViewControllerDelegate <NSObject>

@optional
- (void)pageScrollViewController:(TXPageScrollViewController *)tabPager willTransitionToTabAtIndex:(NSInteger)index;
- (void)pageScrollViewController:(TXPageScrollViewController *)tabPager didTransitionToTabAtIndex:(NSInteger)index;

@end