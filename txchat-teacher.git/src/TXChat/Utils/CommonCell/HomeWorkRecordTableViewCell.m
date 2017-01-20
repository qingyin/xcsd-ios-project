//
//  HomeWorkRecordTableViewCell.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/30.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkRecordTableViewCell.h"

@implementation HomeWorkRecordTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    //分割线
    _lineView=[[UIView alloc]init];
    _lineView.backgroundColor=kColorLine;
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, .5));
    }];
    //头像
    _avatarImage=[[UIImageView alloc]init];
    _avatarImage.image=[UIImage imageNamed:@"attendance_defaultHeader"];
    [self.contentView addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).mas_offset(15);
        make.top.mas_equalTo(self.mas_top).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    _avatarImage.layer.masksToBounds=YES;
    _avatarImage.layer.cornerRadius=5;
    
    //用户名
    _childNameLabel=UILabel.new ;
    _childNameLabel.text=@"";
    [self.contentView addSubview:_childNameLabel];
    [_childNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_avatarImage.mas_right).mas_offset(15);
        make.top.mas_equalTo(_avatarImage.centerY).mas_offset(13);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    _childNameLabel.font=[UIFont systemFontOfSize:18];
    
    _markImage=[UIImageView new];
    [self.contentView addSubview:_markImage];
    //_markImage.image=[UIImage imageNamed:@"hw_keysymbol_s"];
    [_markImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_avatarImage.mas_bottom).mas_offset(5);
        make.right.mas_equalTo(_avatarImage.mas_right).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
       //分数
    _scoreLabel=UILabel.new ;
    _scoreLabel.text=@"";
    [self.contentView addSubview:_scoreLabel];
    [_scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).mas_offset(-15);
        make.top.mas_equalTo(_avatarImage.centerY).mas_offset(13);
        make.size.mas_equalTo(CGSizeMake(60, 40));
    }];
    
    _scoreLabel.font=[UIFont systemFontOfSize:16];
    _scoreLabel.textColor=[UIColor colorWithRed:255/255.0 green:150/255.0 blue:37/255.0 alpha:1];
    _staticStringLabel=[UILabel new];
    _staticStringLabel.text=@"";
    [self.contentView addSubview:_staticStringLabel];
    [_staticStringLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-10);
        make.top.mas_equalTo(_avatarImage.centerY).mas_offset(13);
        make.size.mas_equalTo(CGSizeMake(120, 40));
    }];
//    [_staticStringLabel setTextColor:KColorNewSubTitleTxt];
    _staticStringLabel.font=[UIFont systemFontOfSize:15];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
