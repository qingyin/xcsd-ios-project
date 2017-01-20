//
//  UISelectorView.m
//  GasHome
//
//  Created by Alan on 13-6-25.
//  Copyright (c) 2013年 AutoHome. All rights reserved.
//

#import "UISelectorView.h"

#define kTableViewTag 71992493
#define kSelectorViewTag 81064606
#define componentIndex(i) (i - kTableViewTag)

@implementation UISelectorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _rowHeight = 30;
        _marginWidth = 3;
        self.colorStateNormal = kColorGray3;
        self.colorStateSelected = kColorWhite;
        self.colorSelector = kColorBlack;
    }
    return self;
}

- (void)buildView
{
    isBuildFinish = NO;
    
    [self removeAllSubviews];
    
    if (!_selectedIndexPaths)
        _selectedIndexPaths = [[NSMutableArray alloc] init];
    else
        [_selectedIndexPaths removeAllObjects];
    
    NSUInteger count = self.dataSource.count;
    CGFloat width = (self.width_ - self.marginWidth * (count + 1)) / count;
    for (int i = 0; i < count; i++) {
        [_selectedIndexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        CGFloat emptyHeight = (self.height_ - _rowHeight) / 2;
        
        UITableView *tvData = [[UITableView alloc] initWithFrame:CGRectMake(width * i + self.marginWidth * (i + 1), 0, width, self.height_)];
        tvData.separatorStyle = UITableViewCellSeparatorStyleNone;
        tvData.backgroundColor = [UIColor clearColor];
        tvData.tag = kTableViewTag + i;
        tvData.dataSource = self;
        tvData.delegate = self;
        tvData.showsVerticalScrollIndicator = NO;
        tvData.showsHorizontalScrollIndicator = NO;
        tvData.contentInset = UIEdgeInsetsMake(emptyHeight, 0, emptyHeight, 0);
        
        UIView *vSelector = [[UIView alloc] initWithFrame:CGRectMake(tvData.minX, emptyHeight, tvData.width_, _rowHeight)];
        vSelector.userInteractionEnabled = NO;
        vSelector.backgroundColor = self.colorSelector;
        vSelector.tag = kSelectorViewTag + tvData.tag;
        
        [self addSubview:vSelector];
        [self addSubview:tvData];
    }
    isBuildFinish = YES;
}

/* 设置数据 */
- (void)setDataSource:(NSMutableArray *)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        [self buildView];
    }
}

/* 选择某行 */
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    UITableView *tableView = (UITableView *)[self viewWithTag:kTableViewTag + component];
    if (tableView) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    } else {
        [self.selectedIndexPaths replaceObjectAtIndex:component withObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectorView:didSelectRow:inComponent:)])
        [self.delegate selectorView:self didSelectRow:row inComponent:component];
}

/* 重新加载数据 */
- (void)reloadAllComponents
{
    [self buildView];
}

/* 重新加载某列数据 */
- (void)reloadComponent:(NSInteger)component
{
    UITableView *tableView = (UITableView *)[self viewWithTag:kTableViewTag + component];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource methods
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSArray *)[self.dataSource objectAtIndex:tableView.tag - kTableViewTag] count];
}

//绘制Cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    NSString *strData = [[self.dataSource objectAtIndex:tableView.tag - kTableViewTag] objectAtIndex:indexPath.row];
    NSIndexPath *selectedIndexPath = [self.selectedIndexPaths objectAtIndex:tableView.tag - kTableViewTag];
    cell.textLabel.text = strData;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (indexPath.row == selectedIndexPath.row) {
        cell.textLabel.textColor = self.colorStateSelected;
    } else
        cell.textLabel.textColor = self.colorStateNormal;
    return cell;
}

//区域
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.selectedIndexPaths replaceObjectAtIndex:tableView.tag - kTableViewTag withObject:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(selectorView:didSelectRow:inComponent:)])
        [self.delegate selectorView:self didSelectRow:indexPath.row inComponent:tableView.tag - kTableViewTag];
}


//开始滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 只允许滚动一列
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        UITableView *tableView = (UITableView *)[self viewWithTag:kTableViewTag + i];
        tableView.scrollEnabled = tableView.tag == scrollView.tag;
    }
}

//滑动中
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *selectedIndexPath = [self indexPathForRectInScrollView:scrollView];
    if (selectedIndexPath) {
        UITableView *tableView = (UITableView *)scrollView;
        NSIndexPath *lastSelectedIndexPath = [self.selectedIndexPaths objectAtIndex:tableView.tag - kTableViewTag];
        if (lastSelectedIndexPath) {
            UITableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath:lastSelectedIndexPath];
            lastSelectedCell.textLabel.textColor = self.colorStateNormal;
        }
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:selectedIndexPath];
        selectedCell.textLabel.textColor = self.colorStateSelected;
        
        [self.selectedIndexPaths replaceObjectAtIndex:tableView.tag - kTableViewTag withObject:selectedIndexPath];
    }
}

//滑动减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToTheSelectedCell:scrollView];
}

//结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self scrollToTheSelectedCell:scrollView];
    }
}

/* 校正聚焦的位置 */
- (void)scrollToTheSelectedCell:(UIScrollView *)scrollView {
    NSIndexPath *selectedIndexPath = [self indexPathForRectInScrollView:scrollView];
    if (selectedIndexPath != nil) {
        UITableView *tableView = (UITableView *)scrollView;
        [tableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        if ([self.delegate respondsToSelector:@selector(selectorView:didSelectRow:inComponent:)])
            [self.delegate selectorView:self didSelectRow:selectedIndexPath.row inComponent:tableView.tag - kTableViewTag];
    }
    
    // 选中后恢复其他列表滚动
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        UITableView *tableView = (UITableView *)[self viewWithTag:kTableViewTag + i];
        tableView.scrollEnabled = YES;
    }
}

/* 获取当前聚焦的NSIndexPath */
- (NSIndexPath *)indexPathForRectInScrollView:(UIScrollView *)scrollView
{
    UITableView *tableView = (UITableView *)scrollView;
    CGRect selectionRect = [self viewWithTag:kSelectorViewTag + tableView.tag].frame;
    
    CGRect selectionRectConverted = [self convertRect:selectionRect toView:scrollView];
    NSArray *indexPathArray = [tableView indexPathsForRowsInRect:selectionRectConverted];
    
    CGFloat intersectionHeight = 0.0;
    NSIndexPath *selectedIndexPath = nil;
    
    for (NSIndexPath *index in indexPathArray) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:index];
        CGRect intersectedRect = CGRectIntersection(cell.frame, selectionRectConverted);
        
        if (intersectedRect.size.height >= intersectionHeight) {
            selectedIndexPath = index;
            intersectionHeight = intersectedRect.size.height;
        }
    }
    return selectedIndexPath;
}

- (void)dealloc
{
    self.colorStateNormal = nil;
    self.colorStateSelected = nil;
    self.colorSelector = nil;
    self.dataSource = nil;
    _selectedIndexPaths = nil;
}

@end
