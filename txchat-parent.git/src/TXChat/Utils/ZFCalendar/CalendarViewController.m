//
//  CalendarViewController.m
//  Calendar
//
//  Created by 张凡 on 14-8-21.
//  Copyright (c) 2014年 张凡. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "CalendarViewController.h"
//UI
#import "CalendarMonthCollectionViewLayout.h"
#import "CalendarMonthHeaderView.h"
#import "CalendarDayCell.h"
//MODEL
#import "CalendarDayModel.h"


@interface CalendarViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate>
{

     NSTimer* timer;//定时器

}


@end

@implementation CalendarViewController

static NSString *MonthHeader = @"MonthHeaderView";

static NSString *DayCell = @"DayCell";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initData];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.selectedArr = [NSMutableArray array];
    [self createCustomNavBar];
    [self initView];

	// Do any additional setup after loading the view.
}

- (void)createCustomNavBar{
    [super createCustomNavBar];
    [self.btnRight setTitle:@"确定" forState:UIControlStateNormal];
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (self.calendarblock) {
            _calendarblock(_selectedArr);
        }

        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)initView{
    
    
    [self setTitle:@"选择日期"];
    
    CalendarMonthCollectionViewLayout *layout = [CalendarMonthCollectionViewLayout new];
    
    int width = kScreenWidth/7;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake((kScreenWidth - width * 7)/2, self.customNavigationView.maxY, width * 7, self.view.height_ - self.customNavigationView.maxY) collectionViewLayout:layout]; //初始化网格视图大小
    
    [self.collectionView registerClass:[CalendarDayCell class] forCellWithReuseIdentifier:DayCell];//cell重用设置ID
    
    [self.collectionView registerClass:[CalendarMonthHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MonthHeader];
    
//    self.collectionView.bounces = NO;//将网格视图的下拉效果关闭
    
    self.collectionView.delegate = self;//实现网格视图的delegate
    
    self.collectionView.dataSource = self;//实现网格视图的dataSource
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    
}



-(void)initData{
    
    self.calendarMonth = [[NSMutableArray alloc]init];//每个月份的数组
    
}



#pragma mark - CollectionView代理方法

//定义展示的Section的个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.calendarMonth.count;
}


//定义展示的UICollectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *monthArray = [self.calendarMonth objectAtIndex:section];
    
    return monthArray.count;
}

- (void)reloadData{
    [self.collectionView reloadData];
}


//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalendarDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DayCell forIndexPath:indexPath];
    
    NSMutableArray *monthArray = [self.calendarMonth objectAtIndex:indexPath.section];
    
    CalendarDayModel *model = [monthArray objectAtIndex:indexPath.row];
    cell.calendarVC = self;
    cell.model = model;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;

    if (kind == UICollectionElementKindSectionHeader){
        
        NSMutableArray *month_Array = [self.calendarMonth objectAtIndex:indexPath.section];
        CalendarDayModel *model = [month_Array objectAtIndex:15];

        CalendarMonthHeaderView *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MonthHeader forIndexPath:indexPath];
        monthHeader.masterLabel.text = [NSString stringWithFormat:@"%lu年 %lu月",(unsigned long)model.year,(unsigned long)model.month];//@"日期";
        monthHeader.backgroundColor = RGBCOLOR(238, 238, 238);
        reusableview = monthHeader;
    }
    return reusableview;
    
}


//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *month_Array = [self.calendarMonth objectAtIndex:indexPath.section];
    CalendarDayModel *model = [month_Array objectAtIndex:indexPath.row];

    if (model.style == CellDayTypeFutur ||model.style == CellDayTypeClick) {
       
        [self.Logic selectLogic:model];
        
        if (self.calendarblock) {
            
//            self.calendarblock(model);//传递数组给上级
            
//            timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
        }
        if (_selectedArr.count > 1) {
            [_selectedArr removeAllObjects];
        }
        [_selectedArr addObject:model];
        _selectedArr = [NSMutableArray arrayWithArray:[_selectedArr sortedArrayUsingComparator:cmptr2]];
        [self reloadData];

        
//        if (![_selectedArr containsObject:model]) {
//            if (_selectedArr.count > 2) {
//                CalendarDayModel *firstModel = _selectedArr.firstObject;
//                CalendarDayModel *lastModel = _selectedArr.lastObject;
//                NSDate *earlier_date = [model.date earlierDate:firstModel.date];
//                NSDate *earlier_date1 = [model.date earlierDate:lastModel.date];
//                if ([earlier_date isEqualToDate:model.date]) {
//                    [_selectedArr removeAllObjects];
//                    [_selectedArr addObject:lastModel];
//                }else if ([earlier_date1 isEqualToDate:lastModel.date]){
//                    [_selectedArr removeAllObjects];
//                    [_selectedArr addObject:firstModel];
//                }
//            }
//            [_selectedArr addObject:model];
//            _selectedArr = [NSMutableArray arrayWithArray:[_selectedArr sortedArrayUsingComparator:cmptr2]];
//            [self reloadData];
//        }else{
//            NSInteger index = [_selectedArr indexOfObject:model];
//            if (index * 2 > _selectedArr.count - 1 && index != _selectedArr.count - 1) {
//                [_selectedArr removeObjectsInRange:NSMakeRange(index + 1, _selectedArr.count - index - 1)];
//            }else{
//                [_selectedArr removeObjectsInRange:NSMakeRange(0, index)];
//            }
//            [self reloadData];
//        }
    }
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}


//定时器方法
- (void)onTimer{
    
    [timer invalidate];//定时器无效
    
    timer = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark -
//#pragma mark Touches
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    _collectionView.scrollEnabled = NO;
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.view];
//    UIView *hitView = [self.view hitTest:location withEvent:event];
//    
//    if (!hitView)
//        return;
//    
//    if ([hitView.superview isKindOfClass:[CalendarDayCell class]]) {
//        CalendarDayCell *tile = (CalendarDayCell*)hitView.superview;
//        if (tile.model.style == CellDayTypeEmpty ||
//            tile.model.style == CellDayTypePast)
//            return;
//        
//        if (![_selectedArr containsObject:tile.model]) {
//            [_selectedArr addObject:tile.model];
//            _selectedArr = [NSMutableArray arrayWithArray:[_selectedArr sortedArrayUsingComparator:cmptr]];
//            tile.model.isSelected = YES;
//            [self reloadData];
//        }
//        
//        
//        //        NSDate *date = tile.date;
//        //        if ([date isEqualToDate:self.beginDate]) {
//        //            if (self.selectionMode == KalSelectionModeSingle) return;
//        //
//        //            date = self.beginDate;
//        //            _beginDate = _endDate;
//        //            _endDate = date;
//        //        } else if ([date isEqualToDate:self.endDate]) {
//        //
//        //        } else {
//        //            self.beginDate = date;
//        //        }
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.view];
//    UIView *hitView = [self.view hitTest:location withEvent:event];
//    
//    if (!hitView)
//        return;
//    if ([hitView.superview isKindOfClass:[CalendarDayCell class]]) {
//        CalendarDayCell *tile = (CalendarDayCell*)hitView.superview;
//        NSLog(@"%@",tile);
//        if (tile.model.style == CellDayTypeEmpty ||
//            tile.model.style == CellDayTypePast)
//            return;
//        if (![_selectedArr containsObject:tile.model]) {
//            [_selectedArr addObject:tile.model];
//            _selectedArr = [NSMutableArray arrayWithArray:[_selectedArr sortedArrayUsingComparator:cmptr]];
//            tile.model.isSelected = YES;
//            [self reloadData];
//        }
//        
//        //        NSDate *endDate = tile.date;
//        //        if (!endDate || [endDate isEqualToDate:self.beginDate] || [endDate isEqualToDate:self.endDate])
//        //            return;
//        //        if (tile.isFirst || tile.isLast) {
//        //            if ([tile.date compare:logic.baseDate] == NSOrderedDescending) {
//        //                [delegate showFollowingMonth];
//        //            } else {
//        //                [delegate showPreviousMonth];
//        //            }
//        //        }
//        //        self.endDate = endDate;
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    _collectionView.scrollEnabled = YES;
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self.view];
//    UIView *hitView = [self.view hitTest:location withEvent:event];
//    
//    if ([hitView.superview isKindOfClass:[CalendarDayCell class]]) {
//        CalendarDayCell *tile = (CalendarDayCell*)hitView.superview;
//        if (tile.model.style == CellDayTypeEmpty ||
//            tile.model.style == CellDayTypePast)
//            return;
//        if (![_selectedArr containsObject:tile.model]) {
//            [_selectedArr addObject:tile.model];
//            _selectedArr = [NSMutableArray arrayWithArray:[_selectedArr sortedArrayUsingComparator:cmptr]];
//            tile.model.isSelected = YES;
//            [self reloadData];
//        }
//        
//        //        if ((self.selectionMode == KalSelectionModeSingle && tile.belongsToAdjacentMonth) ||
//        //            (self.selectionMode == KalSelectionModeRange && (tile.isFirst || tile.isLast))) {
//        //            if ([tile.date compare:logic.baseDate] == NSOrderedDescending) {
//        //                [delegate showFollowingMonth];
//        //            } else {
//        //                [delegate showPreviousMonth];
//        //            }
//        //        }
//        //        if (self.selectionMode == KalSelectionModeRange) {
//        //            NSDate *endDate = tile.date;
//        //            if ([tile.date isEqualToDate:self.beginDate]) {
//        //                if ([[endDate offsetDay:1] compare:self.maxAVailableDate] == NSOrderedDescending) {
//        //                    endDate = [endDate offsetDay:-1];
//        //                } else {
//        //                    endDate = [endDate offsetDay:1];
//        //                }
//        //            }
//        //            self.endDate = endDate;
//        //
//        //            NSDate *realBeginDate = self.beginDate;
//        //            NSDate *realEndDate = self.endDate;
//        //            if ([self.beginDate compare:self.endDate] == NSOrderedDescending) {
//        //                realBeginDate = self.endDate;
//        //                realEndDate = self.beginDate;
//        //            }
//        //            if ([(id)delegate respondsToSelector:@selector(didSelectBeginDate:endDate:)]) {
//        //                [delegate didSelectBeginDate:realBeginDate endDate:realEndDate];
//        //            }
//        //        } else {
//        //            if ([(id)delegate respondsToSelector:@selector(didSelectDate:)]) {
//        //                [delegate didSelectDate:self.beginDate];
//        //            }
//        //        }
//    }
//}


#pragma mark - 刷新UI
NSComparator cmptr2 = ^(CalendarDayModel *model1, CalendarDayModel *model2){
    NSDate *earlier_date = [model1.date earlierDate:model2.date];
    BOOL early = [earlier_date isEqualToDate:model2.date];
    if (early) {
        return (NSComparisonResult)NSOrderedDescending;
    }else{
        return (NSComparisonResult)NSOrderedAscending;
    }
    //    return (NSComparisonResult)NSOrderedSame;
};


@end
