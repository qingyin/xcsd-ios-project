//
//  MuteCollectionViewCell.m
//  TXChat
//
//  Created by lyt on 15/7/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MuteCollectionViewCell.h"

@implementation MuteCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupViews];
    }
    return self;
}


-(void)setupViews
{
    _nameLabel = [UILabel new];
    [self addSubview:_nameLabel];
    _headerImage = [UIImageView new];
    _headerImage.layer.cornerRadius = 40.0f/2;
    _headerImage.layer.masksToBounds = YES;
    [_headerImage setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_headerImage];

    _delImageView = [UIImageView new];
    [_delImageView setImage:[UIImage imageNamed:@"deteleIdentifier"]];
    CGFloat delWidth = _delImageView.image.size.width/2.0f;
    [self addSubview:_delImageView];
    
    [_nameLabel setFont:kFontTimeTitle];
    [_nameLabel setTextColor:KColorSubTitleTxt];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(_headerImage.mas_bottom).with.offset(4);
    }];
    
    [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40.0f, 40.0f));
    }];
    
    [_delImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_headerImage.mas_top).with.offset(0);
        make.left.mas_equalTo(_headerImage.mas_left).with.offset(-(delWidth/2+2));
        make.size.mas_equalTo(_delImageView.image.size);
    }];
    [_delImageView setHidden:YES];
}


-(void)updateDelStatus:(BOOL)delStatus
{
    [_delImageView setHidden:!delStatus];
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
