//
//  XLCycleScrollView.m
//  CycleScrollViewDemo
//
//  Created by xie liang on 9/14/12.
//  Copyright (c) 2012 xie liang. All rights reserved.
//

#import "XLCycleScrollView.h"

@implementation XLCycleScrollView

@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize currentPage = _curPage;
@synthesize datasource = _datasource;
@synthesize delegate = _delegate;

- (void)dealloc
{
}

- (id)initWithFrame:(CGRect)frame andTintColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        [_pageControl setPageIndicatorTintColor:[UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1]];
        [_pageControl setCurrentPageIndicatorTintColor:color];

        _pageControl.userInteractionEnabled = NO;
        
        [self addSubview:_pageControl];
        
        _curPage = 0;
        //默认是每次都移除旧数据再添加
        _autoRemoveMode = YES;
    }
    return self;
}

- (void)setDataource:(id<XLCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages];
    if (_totalPages == 0) {
        return;
    }
    if (!_autoRemoveMode) {
        _curPage = 1;
    }
    _pageControl.numberOfPages = _totalPages;
    [self loadData];
}

- (void)loadData
{
    if (_autoRemoveMode) {
        _pageControl.currentPage = _curPage;
        //从scrollView上移除所有的subview
        NSArray *subViews = [_scrollView subviews];
        if([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        
        [self getDisplayImagesWithCurpage:_curPage];
        
        for (int i = 0; i < 3; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }else{
        if (!_curViews) {
            //从scrollView上移除所有的subview
            NSArray *subViews = [_scrollView subviews];
            if([subViews count] != 0) {
                [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            }
            
            [_scrollView setContentSize:CGSizeMake((_totalPages + 1) * _scrollView.frame.size.width, _scrollView.frame.size.height)];
            
            _curViews = [[NSMutableArray alloc] init];
            for (int i = 0; i < _totalPages + 1; i++) {
//                [_curViews addObject:[_datasource pageAtIndex:i]];
                UIView *v;
                if (i == 0) {
                    v = [_datasource pageAtIndex:_totalPages - 1];
                }else{
                    v = [_datasource pageAtIndex:i - 1];
                }
                v.userInteractionEnabled = YES;
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                [v addGestureRecognizer:singleTap];
                v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
                [_scrollView addSubview:v];
            }
            [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
        }
    }
}

- (void)getDisplayImagesWithCurpage:(NSInteger)page {
    
    NSInteger pre = [self validPageValue:_curPage-1];
    NSInteger last = [self validPageValue:_curPage+1];
    
    if (!_curViews) {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];
    
    [_curViews addObject:[_datasource pageAtIndex:pre]];
    [_curViews addObject:[_datasource pageAtIndex:page]];
    [_curViews addObject:[_datasource pageAtIndex:last]];
}

- (NSInteger)validPageValue:(NSInteger)value {
    
    if(value == -1) value = _totalPages - 1;
    if(value == _totalPages) value = 0;
    
    return value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)]) {
        [_delegate didClickPage:self atIndex:_curPage];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage) {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 3; i++) {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handleTap:)];
            [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
            [_scrollView addSubview:v];
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if (_autoRemoveMode) {
        int x = aScrollView.contentOffset.x;
        
        //往下翻一张
        if(x >= (2*self.frame.size.width)) {
            _curPage = [self validPageValue:_curPage+1];
            [self loadData];
        }
        
        //往上翻
        if(x <= 0) {
            _curPage = [self validPageValue:_curPage-1];
            [self loadData];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    if (!_autoRemoveMode) {
        NSInteger currentPage = _scrollView.contentOffset.x / _scrollView.frame.size.width;
        if (currentPage == 0) {
            _scrollView.contentOffset = CGPointMake(_totalPages * _scrollView.frame.size.width, 0);
            _pageControl.currentPage = _totalPages;
        }
        if (_curPage + 1 == currentPage || currentPage == 1) {
            _curPage = currentPage;
            if (_curPage == _totalPages + 1) {
                _curPage = 1;
            }
            if (_curPage == _totalPages) {
                _scrollView.contentOffset = CGPointMake(0, 0);
            }
            _pageControl.currentPage = _curPage - 1;
        }
    }else{
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    }
    
}

@end
