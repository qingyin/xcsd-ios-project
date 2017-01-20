//
//  LeavesTableViewCell.m
//  TXChatTeacher
//
//  Created by Cloud on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "LeavesTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"


@interface LeavesTableViewCell ()
{
    UIView *_detailView;
    UIImageView *_photoView;
    UILabel *_nameLb;
    UILabel *_timeLb;
    UILabel *_reasonTitleLb;
    UILabel *_typeLb;
    UILabel *_reasonLb;
    UILabel *_stateLb;
    UILabel *_numTitleLb;
    UILabel *_numLb;
}

@end


@implementation LeavesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorBackground;
        self.contentView.backgroundColor = kColorBackground;
        
        _detailView = [[UIView alloc] initWithFrame:CGRectZero];
        _detailView.backgroundColor = kColorWhite;
        _detailView.layer.cornerRadius = 5.f;
        _detailView.layer.borderColor = kColorLine.CGColor;
        _detailView.layer.borderWidth = kLineHeight;
        [self.contentView addSubview:_detailView];
        
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.layer.cornerRadius = 8.0/2.0f;
        _photoView.layer.masksToBounds = YES;
        [_detailView addSubview:_photoView];
        
        [_photoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8 * kScale);
            make.top.mas_equalTo(15 * kScale);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);
        }];
        
        _nameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _nameLb.font = kFontMiddle_b;
        _nameLb.textColor = kColorBlack;
        [_detailView addSubview:_nameLb];
        [_nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_photoView.mas_right).offset(7 * kScale);
            make.top.mas_equalTo(_photoView.mas_top).offset(7 * kScale);
        }];
        
        _timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _timeLb.font = kFontSmall;
        _timeLb.textColor = RGBCOLOR(0x66, 0x66, 0x66);
        [_detailView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10 * kScale);
            make.centerY.mas_equalTo(_nameLb.mas_centerY);
        }];
        
        _reasonTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _reasonTitleLb.font = kFontMiddle;
        _reasonTitleLb.textColor = kColorBlack;
        _reasonTitleLb.text = @"原因:";
        [_reasonTitleLb sizeToFit];
        [_detailView addSubview:_reasonTitleLb];
        [_reasonTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLb.mas_left);
            make.top.mas_equalTo(_nameLb.mas_bottom).offset(10 * kScale);
            make.width.mas_equalTo(_reasonTitleLb.width_);
            make.height.mas_equalTo(_reasonTitleLb.height_);
        }];
        
        _typeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _typeLb.layer.cornerRadius = 5.0/2;
        _typeLb.layer.masksToBounds = YES;
        _typeLb.font = kFontMiddle;
        _typeLb.textAlignment = NSTextAlignmentCenter;
        _typeLb.textColor = kColorWhite;
        _typeLb.text = @"病假";
        [_detailView addSubview:_typeLb];
        [_typeLb sizeToFit];
        [_typeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_reasonTitleLb.mas_right).offset(6 * kScale);
            make.width.mas_equalTo(_typeLb.width_ + 8 * kScale);
            make.height.mas_equalTo(_typeLb.height_ + 4 * kScale);
            make.centerY.mas_equalTo(_reasonTitleLb.mas_centerY);
        }];
        
        _reasonLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _reasonLb.font = kFontMiddle;
        _reasonLb.lineBreakMode = NSLineBreakByTruncatingTail;
        _reasonLb.textColor = kColorGray;
        [_detailView addSubview:_reasonLb];
        
        _stateLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _stateLb.font = kFontMiddle;
        _stateLb.text = @"已处理";
        [_detailView addSubview:_stateLb];
        [_stateLb sizeToFit];
        
        [_reasonLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_typeLb.mas_right).offset(6 * kScale);
            make.centerY.mas_equalTo(_typeLb.mas_centerY);
            make.right.mas_equalTo(_stateLb.mas_left).offset(-5 * kScale);
            make.height.mas_equalTo(_reasonTitleLb.height_);
        }];
        
        [_stateLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_timeLb.mas_right);
            make.centerY.mas_equalTo(_reasonLb.mas_centerY);
            make.height.mas_equalTo(_stateLb.height_);
            make.width.mas_equalTo(_stateLb.width_);
        }];
        
        _numTitleLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _numTitleLb.font = kFontMiddle;
        _numTitleLb.textColor = RGBCOLOR(0x66, 0x66, 0x66);
        _numTitleLb.text = @"天数:";
        [_detailView addSubview:_numTitleLb];
        [_numTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLb.mas_left);
            make.top.mas_equalTo(_reasonTitleLb.mas_bottom).offset(6 * kScale);
            make.width.mas_equalTo(_reasonTitleLb.width_);
            make.height.mas_equalTo(_reasonTitleLb.height_);
        }];
        
        _numLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _numLb.font = kFontMiddle;
        _numLb.lineBreakMode = NSLineBreakByTruncatingTail;
        _numLb.textColor = RGBCOLOR(0x66, 0x66, 0x66);
        [_detailView addSubview:_numLb];
        [_numLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_numTitleLb.mas_right).offset(6 * kScale);
            make.centerY.mas_equalTo(_numTitleLb.mas_centerY);
            make.right.mas_equalTo(_timeLb.mas_left).offset(-5 * kScale);
            make.height.mas_equalTo(_reasonTitleLb.height_);
        }];
        
        [_detailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8 * kScale);
            make.right.mas_equalTo(-8 * kScale);
            make.top.mas_equalTo(10 * kScale);
            make.bottom.mas_equalTo(_numLb.mas_bottom).offset(18 * kScale);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(kScreenWidth);
            make.bottom.mas_equalTo(_detailView.mas_bottom);
        }];
        
    }
    return self;
}

- (void)setLeave:(TXPBLeave *)leave{

    _leave = leave;
    
    NSString *imgStr = [leave.userAvatar getFormatPhotoUrl:80 hight:80];
    [_photoView TX_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    

    _nameLb.text = leave.applyUserName;
    [_nameLb sizeToFit];
    [_nameLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_nameLb.width_);
        make.height.mas_equalTo(_nameLb.height_);
    }];
    
    _timeLb.text = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(leave.createdOn/1000)]];
    [_timeLb sizeToFit];
    [_timeLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_timeLb.width_);
        make.height.mas_equalTo(_timeLb.height_);
    }];
    
    _typeLb.backgroundColor = leave.leaveType == TXPBLeaveTypeSck?RGBCOLOR(255, 156, 191):RGBCOLOR(203, 156, 255);
    _typeLb.text = leave.leaveType == TXPBLeaveTypeSck?@"病假":@"事假";

    _reasonLb.text = leave.reason;

    _stateLb.text = [leave.isCompleted boolValue]?@"已处理":@"待处理";
    _stateLb.textColor = [leave.isCompleted boolValue]?kColorGray:RGBCOLOR(255, 93, 93);
    
    _numLb.text = [NSString stringWithFormat:@"%0.1f天",leave.days];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
