//
//  SpecialResponseTableViewCell.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "SpecialResponseTableViewCell.h"

@implementation SpecialResponseTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    
    _questionTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    _questionTitleLabel.textColor = KColorTitleTxt;
    [_questionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kEdgeInsetsLeft);
        make.right.mas_equalTo(_supportIconImgView.mas_left).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(10);
    }];
    
    _answerDetailLabel.font = [UIFont systemFontOfSize:14];
    _answerDetailLabel.textColor = KColorTitleTxt;
    _answerDetailLabel.numberOfLines = 2;
    [_answerDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kEdgeInsetsLeft);
        make.right.mas_equalTo(-kEdgeInsetsLeft);
        make.top.mas_equalTo(_questionTitleLabel.mas_bottom).with.offset(7);
    }];
    
    _supportCountLabel.font = kFontTimeTitle;
    _supportCountLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
    _supportCountLabel.textAlignment = NSTextAlignmentRight;
    [_supportCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(-(kEdgeInsetsLeft));
        make.centerY.mas_equalTo(_questionTitleLabel);
//        make.width.mas_equalTo(50);
//        make.width.mas_greaterThanOrEqualTo(@(25));
    }];
    
    [_supportIconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_supportCountLabel);
        make.size.mas_equalTo(_supportIconImgView.image.size);
        make.right.mas_equalTo(_supportCountLabel.mas_left).with.offset(-kEdgeInsetsLeft/2);
    }];
    
    [_seperatorLine setBackgroundColor:RGBCOLOR(0xe5, 0xe5, 0xe5)];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(self.contentView).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(self.mas_bottom).with.offset(-kLineHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
