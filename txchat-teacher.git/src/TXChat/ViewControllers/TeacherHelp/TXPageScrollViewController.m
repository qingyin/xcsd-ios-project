//
//  TXPageScrollViewController.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXPageScrollViewController.h"
#import "TXPageScrollView.h"

@interface TXPageScrollViewController ()
<TXPageScrollViewDelegate,
UIPageViewControllerDataSource,
UIPageViewControllerDelegate>

@property (nonatomic,strong) TXPageScrollView *header;
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,strong) NSMutableArray *viewControllers;
@property (nonatomic,strong) NSMutableArray *tabTitles;
@property (nonatomic,strong) UIColor *normalTitleColor;
@property (nonatomic,strong) UIColor *selectedTitleColor;
@property (nonatomic,assign) CGFloat headerHeight;

@end

@implementation TXPageScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavBar];
    [self setupPageContentViewController];
}
#pragma mark - UI视图创建
- (void)setupPageContentViewController
{
    [self setPageViewController:[[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                              options:nil]];
    
    for (UIView *view in [[[self pageViewController] view] subviews]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)view setCanCancelContentTouches:YES];
            [(UIScrollView *)view setDelaysContentTouches:NO];
        }
    }
    [[self pageViewController] setDataSource:self];
    [[self pageViewController] setDelegate:self];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}
- (void)reloadData {
    [self setViewControllers:[NSMutableArray array]];
    [self setTabTitles:[NSMutableArray array]];
    
    for (int i = 0; i < [[self dataSource] numberOfViewControllers]; i++) {
        UIViewController *viewController;
        //子视图
        if ((viewController = [[self dataSource] viewControllerForIndex:i]) != nil) {
            [[self viewControllers] addObject:viewController];
        }
    }
    //顶部选项卡
    if ([[self dataSource] respondsToSelector:@selector(titleTabList)]) {
        [[self tabTitles] addObjectsFromArray:[[self dataSource] titleTabList]];
    }
    
    [self reloadTabs];
    
    CGRect frame = [[self view] frame];
    if (self.header) {
        frame.origin.y = self.header.maxY;
        frame.size.height -= self.header.maxY;
    }else{
        frame.origin.y = self.customNavigationView.maxY;
        frame.size.height -= self.customNavigationView.maxY;
    }
    
    [[[self pageViewController] view] setFrame:frame];
    
    if ([[self viewControllers] count] > 0) {
        [self.pageViewController setViewControllers:@[[self viewControllers][0]]
                                          direction:UIPageViewControllerNavigationDirectionReverse
                                           animated:NO
                                         completion:nil];
        [self setSelectedIndex:0];
    }
}

- (void)reloadTabs {
    //顶部选项卡的高度
    if ([[self dataSource] respondsToSelector:@selector(tabHeight)]) {
        [self setHeaderHeight:[[self dataSource] tabHeight]];
    } else {
        [self setHeaderHeight:36.f];
    }
    //判断是否需要return掉
    if ([[self dataSource] numberOfViewControllers] == 0)
        return;

    //普通状态下的按钮颜色
    if ([[self dataSource] respondsToSelector:@selector(normalTitleColor)]) {
        [self setNormalTitleColor:[[self dataSource] normalTitleColor]];
    }else{
        [self setNormalTitleColor:RGBCOLOR(0x44, 0x44, 0x44)];
    }
    //选中状态下的按钮颜色
    if ([[self dataSource] respondsToSelector:@selector(selectedTitleColor)]) {
        [self setSelectedTitleColor:[[self dataSource] selectedTitleColor]];
    }else{
        [self setSelectedTitleColor:RGBCOLOR(0xff, 0x93, 0x3d)];
    }
    //移除旧的header
    if ([self header]) {
        [[self header] removeFromSuperview];
    }
    CGRect frame = self.view.frame;
    frame.origin.y = self.customNavigationView.maxY;
    frame.size.height = [self headerHeight];
    [self setHeader:[[TXPageScrollView alloc] initWithFrame:frame categorys:[self tabTitles] normalTabColor:[self normalTitleColor] selectedTabColor:[self selectedTitleColor] selectedPageIndex:self.selectedIndex]];
    [[self header] setPageScrollDelegate:self];
    
    [[self view] addSubview:[self header]];
}

#pragma mark - Public Methods

- (void)selectTabbarIndex:(NSInteger)index {
    [self selectTabbarIndex:index animation:NO];
}

- (void)selectTabbarIndex:(NSInteger)index animation:(BOOL)animation {
    [self.pageViewController setViewControllers:@[[self viewControllers][index]]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:animation
                                     completion:nil];
    [[self header] animateToPageAtIndex:index animated:animation];
    [self setSelectedIndex:index];
}

#pragma mark - Page View Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    return pageIndex > 0 ? [self viewControllers][pageIndex - 1]: nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger pageIndex = [[self viewControllers] indexOfObject:viewController];
    return pageIndex < [[self viewControllers] count] - 1 ? [self viewControllers][pageIndex + 1]: nil;
}

#pragma mark - Page View Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    NSInteger index = [[self viewControllers] indexOfObject:pendingViewControllers[0]];
    [[self header] animateToPageAtIndex:index];
    
    if ([[self delegate] respondsToSelector:@selector(pageScrollViewController:willTransitionToTabAtIndex:)]) {
        [[self delegate] pageScrollViewController:self willTransitionToTabAtIndex:index];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    [self setSelectedIndex:[[self viewControllers] indexOfObject:[[self pageViewController] viewControllers][0]]];
    [[self header] animateToPageAtIndex:[self selectedIndex]];
    
    if ([[self delegate] respondsToSelector:@selector(pageScrollViewController:didTransitionToTabAtIndex:)]) {
        [[self delegate] pageScrollViewController:self didTransitionToTabAtIndex:[self selectedIndex]];
    }
}

#pragma mark - TXPageScrollViewDelegate methods
- (void)pageScrollView:(TXPageScrollView *)tabScrollView didSelectTabAtIndex:(NSInteger)index
{
    if (index != [self selectedIndex]) {
        if ([[self delegate] respondsToSelector:@selector(pageScrollViewController:willTransitionToTabAtIndex:)]) {
            [[self delegate] pageScrollViewController:self willTransitionToTabAtIndex:index];
        }
        
        [[self pageViewController]  setViewControllers:@[[self viewControllers][index]]
                                             direction:(index > [self selectedIndex]) ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse
                                              animated:YES
                                            completion:^(BOOL finished) {
                                                [self setSelectedIndex:index];
                                                
                                                if ([[self delegate] respondsToSelector:@selector(pageScrollViewController:didTransitionToTabAtIndex:)]) {
                                                    [[self delegate] pageScrollViewController:self didTransitionToTabAtIndex:[self selectedIndex]];
                                                }
                                            }];
    }

}
@end
