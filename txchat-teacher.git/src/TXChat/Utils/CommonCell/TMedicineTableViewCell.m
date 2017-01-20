//
//  TMedicineTableViewCell.m
//  TXChat
//
//  Created by lyt on 15/7/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TMedicineTableViewCell.h"

@implementation TMedicineTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_fromLabel setFont:kFontTitle];
    [_fromLabel setTextColor:KColorTitleTxt];
    _fromLabel.numberOfLines = 1;
    [_fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImageview.mas_right).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(_headerImageview.mas_top).with.offset(1.0f);
        make.right.mas_equalTo(self.mas_right).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(21.0f);
    }];
    
    [_contentLabel setFont:kFontSubTitle];
    [_contentLabel setTextColor:KColorSubTitleTxt];
    _contentLabel.numberOfLines = 1;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImageview.mas_right).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(_fromLabel.mas_bottom).with.offset(-0.0f);
        make.right.mas_equalTo(self.mas_right).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(18.0f);
    }];
    [_timeLabel setFont:kFontTimeTitle];
    [_timeLabel setTextColor:KColorSubTitleTxt];
    [_timeLabel setTextAlignment:NSTextAlignmentRight];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(_fromLabel);
        make.size.mas_equalTo(CGSizeMake(110, 21));
        
    }];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(self).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(self.mas_bottom).with.offset(-kLineHeight);
    }];
    _headerImageview.layer.cornerRadius = 8.0f/2.0f;
    _headerImageview.layer.masksToBounds = YES;
    [_headerImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).with.offset(kEdgeInsetsLeft);
        make.width.mas_equalTo(_headerImageview.mas_height);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.mas_equalTo(self.contentView);
    }];
    CGFloat unreadImageViewWidth = 10.0f;
    [_unreadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImageview.mas_right).with.offset(-unreadImageViewWidth/2.0f);
        make.bottom.mas_equalTo(_headerImageview.mas_top).with.offset(unreadImageViewWidth/2.0f);
        make.size.mas_equalTo(CGSizeMake(unreadImageViewWidth, unreadImageViewWidth));
    }];
    
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
