//
//  NotifyUserView.m
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NotifyUserView.h"
#import <SDiPhoneVersion.h>

@implementation NotifyUserView
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    CGFloat scaleSize = 1.0;
    if ([SDiPhoneVersion deviceSize] == iPhone55inch)
    {
        scaleSize = 1.5;
    }
    
    CGFloat imgSize = 40.0f;    
    [_nameLabel setFont:kFontSmall];
    [_nameLabel setTextColor:kColorBlack];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [_headerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(imgSize*scaleSize, imgSize*scaleSize));
    }];
    
    _headerImg.layer.cornerRadius =8.0/2.0f;
    _headerImg.layer.masksToBounds = YES;
    
    [_labelBase mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(_headerImg.mas_bottom);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    

    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if([SDiPhoneVersion deviceSize] == iPhone55inch)
        {
            make.centerY.mas_equalTo(_labelBase).with.offset(-3);
        }
        else
        {
            make.centerY.mas_equalTo(_labelBase);
        }
        make.centerX.mas_equalTo(_labelBase);
        make.left.mas_equalTo(_labelBase);
        make.right.mas_equalTo(_labelBase);
    }];
}







-(void)updateConstraints
{
    [super updateConstraints];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
