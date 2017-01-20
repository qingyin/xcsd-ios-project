//
//  HomeWorkRecordCell.m
//  TXChatParent
//
//  Created by gaoju on 16/3/8.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkRecordCell.h"

@implementation HomeWorkRecordCell

- (void)awakeFromNib {
      //分割线
    _lineView=UIView.new ;
    _lineView.backgroundColor=kColorLine;
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, .5));
    }];
    //头像
    _stateImage=UIImageView.new;
 //   _stateImage.image=[UIImage imageNamed:@"nav_mine_selected"];
//    stateImage.backgroundColor=[UIColor redColor];
    [self.contentView addSubview:_stateImage];
    [_stateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).mas_offset(15);
        make.top.mas_equalTo(self.mas_top).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    _stateImage.layer.masksToBounds=YES;
    _stateImage.layer.cornerRadius=5;
    //用户名
     _userNameLabel=UILabel.new ;
    _userNameLabel.text=@"";
    [self.contentView addSubview:_userNameLabel];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_stateImage.mas_right).mas_offset(15);
        make.top.mas_equalTo(_stateImage.centerY).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    _userNameLabel.font=[UIFont systemFontOfSize:18];
    //分数
    _scoreLabel=UILabel.new ;
    _scoreLabel.text=@"";
    [self.contentView addSubview:_scoreLabel];
    [_scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).mas_offset(-10);
        make.top.mas_equalTo(_stateImage.centerY).mas_offset(15);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    _scoreLabel.textAlignment=NSTextAlignmentRight;

    _scoreLabel.textColor=[UIColor colorWithRed:255/255.0 green:150/255.0 blue:37/255.0 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
