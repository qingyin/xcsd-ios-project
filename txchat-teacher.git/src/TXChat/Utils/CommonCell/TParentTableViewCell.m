//
//  TParentTableViewCell.m
//  TXChat
//
//  Created by lyt on 15/7/22.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TParentTableViewCell.h"

@implementation TParentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_userNameLabel setFont:kFontTitle];
    [_userNameLabel setTextColor:KColorTitleTxt];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_userImageView.mas_right).with.offset(kEdgeInsetsLeft);
        make.centerY.mas_equalTo(self.contentView);
    }];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf.contentView).with.offset(-kEdgeInsetsLeft);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-kLineHeight);
    }];
    
    [_callButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-5);
        make.centerY.mas_equalTo(@(0));
        make.width.mas_equalTo(@(44));
    }];
    _callBlock = nil;
    [_inActiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_callButton.mas_left).with.offset(0);
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.width.mas_equalTo(@(44));
    }];

    [_inActiveBtn setTitleColor:KColorSubTitleTxt forState:UIControlStateNormal];
    _inActiveBtn.hidden = YES;
    _userImageView.layer.cornerRadius = 8.0f/2.0f;
    _userImageView.layer.masksToBounds = YES;
    _userImageView.contentMode = UIViewContentModeScaleAspectFill;
    _userImageView.clipsToBounds = YES;
    [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(@(kEdgeInsetsLeft));
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)callButton:(id)sender
{
    if(_callBlock)
    {
        _callBlock(self.tag);
    }
}

@end
