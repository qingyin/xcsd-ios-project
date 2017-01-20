//
//  ParnentInfoTableViewCell.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ParnentInfoTableViewCell.h"
#define KHeaderImgViewWidth     40.0f
@interface ParnentInfoTableViewCell()
{
    UILabel *_invitedLabel;
    UIView *_seperatorLine;
}
@end

@implementation ParnentInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initViews];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)initViews
{
    _headerImgView = [[UIImageView alloc] init];
    _headerImgView.layer.masksToBounds = YES;
    _headerImgView.layer.cornerRadius = 8.0f/2;
    [self addSubview:_headerImgView];
    [_headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(KHeaderImgViewWidth);
        make.height.mas_equalTo(KHeaderImgViewWidth);
        make.left.mas_equalTo(10*kScale1);
        make.centerY.mas_equalTo(self);
    }];

    _parentNameLabel = [[UILabel alloc] init];
    _parentNameLabel.tintColor = RGBCOLOR(0x3a, 0x3a, 0x3a);
    _parentNameLabel.font = kFontLarge;
    [self addSubview:_parentNameLabel];
    
    _callBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_callBtn setImage:[UIImage imageNamed:@"icon_tel"] forState:UIControlStateNormal];
    [_callBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [self addSubview:_callBtn];
    [_callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-13*kScale1);
        make.size.mas_equalTo(CGSizeMake(42, 42));
        make.centerY.mas_equalTo(self);
    }];
    
    [_callBtn setHidden:YES];
    
    _inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _inviteBtn.userInteractionEnabled = YES;
    [self addSubview:_inviteBtn];
    
    UIView *borderView = [[UIView alloc] init];
    borderView.layer.masksToBounds = YES;
    borderView.layer.cornerRadius = 5.0f;
    borderView.layer.borderWidth = 1.0f;
    borderView.layer.borderColor = RGBCOLOR(0x49, 0x68, 0x77).CGColor;
    borderView.userInteractionEnabled= NO;
    [_inviteBtn addSubview:borderView];
    [borderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(_inviteBtn);
        make.height.mas_equalTo(23);
    }];
    
    
    UILabel *title = [[UILabel alloc] init];
    title.text = @"邀请";
    title.font = kFontSubTitle;
    title.textColor = RGBCOLOR(0x49, 0x68, 0x77);
    title.textAlignment = NSTextAlignmentRight;
    title.userInteractionEnabled = NO;
    [_inviteBtn addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(36);
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
    UIImageView *inviteIcon = [[UIImageView alloc] init];
    [inviteIcon setImage:[UIImage imageNamed:@"invite_icon"]];
    inviteIcon.userInteractionEnabled= NO;
    [_inviteBtn addSubview:inviteIcon];
    [inviteIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(title.mas_right).with.offset(1);
    }];
    
    [_parentNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImgView.mas_right).with.offset(10*kScale1);
        make.centerY.mas_equalTo(self.contentView);
        make.height.mas_equalTo(24*kScale1);
        //        make.width.mas_equalTo(200);
        make.right.mas_equalTo(_inviteBtn.mas_left);
    }];
    
    [_inviteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-20*kScale1);
//        make.size.mas_equalTo(CGSizeMake(62, 23));
//        make.centerY.mas_equalTo(self);
        make.top.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(62);
    }];
    
    _invitedLabel = [[UILabel alloc] init];
//    _invitedLabel.layer.masksToBounds = YES;
//    _invitedLabel.layer.cornerRadius = 5.0f;
//    _invitedLabel.layer.borderWidth = 1.0f;
//    _invitedLabel.layer.borderColor = RGBCOLOR(0xcd, 0xcd, 0xcd).CGColor;
    _invitedLabel.text = @"未激活";
    _invitedLabel.textAlignment = NSTextAlignmentCenter;
    _invitedLabel.textColor =  RGBCOLOR(0xcd, 0xcd, 0xcd);
    _invitedLabel.font = kFontSubTitle;
    [self addSubview:_invitedLabel];
    [_invitedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(62, 23));
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.mas_right).with.offset(-20*kScale1);
    }];
    
    _seperatorLine = [[UIView alloc] init];
    _seperatorLine.backgroundColor = RGBCOLOR(0xea, 0xea, 0xea);
    [self addSubview:_seperatorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kLineHeight);
        make.left.mas_equalTo(10*kScale1);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setParentStatusValue:(ParentStatus)parentStatusValue
{
    
    switch (parentStatusValue) {
        case ParentStatus_Actived: {
            [_callBtn setHidden:NO];
            [_invitedLabel setHidden:YES];
            [_inviteBtn setHidden:YES];
            break;
        }
        case ParentStatus_InActived: {
            [_callBtn setHidden:YES];
            [_invitedLabel setHidden:NO];
            [_inviteBtn setHidden:YES];
            break;
        }
        case ParentStatus_Invited: {
            [_callBtn setHidden:YES];
            [_invitedLabel setHidden:NO];
            [_inviteBtn setHidden:YES];
            break;
        }
        case ParentStatus_NoCallNumber: {
            [_callBtn setHidden:YES];
            [_invitedLabel setHidden:YES];
            [_inviteBtn setHidden:YES];
            break;
        }
        default: {
            break;
        }
    }
}


@end
