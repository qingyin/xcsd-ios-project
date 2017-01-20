//
//  NotifyRcverTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NotifyRcverTableViewCell.h"

@implementation NotifyRcverTableViewCell

//@property(nonatomic, strong)IBOutlet UIImageView *groupIcon;
//@property(nonatomic, strong)IBOutlet UILabel *groupNamelLabel;
//@property(nonatomic, strong)IBOutlet UILabel *countLabel;
//@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;
//@property(nonatomic, strong)IBOutlet UIView *seperatorLine;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_groupNamelLabel setFont:kFontTitle];
    [_groupNamelLabel setTextColor:KColorTitleTxt];
    [_unreadLabel setFont:kFontSubTitle];
    [_unreadLabel setTextColor:kColorGray];
    [_countLabel setFont:kFontSubTitle];
    [_countLabel setTextColor:KColorAppMain];
    
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf.contentView).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-kLineHeight);
    }];
    
    [_rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.size.mas_equalTo(_rightArrow.image.size);
        
    }];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.right.mas_equalTo(_rightArrow.mas_left).with.offset(-kEdgeInsetsLeft);
    }];
    
    [_unreadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.contentView);
        make.right.mas_equalTo(_countLabel.mas_left).with.offset(-kEdgeInsetsLeft/2);
    }];
    
    [_groupNamelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_groupIcon.mas_right).with.offset(kEdgeInsetsLeft);
        make.centerY.mas_equalTo(weakSelf.contentView);
    }];
    
    _groupIcon.layer.masksToBounds = YES;
    _groupIcon.layer.cornerRadius = 8.0f/2.0f;
    
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
