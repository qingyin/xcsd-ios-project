//
//  NotifyTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NotifyTableViewCell.h"
//时间距top的margin
#define KTIMETOPMARGIN 10.0f

@implementation NotifyTableViewCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_toUserLabel setTextColor:KColorNewTitleTxt];
    [_toUserLabel setFont:kFontTitle];
    [_toUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(KCellTitleLeft);
        make.top.mas_equalTo(_fromHeader.mas_top).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(200, 21));
        
    }];
    [_messageLabel setTextColor:KColorNewSubTitleTxt];
    [_messageLabel setFont:kFontSubTitle];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_toUserLabel);
        make.top.mas_equalTo(_toUserLabel.mas_bottom).with.offset(-3.0f);
        make.height.mas_equalTo(21.0f);
        make.right.mas_equalTo(weakSelf.contentView).with.offset(-2*kEdgeInsetsLeft);
    }];
    [_timeLabel setTextColor:KColorNewTimeTxt];
    [_timeLabel setFont:kFontTimeTitle];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(_toUserLabel.mas_top);
    }];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf.contentView).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-kLineHeight);
    }];
    _fromHeader.layer.cornerRadius = 8.0f/2.0f;
    _fromHeader.layer.masksToBounds = YES;
    [_fromHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.left.mas_equalTo(kEdgeInsetsLeft);
        make.size.mas_equalTo(CGSizeMake(40, 40));        
    }];
    

    [self.contentView bringSubviewToFront:_unreadImage];
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
