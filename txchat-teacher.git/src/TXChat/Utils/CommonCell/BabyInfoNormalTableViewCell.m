//
//  BabyInfoNormalTableViewCell.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BabyInfoNormalTableViewCell.h"

#define KBaseColor  RGBCOLOR(0xff, 0x93, 0x3d)

@interface BabyInfoNormalTableViewCell()
{
    UIView *_beginView;
    UIView *_seperatorLine;
}
@end
@implementation BabyInfoNormalTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initViews];
    }
    return self;
}

-(void)initViews
{
    
    _beginView = [[UIView alloc] init];
    _beginView.backgroundColor = KColorAppMain;
    [self addSubview:_beginView];
    [_beginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(@(10*kScale1));
        make.width.mas_equalTo(@(2));
        make.height.mas_equalTo(@(14));
        make.centerY.mas_equalTo(self);
    }];
    
    _babyNameLabel = [[UILabel alloc] init];
    _babyNameLabel.textColor = KColorAppMain;
    _babyNameLabel.font = kFontLarge;
    [self addSubview:_babyNameLabel];
    [_babyNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_beginView.mas_right).with.offset(2*kScale1);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(14);
        make.centerY.mas_equalTo(self);
    }];
//    _seperatorLine = [[UIView alloc] init];
//    _seperatorLine.backgroundColor = kColorLine;
//    [self addSubview:_seperatorLine];
//    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(kLineHeight);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.top.mas_equalTo(0);
//    }];
//    [_seperatorLine setHidden:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
