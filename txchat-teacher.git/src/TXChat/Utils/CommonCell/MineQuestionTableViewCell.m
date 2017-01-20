//
//  MineQuestionTableViewCell.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MineQuestionTableViewCell.h"

@implementation MineQuestionTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    _titleLabel.font = kFontMiddle_1_b;
    _titleLabel.textColor = KColorTitleTxt;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kEdgeInsetsLeft);
        make.right.mas_equalTo(-kEdgeInsetsLeft);
        make.top.mas_equalTo(kEdgeInsetsLeft-2);
    }];
    
    _detailLabel.font = kFontTiny;
    _detailLabel.numberOfLines = 2;
    _detailLabel.textColor = KColorTitleTxt;
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kEdgeInsetsLeft);
        make.right.mas_equalTo(-kEdgeInsetsLeft);
        make.top.mas_equalTo(_titleLabel.mas_bottom).with.offset(kEdgeInsetsLeft-5);
        
    }];
    
    _answerLabel.font = kFontTimeTitle;
    _answerLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
    _answerLabel.textAlignment = NSTextAlignmentRight;
    [_answerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-kEdgeInsetsLeft);
        make.bottom.mas_equalTo(-kEdgeInsetsLeft-1);
    }];
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
