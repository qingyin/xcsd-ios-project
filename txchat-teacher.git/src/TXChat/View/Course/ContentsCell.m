//
//  contentsCell.m
//  TXChatParent
//
//  Created by frank on 16/3/16.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "ContentsCell.h"
#import "BroadcastVideoItem.h"

@implementation ContentsCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDateWithItem:(BroadcastVideoItem *)item andIndex:(NSInteger)index
{
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self);
        make.bottom.mas_equalTo(0);
    }];
    if (!self.titleLable) {
        self.lable1 = [[UILabel alloc]init];
        [self.contentView addSubview:self.lable1];
        
        [self.lable1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(12);
            make.width.mas_equalTo(20);
        }];
        
        self.titleLable = [[UILabel alloc]init];
        [self.contentView addSubview:self.titleLable];
        
        [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(37);
            make.right.mas_equalTo(-12);
        }];
        
        self.timeLable = [[UILabel alloc]init];
        [self.contentView addSubview:self.timeLable];
        
        [self.timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.top.mas_equalTo(self.titleLable.mas_bottom).with.offset(8);
        }];
        
//        self.imageV = [[UIImageView alloc]init];
//        [self.contentView addSubview:self.imageV];
//        self.imageV.image = [UIImage imageNamed:@"tips_95"];
//        
//        [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.titleLable.mas_bottom).with.offset(8);
//            make.left.mas_equalTo(self.titleLable.mas_left).with.offset(0);
//        }];
        
        self.lineView = [[UIView alloc]init];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLable.mas_left).with.offset(0);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).with.offset(-0.5);
            make.height.mas_equalTo(0.5);
            make.right.mas_equalTo(0);
        }];
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.timeLable.mas_bottom).with.offset(9);
        }];
    }

    if (item != nil) {
        
        self.titleLable.textColor = KColorTitleTxt;
        self.titleLable.font = kFontSmall;
        self.titleLable.numberOfLines = 0;
        self.timeLable.font = kFontMini;
        self.timeLable.textColor = KColorNewSubTitleTxt;
        self.lable1.font = kFontSmall;
        self.lable1.textColor = KColorTitleTxt;
        self.lineView.backgroundColor = kColorLine;
        
        self.titleLable.text = item.title;
        if (item.duration < 60) {
            self.timeLable.text = @"时长：1分钟";
        }else{
            self.timeLable.text = [NSString stringWithFormat:@"时长：%ld分钟",item.duration/60];
        }
        if (index+1<10) {
            self.lable1.text = [NSString stringWithFormat:@"0%ld",index+1];
        }else{
            self.lable1.text = [NSString stringWithFormat:@"%ld",(long)index+1];
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.titleLable.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        
        [paragraphStyle setLineSpacing:6];//调整行间距
        
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.titleLable.text length])];
        self.titleLable.attributedText = attributedString;
    }
}

@end
