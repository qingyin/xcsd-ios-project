//
//  HomeWorkTypeTableViewCell.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkTypeTableViewCell.h"

@implementation HomeWorkTypeTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
       //分割线
    _lineView=UIView.new;
    _lineView.backgroundColor=kColorLine;
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, .5));
    }];

    
    _homeWorkTypeLabel=[UILabel new];
    [self.contentView addSubview:_homeWorkTypeLabel];
    [_homeWorkTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    _homeWorkTypeLabel.font=[UIFont systemFontOfSize:16];
    
    _stateLabel=[UILabel new];
    [self.contentView addSubview:_stateLabel];
    [_stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(120, 30));
    }];
     _stateLabel.font=[UIFont systemFontOfSize:16];
    _stateLabel.textColor=[UIColor colorWithRed:255/255.0 green:150/255.0 blue:37/255.0 alpha:1];

    
    _homeWorkBriefLabel=[UILabel new];
    [self.contentView addSubview:_homeWorkBriefLabel];
    _homeWorkBriefLabel.numberOfLines=2;
    [_homeWorkBriefLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(_homeWorkTypeLabel.mas_bottom).mas_offset(-10);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(60);
    }];
    _homeWorkBriefLabel.font=[UIFont systemFontOfSize:14];
    [_homeWorkBriefLabel setTextColor:KColorNewSubTitleTxt];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
