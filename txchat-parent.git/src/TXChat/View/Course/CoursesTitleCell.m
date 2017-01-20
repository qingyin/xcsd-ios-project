//
//  CoursesTitleCell.m
//  1
//
//  Created by frank on 16/3/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import "CoursesTitleCell.h"

@implementation CoursesTitleCell

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
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    if (!self.title) {
        self.title = [[UILabel alloc]init];
        [self.contentView addSubview:self.title];
        self.title.numberOfLines = 0;
        
        self.title.font = kFontMiddle;
        self.title.textColor = KColorTitleTxt;
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(18);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
        }];

        self.studyCount = [[UILabel alloc]init];
        [self.contentView addSubview:self.studyCount];
        self.studyCount.font = kFontTimeTitle;
        self.studyCount.textColor = kColorBtn;
        [self.studyCount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.title.mas_bottom).with.offset(18);
            make.left.mas_equalTo(10);
        }];

        
        self.image1 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image1];
        
        self.image2 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image2];
        
        self.image3 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image3];
        
        self.image4 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image4];
        
        self.image5 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image5];
        
        
        [self.image1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.studyCount.mas_centerY).with.offset(0);
            make.left.mas_equalTo(self.studyCount.mas_right).with.offset(20);
//            make.width.mas_equalTo(13);
//            make.height.mas_equalTo(13);
            
        }];
        
        [self.image2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.image1.mas_top);
            make.left.mas_equalTo(self.image1.mas_right).with.offset(4);
            make.width.height.mas_equalTo(self.image1.mas_width).with.offset(0);
        }];
        
        [self.image3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.image2.mas_top);
            make.left.mas_equalTo(self.image2.mas_right).with.offset(4);
            make.width.height.mas_equalTo(self.image2.mas_width).with.offset(0);
        }];
        
        [self.image4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.image3.mas_top);
            make.left.mas_equalTo(self.image3.mas_right).with.offset(4);
            make.width.height.mas_equalTo(self.image3.mas_width).with.offset(0);
        }];
        
        [self.image5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.image4.mas_top);
            make.left.mas_equalTo(self.image4.mas_right).with.offset(4);
            make.width.height.mas_equalTo(self.image4.mas_width).with.offset(0);
        }];
        
        self.assments = [[UILabel alloc]init];
        self.assments.font = kFontTimeTitle;
        self.assments.textColor = kColorStar;
        [self.contentView addSubview:self.assments];
        [self.assments mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.studyCount.mas_top).with.offset(0);
            make.left.mas_equalTo(self.image5.mas_right).with.offset(6);
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
            make.bottom.mas_equalTo(self.assments.mas_bottom).with.offset(13);
        }];
    }
    if (course != nil) {
        self.title.text = course.title;
        self.assments.text = [NSString stringWithFormat:@"%.1f分",course.score];
        self.studyCount.text = [NSString stringWithFormat:@"%lld人学过",course.hits];
        
        
        int num = (int)course.score;
        if (num == 0) {
            self.image1.image = [UIImage imageNamed:@"m-star_50"];
            self.image3.image = [UIImage imageNamed:@"m-star_50"];
            self.image4.image = [UIImage imageNamed:@"m-star_50"];
            self.image5.image = [UIImage imageNamed:@"m-star_50"];
            self.image2.image = [UIImage imageNamed:@"m-star_50"];
        }
        if (num == 1) {
            if (course.score-num != 0) {
                self.image2.image = [UIImage imageNamed:@"m-star_53"];
            }else{
                self.image2.image = [UIImage imageNamed:@"m-star_50"];
            }
            self.image1.image = [UIImage imageNamed:@"m-star_47"];
            self.image3.image = [UIImage imageNamed:@"m-star_50"];
            self.image4.image = [UIImage imageNamed:@"m-star_50"];
            self.image5.image = [UIImage imageNamed:@"m-star_50"];
        }
        if (num == 2) {
            if (course.score-num != 0) {
                self.image3.image = [UIImage imageNamed:@"m-star_53"];
            }else{
                self.image3.image = [UIImage imageNamed:@"m-star_50"];
            }
            self.image1.image = [UIImage imageNamed:@"m-star_47"];
            self.image2.image = [UIImage imageNamed:@"m-star_47"];
            self.image4.image = [UIImage imageNamed:@"m-star_50"];
            self.image5.image = [UIImage imageNamed:@"m-star_50"];
        }
        if (num == 3) {
            if (course.score-num != 0) {
                self.image4.image = [UIImage imageNamed:@"m-star_53"];
            }else{
                self.image4.image = [UIImage imageNamed:@"m-star_50"];
            }
            self.image1.image = [UIImage imageNamed:@"m-star_47"];
            self.image3.image = [UIImage imageNamed:@"m-star_47"];
            self.image2.image = [UIImage imageNamed:@"m-star_47"];
            self.image5.image = [UIImage imageNamed:@"m-star_50"];
        }
        if (num == 4) {
            if (course.score-num != 0) {
                self.image5.image = [UIImage imageNamed:@"m-star_53"];
            }else{
                self.image5.image = [UIImage imageNamed:@"m-star_50"];
            }
            self.image1.image = [UIImage imageNamed:@"m-star_47"];
            self.image3.image = [UIImage imageNamed:@"m-star_47"];
            self.image2.image = [UIImage imageNamed:@"m-star_47"];
            self.image4.image = [UIImage imageNamed:@"m-star_47"];
        }
        if (num == 5) {
            self.image1.image = [UIImage imageNamed:@"m-star_47"];
            self.image3.image = [UIImage imageNamed:@"m-star_47"];
            self.image4.image = [UIImage imageNamed:@"m-star_47"];
            self.image5.image = [UIImage imageNamed:@"m-star_47"];
            self.image2.image = [UIImage imageNamed:@"m-star_47"];
        }
        
        
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.title.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:4];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.title.text length])];
        self.title.attributedText = attributedString;
    }
}

@end
