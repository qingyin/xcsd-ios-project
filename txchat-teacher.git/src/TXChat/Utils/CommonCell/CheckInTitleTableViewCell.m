//
//  CheckInTitleTableViewCell.m
//  TXChatTeacher
//
//  Created by lyt on 15/9/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CheckInTitleTableViewCell.h"
#import "UIView+Masonry.h"


@implementation CheckInTitleTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _cardNumberOrNickNameLabel.textColor = KColorTitleTxt;
    _cardNumberOrNickNameLabel.font = kFontSubTitle;
    
    _timeLabel.textColor = KColorTitleTxt;
    _timeLabel.font = kFontSubTitle;
    
    _statusLabel.textColor = KColorTitleTxt;
    _statusLabel.font = kFontSubTitle;
    
    CGFloat extraWidth = 30.0f;
    CGFloat avgWidth = (kScreenWidth - extraWidth)/3;
    [_cardNumberOrNickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0));
        make.height.mas_equalTo(self.contentView);
        make.top.mas_equalTo(@(0));
        make.width.mas_equalTo(avgWidth +extraWidth/2);
    }];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_cardNumberOrNickNameLabel.mas_right);
        make.height.mas_equalTo(self.contentView);
        make.top.mas_equalTo(@(0));
        make.width.mas_equalTo(avgWidth +extraWidth/2);
    }];
    [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_timeLabel.mas_right);
        make.height.mas_equalTo(self.contentView);
        make.top.mas_equalTo(@(0));
        make.width.mas_equalTo(avgWidth);
    }];
    
     __weak __typeof(&*self) weakSelf=self;  //by sck
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(0);
        make.right.mas_equalTo(weakSelf.contentView).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-kLineHeight);
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
