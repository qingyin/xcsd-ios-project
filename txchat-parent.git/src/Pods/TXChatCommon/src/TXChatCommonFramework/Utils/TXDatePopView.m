//
//  TXDatePopView.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/4.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXDatePopView.h"
#import <MMPopupView/MMPopupDefine.h>
#import <MMPopupView/MMPopupCategory.h>
#import <Masonry/Masonry.h>

@interface TXDatePopView()

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) UIButton *btnCancel;
@property (nonatomic, strong) UIButton *btnConfirm;
@property (nonatomic, copy) PickerSelectedDateBlock selectedDateBlock;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation TXDatePopView

- (instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        self.type = MMPopupTypeSheet;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
            make.height.mas_equalTo(216+50);
        }];
        
        self.btnCancel = [UIButton mm_buttonWithTarget:self action:@selector(actionHide)];
        [self addSubview:self.btnCancel];
        [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 50));
            make.left.top.equalTo(self);
        }];
        [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:MMHexColor(0x444444FF) forState:UIControlStateNormal];
        
        
        self.btnConfirm = [UIButton mm_buttonWithTarget:self action:@selector(confirmDatePick)];
        [self addSubview:self.btnConfirm];
        [self.btnConfirm mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 50));
            make.right.top.equalTo(self);
        }];
        [self.btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [self.btnConfirm setTitleColor:MMHexColor(0x444444FF) forState:UIControlStateNormal];
        
        self.datePicker = [UIDatePicker new];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
        _datePicker.locale = locale;
        _datePicker.backgroundColor = [UIColor whiteColor];
        [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.datePicker];
        [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(50, 0, 0, 0));
        }];
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithRed:216/255.f green:216/255.f blue:216/255.f alpha:1.f];
        [self addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(_btnConfirm.mas_bottom);
            make.height.equalTo(@(0.5));
        }];

    }
    
    return self;
}
//设置时间
- (void)setPickerCurrentDate:(NSDate *)currentDate
                 minimumDate:(NSDate *)minimumDate
                 maximumDate:(NSDate *)maximumDate
                selectedDate:(NSDate *)selectedDate
               selectedBlock:(void(^)(NSDate *selectedDate))selectedBlcok
{
    if (selectedBlcok) {
        self.selectedDateBlock = selectedBlcok;
    }
    if (currentDate) {
        _datePicker.date = currentDate;
    }
    if (minimumDate) {
        _datePicker.minimumDate = minimumDate;
    }
    if (maximumDate) {
        _datePicker.maximumDate = maximumDate;
    }
    if(selectedDate){
        _datePicker.date = selectedDate;
        self.selectedDate = selectedDate;
    }else{
        self.selectedDate  = [NSDate date];
    }
}
//日期更改
- (void)onDatePickerValueChanged:(UIDatePicker *)picker
{
    self.selectedDate = picker.date;
}

- (void)actionHide
{
    [self hide];
}

- (void)confirmDatePick
{
    //block传递
    if (self.selectedDateBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.selectedDateBlock(self.selectedDate);
        });
    }
    [self hide];
}

@end
