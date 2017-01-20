//
//  TXPageScrollView.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXPageScrollView.h"
#import "UILabel+ContentSize.h"

#define MAP(a, b, c) MIN(MAX(a, b), c)

static NSInteger const kCategoryButtonTag = 100;

@interface TXPageScrollView()

@property (nonatomic,strong) NSArray *categorys;
@property (nonatomic,strong) NSMutableArray *tabFrames;
@property (nonatomic,strong) UIColor *normalColor;
@property (nonatomic,strong) UIColor *selectedColor;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIButton *categoryButton;

@end

@implementation TXPageScrollView

- (instancetype)initWithFrame:(CGRect)frame categorys:(NSArray *)categorys normalTabColor:(UIColor *)nColor selectedTabColor:(UIColor *)sColor selectedPageIndex:(NSInteger)index
{
    self = [self initWithFrame:frame categorys:categorys normalTabColor:nColor selectedTabColor:sColor];
    if (self) {
        self.selectedIndex = index;
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame categorys:(NSArray *)categorys normalTabColor:(UIColor *)nColor selectedTabColor:(UIColor *)sColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.categorys = categorys;
        self.normalColor = nColor;
        self.selectedColor = sColor;
        //创建视图
        [self setupCategoryView];
    }
    return self;
}
- (void)setupCategoryView
{
    self.backgroundColor = RGBCOLOR(230, 231, 232);
    self.tabFrames = [NSMutableArray array];
    //添加滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    //添加选项卡
    CGFloat totalWidth = 0;
    for (int i = 0; i < [self.categorys count]; i++) {
        NSString *category = self.categorys[i];
        CGFloat tabWidth = [UILabel widthForLabelWithText:category maxHeight:self.scrollView.frame.size.height font:[UIFont systemFontOfSize:14]];
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.frame = CGRectMake(totalWidth, 0, tabWidth + 20, self.scrollView.frame.size.height);
        tabButton.backgroundColor = [UIColor clearColor];
        tabButton.tag = kCategoryButtonTag + i;
        [tabButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [tabButton setTitleColor:_normalColor forState:UIControlStateNormal];
        [tabButton setTitleColor:_selectedColor forState:UIControlStateSelected];
        [tabButton setTitle:category forState:UIControlStateNormal];
        [tabButton addTarget:self action:@selector(onCategoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:tabButton];
        //更新偏移量
        totalWidth += (tabWidth + 20);
        //添加frame到数组中
        [self.tabFrames addObject:NSStringFromCGRect(tabButton.frame)];
    }
    //设置contentSize
    [self.scrollView setContentSize:CGSizeMake(totalWidth, self.scrollView.frame.size.height)];
    //添加分割线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    lineView.backgroundColor = kColorLine;
    [self addSubview:lineView];
}
//点击了某个选项卡
- (void)onCategoryButtonTapped:(UIButton *)btn
{
    NSInteger index = btn.tag - kCategoryButtonTag;
    //视图更新
    if (self.categoryButton.isSelected) {
        [self.categoryButton setSelected:NO];
    }
    if (!btn.isSelected) {
        [btn setSelected:YES];
    }
    self.categoryButton = btn;
    //动画更新
    [self animateToPageAtIndex:index];
    //代理传递
    if (_pageScrollDelegate && [_pageScrollDelegate respondsToSelector:@selector(pageScrollView:didSelectTabAtIndex:)]) {
        [_pageScrollDelegate pageScrollView:self didSelectTabAtIndex:index];
    }
}
- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    //视图更新
    UIButton *btn = (UIButton *)[_scrollView viewWithTag:kCategoryButtonTag + _selectedIndex];
    if (self.categoryButton.isSelected) {
        [self.categoryButton setSelected:NO];
    }
    if (!btn.isSelected) {
        [btn setSelected:YES];
    }
    self.categoryButton = btn;
    //动画更新
    [self animateToPageAtIndex:_selectedIndex animated:NO];
}
//滚动到第index页
- (void)animateToPageAtIndex:(NSInteger)index
{
    [self animateToPageAtIndex:index animated:YES];
}
//滚动到第index页,包含animated选项
- (void)animateToPageAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CGFloat animatedDuration = 0.4f;
    if (!animated) {
        animatedDuration = 0.0f;
    }
    
    CGRect firstFrame = CGRectFromString(self.tabFrames[0]);
    CGFloat x = firstFrame.origin.x - 5;
    for (int i = 0; i < index; i++) {
        CGRect tabFrame = CGRectFromString(self.tabFrames[i]);
        x += tabFrame.size.width;
    }
    CGRect indexFrame = CGRectFromString(self.tabFrames[index]);
    CGFloat w = indexFrame.size.width;
    CGFloat p = x - (self.scrollView.frame.size.width - w) / 2;
    CGFloat min = 0;
    CGFloat max = MAX(0, self.scrollView.contentSize.width - self.frame.size.width);
    
    [self.scrollView setContentOffset:CGPointMake(MAP(p, min, max), 0) animated:animated];
    //选中按钮
    UIButton *btn = (UIButton *)[_scrollView viewWithTag:kCategoryButtonTag + index];
    if (self.categoryButton.isSelected) {
        [self.categoryButton setSelected:NO];
    }
    if (!btn.isSelected) {
        [btn setSelected:YES];
    }
    self.categoryButton = btn;

}
@end
