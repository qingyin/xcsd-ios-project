//
//  LeaveDetailTableViewCell.m
//  TXChatParent
//
//  Created by lyt on 15/11/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "LeaveDetailTableViewCell.h"

@implementation LeaveDetailTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.contentView.backgroundColor = kColorClear;
    self.backgroundColor = kColorClear;
    _leaveBgView.layer.cornerRadius = 6.0f/2;
    _leaveBgView.layer.masksToBounds = YES;
    _leaveBgView.layer.borderWidth = 0.5f;
    _leaveBgView.layer.borderColor = RGBCOLOR(0xcc, 0xcc, 0xcc).CGColor;
    
    [_leaveBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).with.offset(8);
        make.right.mas_equalTo(self.contentView.mas_right).with.offset(-8);
        make.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView.mas_top).with.offset(10);
    }];
    
    [_leaveReasonLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_leaveTimeLabel.mas_left).with.offset(-10);
        make.left.mas_equalTo(_leaveTypeLabel.mas_right).with.offset(6);
        make.centerY.mas_equalTo(_leaveTypeLabel);
    }];
    
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = 8.0f/2;
    [_headerImageView setImage:[UIImage imageNamed:@"userDefaultIcon"]];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_leaveBgView);
        make.left.mas_equalTo(_leaveBgView.mas_left).with.offset(8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    _leaveTypeLabel.textColor = kColorWhite;
    _leaveTypeLabel.layer.cornerRadius = 3.0f/2;
    _leaveTypeLabel.layer.masksToBounds = YES;
    [_leaveTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_leaveReasonTitleLabel);
        make.left.mas_equalTo(_leaveReasonTitleLabel.mas_right).with.offset(6);
        make.width.mas_equalTo(@(36));
    }];
    
    [_leaveCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_leaveTypeLabel.mas_left);
        make.centerY.mas_equalTo(_leaveTimeTitleLabel);
    }];
    
    [_leaveTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(_leaveBgView.mas_right).with.offset(-10);
        make.centerY.mas_equalTo(_leaveReasonLabel);
        make.width.greaterThanOrEqualTo(@(50));
    }];
    _leaveResultLabel.font = kFontSmall;

    [_leaveResultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_leaveBgView.mas_right).with.offset(-10);
        make.centerY.mas_equalTo(_leaveTimeTitleLabel);
    }];
    
    [_leaveReasonTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImageView.mas_right).with.offset(8);
        make.top.mas_equalTo(_leaveBgView.mas_top).with.offset(18);
        make.width.mas_equalTo(@(36));
    }];
    [_leaveTimeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_leaveReasonTitleLabel);
        make.top.mas_equalTo(_leaveReasonTitleLabel.mas_bottom).with.offset(3);
    }];
    
    
    
    self.leaveType = TXPBLeaveTypeSck;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setLeaveType:(TXPBLeaveType)leaveType
{
    switch (leaveType) {
        case TXPBLeaveTypeSck: {
            {
                _leaveTypeLabel.text = @"病假";
                _leaveTypeLabel.backgroundColor = RGBCOLOR(0xff, 0x9c, 0xbf);
            }
            break;
        }
        case TXPBLeaveTypeUnp: {
            {
                _leaveTypeLabel.text = @"事假";
                _leaveTypeLabel.backgroundColor = RGBCOLOR(0xcb, 0x9c, 0xff);
            }
            break;
        }
        default: {
            break;
        }
    }

}


-(void)setResolvedStatus:(TXPBLeaveStatus)resolvedStatus
{
    switch (resolvedStatus) {
        case TXPBLeaveStatusApplied: {
            {
                _leaveResultLabel.text = @"待处理";
                _leaveResultLabel.textColor = RGBCOLOR(0xff, 0x5d, 0x5d);
            }
            break;
        }
        case TXPBLeaveStatusApproved: {
            {
                _leaveResultLabel.text = @"已处理";
                _leaveResultLabel.textColor = RGBCOLOR(0x66, 0x66, 0x66);
            }
            break;
        }
        default: {
            break;
        }
    }
}


@end
