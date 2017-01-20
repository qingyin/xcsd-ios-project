//
//  TXCalendarView.m
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXCalendarView.h"
#import "TXAttendanceWeekView.h"

@interface TXCalendarView()
{
    NSMutableArray *_weekViewsArray;
    NSArray *_weekInfo;
    NSMutableArray *_promptViews;
    UIView *_promptView;
    UIView *_endLineView;
}
@end
@implementation TXCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _weekViewsArray = [NSMutableArray arrayWithCapacity:1];
        _promptViews = [NSMutableArray arrayWithCapacity:1];
        [self initViews];
    }
    return self;
}


-(void)initViews
{
    UIView *beginViewLine = [[UIView alloc] init];
    beginViewLine.backgroundColor = kColorLine;
    beginViewLine.frame =CGRectMake(0, 0, kScreenWidth, kLineHeight);
    [self addSubview:beginViewLine];
    
    UIView *middleViewLine = [[UIView alloc] init];
    middleViewLine.backgroundColor = kColorLine;
    middleViewLine.frame = CGRectMake(0, 28, kScreenWidth, kLineHeight);
    [self addSubview:middleViewLine];
    
    UIView *endViewLine = [[UIView alloc] init];
    _endLineView = endViewLine;
    endViewLine.backgroundColor = kColorLine;
    [self addSubview:endViewLine];
    
    NSArray *titles = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    NSMutableArray *titleViews = [NSMutableArray arrayWithCapacity:1];
    for(NSString *title in titles)
    {
        UILabel *titleView = [[UILabel alloc] init];
        titleView.textColor  = KColorTitleTxt;
        titleView.font = kFontSmall_b;
        titleView.text = title;
        titleView.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleView];
        [titleViews addObject:titleView];
    }
    [self layoutTitlesViews:titleViews topView:beginViewLine bottomView:middleViewLine];
    
    
    for (NSInteger i = 0; i < 6; i++) {
        TXAttendanceWeekView *weekView = [[TXAttendanceWeekView alloc] init];
        weekView.backgroundColor = kColorClear;
        weekView.weekViewIndex = i;
        [self addSubview:weekView];
        [_weekViewsArray addObject:weekView];
        weekView.layer.borderColor = [UIColor redColor].CGColor;
    }
    [self layoutWeekViews:_weekViewsArray topView:middleViewLine];
    
    _promptView = [[UIView alloc] init];
    _promptView.backgroundColor = kColorClear;
    [self addSubview:_promptView];
    UIView *colorPromptLastView = nil;
    for(NSInteger i = 1; i >= 0; i--)
    {
    
        UIView *colorPrompt = [self createPromptViewByIndex:i];
        [_promptView addSubview:colorPrompt];
        [colorPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
            if(i == 1)
            {
                make.right.mas_equalTo(_promptView).with.offset(-15);
            }
            else
            {
                make.right.mas_equalTo(colorPromptLastView.mas_left).with.offset(-18);
            }
            make.height.greaterThanOrEqualTo(@(15));
            make.width.greaterThanOrEqualTo(@(80));
            make.centerY.mas_equalTo(_promptView);
        }];
        colorPromptLastView = colorPrompt;
        [_promptViews addObject:colorPrompt];
    }
    self.backgroundColor = kColorClear;
}



-(UIView *)createPromptViewByIndex:(NSInteger)index
{
    UIView *colorPrompt = [[UIView alloc] init];
    NSString *title = nil;
    UIColor *color = nil;
    switch (index) {
        case 0:
        {
            title = @"完成作业";
            color = RGBCOLOR(0x82, 0xd7, 0xff);
        }
            break;
        case 1:
        {
            title = @"未完成作业";
            color = RGBCOLOR(0xff, 0x80, 0x80);

        }
            break;
//        case 2:
//        {
//            title = @"未完成作业";
//            color = RGBCOLOR(0xff, 0x80, 0x80);
//        }
//            break;
        default:
            break;
    }
    CGFloat promptHight = 15.0f;
    CGFloat colorViewWidth = 12.0f;
    UIView *colorView = [[UIView alloc] init];
    colorView.backgroundColor = color;
    colorView.layer.masksToBounds = YES;
    colorView.layer.cornerRadius = colorViewWidth/2;
    colorView.frame = CGRectMake(0, (promptHight-colorViewWidth)/2.0f, colorViewWidth, colorViewWidth);
    [colorPrompt addSubview:colorView];
    
    UILabel *titleView = [[UILabel alloc] init];
    titleView.text = title;
    titleView.textColor = KColorSubTitleTxt;
    titleView.font = kFontMiddle;
    titleView.frame = CGRectMake(colorView.maxX+5, 0, 80, promptHight);
    [colorPrompt addSubview:titleView];
    return colorPrompt;
}




-(void)layoutTitlesViews:(NSMutableArray *)titlesViews topView:(UIView *)topView bottomView:(UIView *)bottomView
{
    
    if(titlesViews == nil || [titlesViews count] == 0
       || !topView || !bottomView)
    {
        return;
    }
    CGFloat viewWidth = 30;
    CGFloat viewHight = 27;
    CGFloat margin = 10;
    CGFloat middleMargin = (kScreenWidth- 2*margin -titlesViews.count * viewWidth)/(titlesViews.count-1);
    
    for(NSInteger i = 0; i < titlesViews.count; i++)
    {
        UIView *dayView = titlesViews[i];
        dayView.frame = CGRectMake(margin+i*(middleMargin+viewWidth), topView.maxY, viewWidth, viewHight);
    }
}

-(void)layoutWeekViews:(NSMutableArray *)weekViews topView:(UIView *)topView
{
    if(weekViews == nil || [weekViews count] == 0
       || !topView)
    {
        return;
    }

    CGFloat weekViewHight = 55.0f;
    for(NSInteger index = 0; index < weekViews.count; index++)
    {
        UIView *weekView = weekViews[index];
        weekView.frame = CGRectMake(0, topView.maxY + weekViewHight*index, kScreenWidth, weekViewHight);
    }
    
    
}


-(UIView *)getLastVisibleWeekView
{
    UIView *lastVisibleWeek = nil;
    for(NSInteger i = _weekViewsArray.count-1; i >= 0; i--)
    {
        TXAttendanceWeekView *weekView = (TXAttendanceWeekView *)_weekViewsArray[i];
        if(weekView.isWeekVisible)
        {
            lastVisibleWeek = weekView;
            break;
        }
    }
    return lastVisibleWeek;
}

/**
 *  根据信息刷新界面
 *
 *  @param weekInfos 出席信息
 */
-(void)refreshViews:(NSArray *)weekInfos
{
    __block UIView *lastWeekView = nil;
    _weekInfo = weekInfos;
    for (TXCalendarWeekModel *index in _weekInfo) {
        [_weekViewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TXAttendanceWeekView *weekView = (TXAttendanceWeekView *)obj;
            if(weekView.weekViewIndex+1 == index.getWeekIndex)
            {
                [weekView setHidden:NO];
                [weekView refreshByWeekInfo:index];
                if(weekView.isWeekVisible)
                {
                    lastWeekView = weekView;
                }
                *stop = YES;
            }
        }];
    }
    if(lastWeekView)
    {
        _endLineView.frame = CGRectMake(0, lastWeekView.maxY+30, kScreenWidth, kLineHeight);
        _promptView.frame = CGRectMake(kScreenWidth-198-10, _endLineView.minY - 8-30, 198, 30);
    }
}

-(void)hiddenWeeks
{
    [_weekViewsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *weekView = (UIView *)obj;
        weekView.hidden = YES;
    }];
}

-(CGFloat)getTotalHight
{
    UIView *lastWeekView = [self getLastVisibleWeekView];
    NSInteger index = [_weekViewsArray indexOfObject:lastWeekView];
    
    return (index+1)*55+30 + 28;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
