//
//  HomeWorkListTableViewCell.m
//  TXChatTeacher
//
//  Created by gaoju on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "HomeWorkListTableViewCell.h"
@implementation HomeWorkListTableViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    //分割线
    _lineView=UIView.new;
    _lineView.backgroundColor=kColorLine;
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, .5));
    }];
    //头像
    _avatarImage=UIImageView.new;
    //_avatarImage.image=[UIImage imageNamed:@"nav_mine_selected"];
    //    stateImage.backgroundColor=[UIColor redColor];
    [self.contentView addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).mas_offset(15);
        make.top.mas_equalTo(self.mas_top).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    _avatarImage.layer.masksToBounds=YES;
    _avatarImage.layer.cornerRadius=5;
    
    //班级
    _classLabel=UILabel.new ;
    //_classLabel.text=@"二年级三班";
    [self.contentView addSubview:_classLabel];
    [_classLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_avatarImage.mas_right).mas_offset(10);
        make.top.mas_equalTo(6);
        make.size.mas_equalTo(CGSizeMake(150, 35));
    }];
    _classLabel.font=[UIFont systemFontOfSize:16];
    
    //作业类型
    _homeWorkTypeLabel= UILabel.new;
    _homeWorkTypeLabel.text=@"定制学能作业";
    [self.contentView addSubview:_homeWorkTypeLabel];
    [_homeWorkTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_avatarImage.mas_right).mas_offset(10);
        make.top.mas_equalTo(_classLabel.mas_bottom).mas_offset(-10);
        make.size.mas_equalTo(CGSizeMake(150, 35));
    }];
    _homeWorkTypeLabel.font=[UIFont systemFontOfSize:14];
    [_homeWorkTypeLabel setTextColor:KColorNewSubTitleTxt];
    
    // 时间
    _timeLabel=UILabel.new;
    _timeLabel.text=@"";
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textAlignment=NSTextAlignmentRight;
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).mas_offset(-10);
        make.bottom.mas_equalTo(_classLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(150, 30));
    }];
    _timeLabel.font=[UIFont systemFontOfSize:13];
   [_timeLabel setTextColor:KColorNewSubTitleTxt];
    
    //作业数量
    _numberLabel=UILabel.new;
    _numberLabel.text=@"";
    _numberLabel.textAlignment=NSTextAlignmentRight;
    [self.contentView addSubview:_numberLabel];
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).mas_offset(-10);
        make.top.mas_equalTo(_timeLabel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    _numberLabel.font=[UIFont systemFontOfSize:13];
    [_numberLabel setTextColor:TimeColorTitleTxt];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
