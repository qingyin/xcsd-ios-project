//
//  assessCell.m
//  TXChatParent
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "AssessCell.h"
#import "NSDate+TuXing.h"

@implementation AssessCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindDateWithCourseComment:(TXPBCourseComment *)comment
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    if (!self.lableName) {
        self.iconImage = [[UIImageView alloc]init];
        [self.contentView addSubview:self.iconImage];
        self.iconImage.layer.masksToBounds = YES;
        self.iconImage.layer.cornerRadius = 4;
        self.iconImage.backgroundColor = [UIColor redColor];
        
        [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(11);
            make.left.mas_equalTo(10);
            make.width.mas_equalTo(30);
            make.height.mas_equalTo(30);
        }];
        
        self.lableName = [[UILabel alloc]init];
        [self.contentView addSubview:self.lableName];
        
        [self.lableName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(14);
            make.left.mas_equalTo(self.iconImage.mas_right).with.offset(15);
            make.right.mas_equalTo(-(5*13+12+16+10));
        }];
        
        self.lableData = [[UILabel alloc]init];
        [self.contentView addSubview:self.lableData];
        
        [self.lableData mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lableName.mas_bottom).with.offset(6);
            make.left.mas_equalTo(self.lableName.mas_left).with.offset(0);
            make.right.mas_equalTo(-12);
        }];
        
        self.lableContent = [[UILabel alloc]init];
        [self.contentView addSubview:self.lableContent];
        
        [self.lableContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lableData.mas_bottom).with.offset(12);
            make.left.mas_equalTo(self.lableData.mas_left).with.offset(0);
            make.right.mas_equalTo(-12);
        }];
        
        self.image5 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image5];
        
        [self.image5 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-14);
            make.centerY.mas_equalTo(self.lableName.mas_centerY).with.offset(0);
        }];
        
        self.image4 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image4];
        
        [self.image4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.image5.mas_left).with.offset(-4);
            make.centerY.mas_equalTo(self.image5.mas_centerY).with.offset(0);
        }];
        
        self.image3 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image3];
        
        [self.image3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.image4.mas_left).with.offset(-4);
            make.centerY.mas_equalTo(self.image4.mas_centerY).with.offset(0);
        }];
        
        self.image2 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image2];
        
        [self.image2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.image3.mas_left).with.offset(-4);
            make.centerY.mas_equalTo(self.image3.mas_centerY).with.offset(0);
        }];
        
        self.image1 = [[UIImageView alloc]init];
        [self.contentView addSubview:self.image1];
        
        [self.image1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.image2.mas_left).with.offset(-4);
            make.centerY.mas_equalTo(self.image2.mas_centerY).with.offset(0);
        }];
        
        self.lineView = [[UIView alloc]init];
        [self.contentView addSubview:self.lineView];
        self.lineView.backgroundColor = kColorLine;
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.lableContent.mas_left).with.offset(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(-0.5);
        }];
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.lableContent.mas_bottom).with.offset(13);
        }];
        
        self.lableName.font = kFontChildSection;
        self.lableName.textColor = kColorBtn;
        self.lableData.font = kFontMini;
        self.lableData.textColor = KColorNewSubTitleTxt;
        self.lableContent.font = kFontSmall;
        self.lableContent.textColor = KColorTitleTxt;
        self.lableContent.numberOfLines = 0;
    }
    
    if (comment != nil) {
        
        if (comment.score == 1) {
            self.image1.image = [UIImage imageNamed:@"s-star_68"];
            self.image2.image = [UIImage imageNamed:@"s-star_71"];
            self.image3.image = [UIImage imageNamed:@"s-star_71"];
            self.image4.image = [UIImage imageNamed:@"s-star_71"];
            self.image5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (comment.score == 2) {
            self.image1.image = [UIImage imageNamed:@"s-star_68"];
            self.image2.image = [UIImage imageNamed:@"s-star_68"];
            self.image3.image = [UIImage imageNamed:@"s-star_71"];
            self.image4.image = [UIImage imageNamed:@"s-star_71"];
            self.image5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (comment.score == 3) {
            self.image1.image = [UIImage imageNamed:@"s-star_68"];
            self.image2.image = [UIImage imageNamed:@"s-star_68"];
            self.image3.image = [UIImage imageNamed:@"s-star_68"];
            self.image4.image = [UIImage imageNamed:@"s-star_71"];
            self.image5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (comment.score == 4) {
            self.image1.image = [UIImage imageNamed:@"s-star_68"];
            self.image2.image = [UIImage imageNamed:@"s-star_68"];
            self.image3.image = [UIImage imageNamed:@"s-star_68"];
            self.image4.image = [UIImage imageNamed:@"s-star_68"];
            self.image5.image = [UIImage imageNamed:@"s-star_71"];
        }
        if (comment.score == 5) {
            self.image1.image = [UIImage imageNamed:@"s-star_68"];
            self.image2.image = [UIImage imageNamed:@"s-star_68"];
            self.image3.image = [UIImage imageNamed:@"s-star_68"];
            self.image4.image = [UIImage imageNamed:@"s-star_68"];
            self.image5.image = [UIImage imageNamed:@"s-star_68"];
        }
        
        self.lableName.text = comment.userName;
        NSString *date = [NSString stringWithFormat:@"%lld",comment.createOn/1000];
        self.lableData.text = [NSDate timeForNoticeStyle:date];
        self.lableContent.text = comment.content;
        [self.iconImage TX_setImageWithURL:[NSURL URLWithString:[comment.userAvatar getFormatPhotoUrl:30 hight:30]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.lableContent.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:7];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.lableContent.text length])];
        self.lableContent.attributedText = attributedString;
    }
}

@end
