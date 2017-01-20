//
//  UserDetailTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UserDetailTableViewCell.h"

@implementation UserDetailTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    WEAKSELF
    [_titleLabel setFont:kFontTitle];
    [_titleLabel setTextColor:KColorTitleTxt];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(kEdgeInsetsLeft));
        make.centerY.mas_equalTo(weakSelf.contentView);
    }];
    [_contentLabel setFont:kFontSubTitle];
    [_contentLabel setTextColor:KColorSubTitleTxt];
    [_seperatorLine setBackgroundColor:kColorLine];
    _contentLabel.textAlignment = NSTextAlignmentRight;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-kEdgeInsetsLeft);
        make.left.equalTo(_titleLabel.mas_right);
        make.top.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
    }];
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
