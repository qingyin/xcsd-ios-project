//
//  CalendarDayCell.m
//  tttttt
//
//  Created by 张凡 on 14-8-20.
//  Copyright (c) 2014年 张凡. All rights reserved.
//

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

#import "CalendarDayCell.h"
#import "CalendarViewController.h"
#import <NSDate+DateTools.h>

@implementation CalendarDayCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView{
    self.clipsToBounds = YES;
    self.contentView.clipsToBounds = YES;
//    //选中时显示的图片
//    imgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
//    imgview.backgroundColor = RGBACOLOR(255, 183, 105, 0.5);
////    imgview.image = [UIImage imageNamed:@"chack.png"];
//    [self addSubview:imgview];
    
    //日期
    day_lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
    day_lab.numberOfLines = 0;
    day_lab.backgroundColor = kColorClear;
    day_lab.textAlignment = NSTextAlignmentCenter;
    day_lab.font = kFontMiddle;
    [self addSubview:day_lab];

//    //农历
//    day_title = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-15, self.bounds.size.width, 13)];
//    day_title.textColor = [UIColor lightGrayColor];
//    day_title.font = [UIFont boldSystemFontOfSize:10];
//    day_title.textAlignment = NSTextAlignmentCenter;
//    [self addSubview:day_title];
    

}


- (void)setModel:(CalendarDayModel *)model
{
    _model = model;
    switch (model.style) {
        case CellDayTypeEmpty://不显示
            [self hidden_YES];
            break;
            
        case CellDayTypePast://过去的日期
            [self hidden_NO];
            
            if (model.holiday) {
                day_lab.text = model.holiday;
            }else{
                day_lab.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
            }
            
            day_lab.textColor = [UIColor lightGrayColor];
//            day_title.text = model.Chinese_calendar;
//            imgview.hidden = YES;
            break;
            
        case CellDayTypeFutur://将来的日期
            [self hidden_NO];
            
            if (model.holiday) {
                day_lab.text = model.holiday;
                day_lab.textColor = COLOR_THEME;
            }else{
                day_lab.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
                day_lab.textColor = COLOR_THEME;
            }
            
//            day_title.text = model.Chinese_calendar;
//            imgview.hidden = YES;
            break;
            
        case CellDayTypeWeek://周末
            [self hidden_NO];
            
            if (model.holiday) {
                day_lab.text = model.holiday;
                day_lab.textColor = COLOR_THEME;
            }else{
                day_lab.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
                day_lab.textColor = kColorLightGray;
            }
            
//            day_title.text = model.Chinese_calendar;
//            imgview.hidden = YES;
            break;
            
        case CellDayTypeClick://被点击的日期
            [self hidden_NO];
            if ([model.date isToday]) {
                day_lab.text = @"今天";
            }else{
                day_lab.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
            }
            day_lab.textColor = [UIColor whiteColor];
//            day_title.text = model.Chinese_calendar;
//            imgview.hidden = NO;
            
            if (!_calendarVC.selectedArr.count) {
                [_calendarVC.selectedArr addObject:model];
            }
//
//            break;
            
        default:
            
            break;
    }
    
    
    BOOL isSelected = NO;
    if (_calendarVC.selectedArr.count > 1 && model.style != CellDayTypeWeek) {
        CalendarDayModel *firstModel = _calendarVC.selectedArr.firstObject;
        CalendarDayModel *lastModel = _calendarVC.selectedArr.lastObject;
        NSDate *earlier_date = [model.date earlierDate:firstModel.date];
        NSDate *earlier_date1 = [model.date earlierDate:lastModel.date];
        if ([earlier_date isEqualToDate:firstModel.date] && [earlier_date1 isEqualToDate:model.date] && ![_calendarVC.selectedArr containsObject:model] && model.style != CellDayTypeEmpty && model.style != CellDayTypePast) {
//            isSelected = YES;
            [_calendarVC.selectedArr addObject:model];
            _calendarVC.selectedArr = [NSMutableArray arrayWithArray:[_calendarVC.selectedArr sortedArrayUsingComparator:cmptr1]];
//            [_calendarVC reloadData];
        }
    }
    BOOL isDark = NO;
    if ([_calendarVC.selectedArr containsObject:model]) {
        isSelected = YES;
        if ([_calendarVC.selectedArr indexOfObject:model] == 0) {
            isDark = YES;
            day_lab.text = [NSString stringWithFormat:@"%@\n开始",day_lab.text];
        }else if ([model isEqual:[_calendarVC.selectedArr lastObject]]){
            isDark = YES;
            day_lab.text = [NSString stringWithFormat:@"%@\n结束",day_lab.text];
        }
    }else{
        isSelected = NO;
    }
    day_lab.font = kFontMiddle;
    if (isSelected) {
        day_lab.font = kFontMiddle_b;
        if (!isDark) {
            day_lab.backgroundColor = RGBACOLOR(255, 183, 105, 0.5);
        }else{
            day_lab.textColor = kColorWhite;
            day_lab.backgroundColor = KColorAppMain;
        }
    }else{
        day_lab.backgroundColor = kColorClear;
    }
//    imgview.hidden = !isSelected;
}



- (void)hidden_YES{
    
    day_lab.hidden = YES;
//    day_title.hidden = YES;
//    imgview.hidden = YES;
    
}


- (void)hidden_NO{
    
    day_lab.hidden = NO;
//    day_title.hidden = NO;
    
}

//#pragma mark -
//#pragma mark Touches
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    _calendarVC.collectionView.scrollEnabled = NO;
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:_calendarVC.collectionView];
//    UIView *hitView = [_calendarVC.collectionView hitTest:location withEvent:event];
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
//        if (![_calendarVC.selectedArr containsObject:tile.model]) {
//            [_calendarVC.selectedArr addObject:tile.model];
//            _calendarVC.selectedArr = [NSMutableArray arrayWithArray:[_calendarVC.selectedArr sortedArrayUsingComparator:cmptr1]];
//            tile.model.isSelected = YES;
//            [_calendarVC reloadData];
//        }
//
//        
////        NSDate *date = tile.date;
////        if ([date isEqualToDate:self.beginDate]) {
////            if (self.selectionMode == KalSelectionModeSingle) return;
////            
////            date = self.beginDate;
////            _beginDate = _endDate;
////            _endDate = date;
////        } else if ([date isEqualToDate:self.endDate]) {
////            
////        } else {
////            self.beginDate = date;
////        }
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self];
//    UIView *hitView = [self hitTest:location withEvent:event];
//    
//    if (!hitView)
//        return;
//    if ([hitView.superview isKindOfClass:[CalendarDayCell class]]) {
//        CalendarDayCell *tile = (CalendarDayCell*)hitView.superview;
//        NSLog(@"%@",tile);
//        if (tile.model.style == CellDayTypeEmpty ||
//            tile.model.style == CellDayTypePast)
//            return;
//        if (![_calendarVC.selectedArr containsObject:tile.model]) {
//            [_calendarVC.selectedArr addObject:tile.model];
//            _calendarVC.selectedArr = [NSMutableArray arrayWithArray:[_calendarVC.selectedArr sortedArrayUsingComparator:cmptr1]];
//            tile.model.isSelected = YES;
//            [_calendarVC reloadData];
//        }
//
////        NSDate *endDate = tile.date;
////        if (!endDate || [endDate isEqualToDate:self.beginDate] || [endDate isEqualToDate:self.endDate])
////            return;
////        if (tile.isFirst || tile.isLast) {
////            if ([tile.date compare:logic.baseDate] == NSOrderedDescending) {
////                [delegate showFollowingMonth];
////            } else {
////                [delegate showPreviousMonth];
////            }
////        }
////        self.endDate = endDate;
//    }
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    _calendarVC.collectionView.scrollEnabled = YES;
//    UITouch *touch = [touches anyObject];
//    CGPoint location = [touch locationInView:self];
//    UIView *hitView = [self hitTest:location withEvent:event];
//    
//    if ([hitView.superview isKindOfClass:[CalendarDayCell class]]) {
//        CalendarDayCell *tile = (CalendarDayCell*)hitView.superview;
//        if (tile.model.style == CellDayTypeEmpty ||
//            tile.model.style == CellDayTypePast)
//            return;
//        if (![_calendarVC.selectedArr containsObject:tile.model]) {
//            [_calendarVC.selectedArr addObject:tile.model];
//            _calendarVC.selectedArr = [NSMutableArray arrayWithArray:[_calendarVC.selectedArr sortedArrayUsingComparator:cmptr1]];
//            tile.model.isSelected = YES;
//            [_calendarVC reloadData];
//        }
//        
////        if ((self.selectionMode == KalSelectionModeSingle && tile.belongsToAdjacentMonth) ||
////            (self.selectionMode == KalSelectionModeRange && (tile.isFirst || tile.isLast))) {
////            if ([tile.date compare:logic.baseDate] == NSOrderedDescending) {
////                [delegate showFollowingMonth];
////            } else {
////                [delegate showPreviousMonth];
////            }
////        }
////        if (self.selectionMode == KalSelectionModeRange) {
////            NSDate *endDate = tile.date;
////            if ([tile.date isEqualToDate:self.beginDate]) {
////                if ([[endDate offsetDay:1] compare:self.maxAVailableDate] == NSOrderedDescending) {
////                    endDate = [endDate offsetDay:-1];
////                } else {
////                    endDate = [endDate offsetDay:1];
////                }
////            }
////            self.endDate = endDate;
////            
////            NSDate *realBeginDate = self.beginDate;
////            NSDate *realEndDate = self.endDate;
////            if ([self.beginDate compare:self.endDate] == NSOrderedDescending) {
////                realBeginDate = self.endDate;
////                realEndDate = self.beginDate;
////            }
////            if ([(id)delegate respondsToSelector:@selector(didSelectBeginDate:endDate:)]) {
////                [delegate didSelectBeginDate:realBeginDate endDate:realEndDate];
////            }
////        } else {
////            if ([(id)delegate respondsToSelector:@selector(didSelectDate:)]) {
////                [delegate didSelectDate:self.beginDate];
////            }
////        }
//    }
//}

#pragma mark - 刷新UI
NSComparator cmptr1 = ^(CalendarDayModel *model1, CalendarDayModel *model2){
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
