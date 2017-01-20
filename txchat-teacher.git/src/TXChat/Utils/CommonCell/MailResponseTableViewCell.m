//
//  MailResponseTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MailResponseTableViewCell.h"

@implementation MailResponseTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_fromLabel setFont:kFontTitle];
    [_fromLabel setTextColor:KColorTitleTxt];
    [_contentLabel setFont:kFontSubTitle];
    [_contentLabel setTextColor:KColorSubTitleTxt];
    _contentLabel.numberOfLines = 0;

    
    [_timeLabel setFont:kFontTimeTitle];
    [_timeLabel setTextColor:KColorSubTitleTxt];
    [_timeLabel setTextAlignment:NSTextAlignmentRight];
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
    _headerImageview.layer.masksToBounds = YES;
    _headerImageview.layer.cornerRadius = 8.0f/2.0f;
    [_headerImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(self).with.offset(kEdgeInsetsLeft/2+1.5);
        make.size.mas_equalTo(CGSizeMake(40.0f, 40.0f));
    }];
    
    [_fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImageview.mas_right).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(_headerImageview.mas_top).with.offset(1.0f);
    }];
    [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).with.offset(60.f);
        make.right.mas_equalTo(self.mas_right).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(_fromLabel.mas_bottom).with.offset(1.5f);
    }];
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
