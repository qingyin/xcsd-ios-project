//
//  AttendanceUICollectionViewCell.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "AttendanceUICollectionViewCell.h"

@implementation AttendanceUICollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupViews];
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


-(void)setupViews
{
    _nameLabel = [UILabel new];
    [self addSubview:_nameLabel];
    _headerImage = [UIImageView new];
    _headerImage.layer.cornerRadius = 10.0f/2;
    _headerImage.layer.masksToBounds = YES;
    [_headerImage setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_headerImage];
    
    _selectedImageView = [UIImageView new];
    [_selectedImageView setImage:[UIImage imageNamed:@"attendance_selected"]];
    CGFloat delWidth = _selectedImageView.image.size.width/2.0f;
    [self addSubview:_selectedImageView];
    
    [_nameLabel setFont:kFontChildSection];
    [_nameLabel setTextColor:KColorSubTitleTxt];
    [_nameLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(_headerImage.mas_bottom).with.offset(9);
    }];
    
    [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).with.offset(20);
        make.size.mas_equalTo(CGSizeMake(54.0f, 54.0f));
    }];
    
    [_selectedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_headerImage.mas_bottom).with.offset(-(delWidth+2));
        make.left.mas_equalTo(_headerImage.mas_right).with.offset(-(delWidth+2));
//        make.left.mas_equalTo(_headerImage.mas_right);
        make.size.mas_equalTo(_selectedImageView.image.size);
    }];
    [_selectedImageView setHidden:YES];
}


//更新选中状态
-(void)updateSelectedStatus:(BOOL)selectedStatus
{
    [_selectedImageView setHidden:!selectedStatus];
}



@end
