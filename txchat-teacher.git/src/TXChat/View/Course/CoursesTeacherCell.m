//
//  CoursesTeacherCell.m
//  1
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CoursesTeacherCell.h"

@implementation CoursesTeacherCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateWithCourse:(TXPBCourse *)course
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    if (!self.lableContent) {
        
        UIView *view = [[UIView alloc]init];
        [self.contentView addSubview:view];
        view.backgroundColor = KColorAppMain;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(17);
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(2);
            make.height.mas_equalTo(13);
        }];
        
        self.lableTitle = [[UILabel alloc]init];
        [self.contentView addSubview:self.lableTitle];
        self.lableTitle.text = @"讲师";
        self.lableTitle.font = kFontSubTitle;
        self.lableTitle.textColor = KColorTitleTxt;
        [self.lableTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.left.mas_equalTo(view.mas_right).with.offset(4);
        }];
        
        self.iconImage = [[UIImageView alloc]init];
        [self.contentView addSubview:self.iconImage];
        self.iconImage.layer.cornerRadius = 4;
        self.iconImage.layer.masksToBounds = YES;
        [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lableTitle.mas_bottom).with.offset(13);
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(30);
        }];
        
        self.lableName = [[UILabel alloc]init];
        [self.contentView addSubview:self.lableName];
        self.lableName.font = kFontSubTitle;
        self.lableName.textColor = KColorTitleTxt;
        [self.lableName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconImage.mas_right).with.offset(15);
            make.centerY.mas_equalTo(self.iconImage.mas_centerY).with.offset(0);
        }];
        
        self.lableContent = [[UILabel alloc]init];
        [self.contentView addSubview:self.lableContent];
        self.lableContent.font = kFontSmall;
        self.lableContent.textColor = kColorBtn;
        self.lableContent.numberOfLines = 0;
        
        
        [self.lableContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lableName.mas_bottom).with.offset(10);
            make.left.mas_equalTo(self.lableName.mas_left).with.offset(0);
            make.right.mas_equalTo(-10);
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
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.lableContent.mas_bottom).with.offset(20);
        }];
    }
    if (course != nil) {
        self.lableName.text = course.teacherName;
        self.lableContent.text = course.teacherDesc;
        [self.iconImage TX_setImageWithURL:[NSURL URLWithString:[course.teacherAvatar getFormatPhotoUrl:30 hight:30]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.lableContent.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:7];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.lableContent.text length])];
        self.lableContent.attributedText = attributedString;
    }
}

@end
