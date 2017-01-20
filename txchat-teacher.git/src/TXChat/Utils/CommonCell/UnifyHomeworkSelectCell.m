//
//  UnifyHomeworkSelectCell.m
//  TXChatTeacher
//
//  Created by gaoju on 16/6/28.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "UnifyHomeworkSelectCell.h"

@interface UnifyHomeworkSelectCell ()




@end

@implementation UnifyHomeworkSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = RGBCOLOR(72, 72, 72);
    label.font = [UIFont boldSystemFontOfSize:15];
    [label sizeToFit];
    [self.contentView addSubview:label];
    self.levelLbl = label;
    
    UIButton *btn = [[UIButton alloc] init];
    btn.userInteractionEnabled = NO;
    [btn setImage:[UIImage imageNamed:@"LearnWork_nav_normal"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"LearnWork_nav_pass"] forState:UIControlStateSelected];
    self.seletBtn = btn;
    [self.contentView addSubview:btn];
    
    UIView *separteView = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentView.height_ - 1, kScreenWidth, 1)];
    separteView.backgroundColor = kColorLine;
    [self.contentView addSubview:separteView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self.levelLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10.);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.seletBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10.0);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.equalTo(@20);
    }];
}

@end
