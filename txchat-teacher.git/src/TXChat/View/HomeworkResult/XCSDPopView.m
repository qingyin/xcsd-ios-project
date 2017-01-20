//
//  XCSDPopView.m
//  TXChatTeacher
//
//  Created by gaoju on 16/7/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "XCSDPopView.h"

@interface XCSDPopView ()

@property (nonatomic, weak) UILabel *titleLbl;

@property (nonatomic, weak) UIButton *closeBtn;

@property (nonatomic, weak) UILabel *textLbl;

@end

@implementation XCSDPopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.layer.backgroundColor = RGBCOLOR(65, 195, 255).CGColor;
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.font = [UIFont systemFontOfSize:15];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    self.titleLbl = titleLbl;
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    self.closeBtn = closeBtn;
    
    UILabel *textLbl = [[UILabel alloc] init];
    textLbl.font = [UIFont systemFontOfSize:14];
    textLbl.textColor = RGBCOLOR(170, 170, 170);
    textLbl.numberOfLines = 0;
    [textLbl sizeToFit];
    self.textLbl = textLbl;
    
    [self addSubview:titleLbl];
    [self.titleLbl addSubview:closeBtn];
    [self addSubview:textLbl];
}

- (void)setTitle:(NSString *)title text:(NSString *)text{
    self.titleLbl.text = title;
    self.textLbl.text = text;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@30);
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_titleLbl);
        make.left.equalTo(_titleLbl.mas_left).offset(10);
    }];
    
    [_textLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(25);
        make.right.equalTo(self.mas_right).offset(-25);
        make.top.equalTo(_titleLbl.mas_bottom).offset(20);
    }];
}

@end
