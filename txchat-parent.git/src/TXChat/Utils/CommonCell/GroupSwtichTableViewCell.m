//
//  GroupSwtichTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "GroupSwtichTableViewCell.h"

@implementation GroupSwtichTableViewCell


- (void)awakeFromNib
{
    // Initialization code
    [_nameLabel setFont:kFontTitle];
    [_nameLabel setTextColor:KColorTitleTxt];
    WEAKSELF
    CGFloat padding = (weakSelf.frame.size.height - 31.0f)/2.0f;
    [_sw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.mas_right).with.offset(-kEdgeInsetsLeft);
        make.size.mas_equalTo(CGSizeMake(51, 31));
        make.top.mas_equalTo(weakSelf).with.offset(padding);
    }];
    _switchValueChanged = nil;
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_sw setOnTintColor:KColorAppMain];
}

-(void)switchAction:(id)sender
{
    if(_switchValueChanged)
    {
        _switchValueChanged(sender);
    }
}


@end
