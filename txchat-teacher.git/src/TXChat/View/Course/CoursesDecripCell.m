//
//  CoursesDecripCell.m
//  1
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CoursesDecripCell.h"

@implementation CoursesDecripCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateWithCourse:(TXPBCourse *)course andBool:(BOOL)reload;
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    if (!self.decripLable) {
        
        UIView *view = [[UIView alloc]init];
        [self.contentView addSubview:view];
        view.backgroundColor = KColorAppMain;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(17);
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(2);
            make.height.mas_equalTo(13);
        }];
        
        self.lable = [[UILabel alloc]init];
        [self.contentView addSubview:self.lable];
        self.lable.text = @"课程概述";
        self.lable.font = kFontSubTitle;
        self.lable.textColor = KColorTitleTxt;
        [self.lable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(view.mas_right).with.offset(4);
        }];
        
        self.decripLable = [[UILabel alloc]init];
        [self.contentView addSubview:self.decripLable];
        self.decripLable.font = kFontSmall;
        self.decripLable.textColor = kColorBtn;

        [self.decripLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lable.mas_bottom).with.offset(8);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
        }];
        
        self.MoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:self.MoreBtn];
        [self.MoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.decripLable.mas_bottom).with.offset(10);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(kScreenWidth);
        }];
        
        //分割线
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = kColorLine;
        [self.contentView addSubview:self.lineView];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-0.5);
            make.height.mas_equalTo(0.5);
        }];
    }
    if (course != nil) {
        self.decripLable.text = course.pb_description;
        self.decripLable.numberOfLines = 0;
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.decripLable.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:7];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.decripLable.text length])];
        self.decripLable.attributedText = attributedString;
        
        CGFloat decripLableHeight = [self.decripLable sizeThatFits:CGSizeMake(self.contentView.frame.size.width-20, MAXFLOAT)].height;
        
        if (reload) {
            self.decripLable.numberOfLines = 0;
            [self.MoreBtn setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
        }else{
            self.decripLable.numberOfLines = 3;
            [self.MoreBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        }
        
        
        if (decripLableHeight > 61) {
            self.MoreBtn.hidden = NO;
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.MoreBtn.mas_bottom).with.offset(10);
            }];
        }else{
            self.MoreBtn.hidden = YES;
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.decripLable.mas_bottom).with.offset(10);
            }];
        }
    }
}

@end
