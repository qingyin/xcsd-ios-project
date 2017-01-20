//
//  BabyDetailTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BabyDetailTableViewCell.h"

@implementation BabyDetailTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_nameLabel setFont:kFontTitle];
    [_nameLabel setTextColor:KColorTitleTxt];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
    }];
    
    [_rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(weakSelf);
        make.size.mas_equalTo(_rightArrow.image.size);
        
    }];
    
    CGFloat imageWidth = 40.0f;
    
    [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf);
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
    }];
    [_headerMaskImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_headerImage);
        make.left.mas_equalTo(_headerImage);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageWidth));
    }];
    [self.contentView setBackgroundColor:kColorWhite];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
