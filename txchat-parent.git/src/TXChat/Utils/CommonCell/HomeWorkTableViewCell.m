//
//  NotifyTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-8.
//  Copyright (c) 2015年 yi.meng. All rights reserved.
//

#import "HomeWorkTableViewCell.h"
//时间距top的margin
#define KTIMETOPMARGIN 10.0f

@implementation HomeWorkTableViewCell
- (void)awakeFromNib
{
    // Initialization code
    WEAKSELF
    _lineView.backgroundColor=kColorLine;
    //分割线
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(weakSelf.contentView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, .5));
    }];
    
    //老师
    [_toUserLabel setTextColor:KColorTitleTxt];
    [_toUserLabel setFont:kFontSmall];
    [_toUserLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(KCellTitleLeft-45);
        make.top.mas_equalTo(weakSelf.contentView).with.offset(KCellTitleTop);
        make.size.mas_equalTo(CGSizeMake(100, 21));
    }];
    
    [_unreadImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(2);
       // make.top.mas_equalTo(_toUserLabel.mas_top);
        make.top.mas_equalTo(_toUserLabel.centerY);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    
    }];
    
//   // 布置
//    _arrangeLabel.text=@"布置";
//    [_arrangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(_toUserLabel.mas_right);
//        make.top.mas_equalTo(_toUserLabel);
//        make.size.mas_equalTo(CGSizeMake(40, 21));
//    }];
    
    //to
    [_toLabel setTextColor:uColor];
    [_toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.contentView).with.offset(KCellTitleLeft-47);
        make.top.mas_equalTo(_toUserLabel.mas_bottom).with.offset(6);
        make.size.mas_equalTo(CGSizeMake(36, 21));
    }];
    
    //user
    [_userLabel setTextColor:uColor];
    [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_toLabel.mas_right);
        make.top.mas_equalTo(_toUserLabel.mas_bottom).with.offset(6);
        make.size.mas_equalTo(CGSizeMake(60, 21));
    }];

    
        //状态
    
    [_stateImage setImage:[UIImage imageNamed:@"LearnWork_page_Todo"]];
//    
//    [_unreadImage setImage:[UIImage imageNamed:@"LearnWork_page_HaveToDo"]];
    
    [_stateImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.contentView).with.offset(-kEdgeInsetsLeft);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(57/2, 62/2));
    }];
    
    // 时间
    [_timeLabel setTextColor:KColorNewTimeTxt];
    [_timeLabel setFont:kFontTimeTitle];
    _timeLabel.textAlignment=NSTextAlignmentRight;
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_toUserLabel.mas_bottom).with.offset(6);
//      make.left.mas_equalTo(_messageLabel.mas_right).with.offset(10);
        make.right.mas_equalTo(_stateImage.mas_right);
        make.size.mas_equalTo(CGSizeMake(90, 21));
    }];
 
    //详情
    [_messageLabel setTextColor:KColorNewSubTitleTxt];
    //[_messageLabel setFont:kFontSubTitle];
    [_messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_userLabel.mas_right);
        make.top.mas_equalTo(_userLabel.mas_top);
        make.right.mas_equalTo(_timeLabel.mas_left);
        make.height.mas_equalTo(21);
    }];

    
    
//    [_seperatorLine setBackgroundColor:kColorLine];
//    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf.contentView).with.offset(kEdgeInsetsLeft);
//        make.right.mas_equalTo(weakSelf.contentView).with.offset(0);
//        make.height.mas_equalTo(kLineHeight);
//        make.top.mas_equalTo(weakSelf.contentView.mas_bottom).with.offset(-kLineHeight);
//    }];
//
//    [_fromHeader mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.mas_equalTo(weakSelf.contentView);
//        make.left.mas_equalTo(kEdgeInsetsLeft);
//        make.size.mas_equalTo(CGSizeMake(40, 40));
//    }];
//    
//    _fromHeader.layer.cornerRadius = 8.0f/2.0f;
//    _fromHeader.layer.masksToBounds = YES;
//
//    [self.contentView bringSubviewToFront:_unreadImage];
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
