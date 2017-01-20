//
//  MedicineTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MedicineTableViewCell.h"

@implementation MedicineTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    [_contentLabel setFont:kFontSubTitle];
    [_contentLabel setTextColor:KColorSubTitleTxt];
    _contentLabel.numberOfLines = 2;
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(60.0f);
        make.top.mas_equalTo(self.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(41.0f);
    }];
    [_timeLabel setFont:kFontSmall];
    [_timeLabel setTextColor:kColorGray];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(110, 21));
        
    }];
    [_timeLabel setHidden:YES];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(self.contentView).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(self.contentView.mas_bottom).with.offset(-kLineHeight);
    }];
    _headerImageview.layer.masksToBounds = YES;
    _headerImageview.layer.cornerRadius = 8.0f/2.0f;
    [_headerImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset(kEdgeInsetsLeft);
        make.top.mas_equalTo(self.contentView).with.offset(kEdgeInsetsLeft);
        make.bottom.mas_equalTo(self.contentView).with.offset(-kEdgeInsetsLeft);
        make.width.mas_equalTo(_headerImageview.mas_height);
    }];
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
