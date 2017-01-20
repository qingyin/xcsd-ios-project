//
//  ClassTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ClassTableViewCell.h"

@implementation ClassTableViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_classNameLabel setFont:kFontTitle];
    [_classNameLabel setTextColor:KColorTitleTxt];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
    }];
    _classIconImageView.layer.cornerRadius = 40.0f/2.0f;
    _classIconImageView.layer.masksToBounds = YES;
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
