//
//  GroupDetailHeader.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "GroupDetailHeader.h"

@implementation GroupDetailHeader

//@property(nonatomic, strong)IBOutlet UIImageView *bkImage;
//@property(nonatomic, strong)IBOutlet UIImageView *headerImage;

-(void)awakeFromNib
{
    [super awakeFromNib];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [_bkImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf);
    }];
    _headerImage.contentMode = UIViewContentModeScaleAspectFill;
    _headerImage.clipsToBounds = YES;
    _headerImage.layer.cornerRadius = 4.0f/2.0f;
    _headerImage.layer.masksToBounds = YES;
    [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_bkImage).with.offset(0.0f);
        make.centerX.mas_equalTo(_bkImage);
        make.size.mas_equalTo(CGSizeMake(66.0f, 66.0f));
    }];
    _headerBK.layer.masksToBounds = YES;
    _headerBK.layer.cornerRadius = 4.0f/2.0f;
    [_headerBK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_headerImage.mas_left).with.offset(-1);
        make.top.mas_equalTo(_headerImage.mas_top).with.offset(-1);
        make.size.mas_equalTo(CGSizeMake(68.0f, 68.0f));
    }];
    
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
//GROUPDETAILHEADER_GROUP,
//GROUPDETAILHEADER_BABY,

-(void)setViewModel:(GROUPDETAILHEADER)model
{
    switch (model) {
        case GROUPDETAILHEADER_GROUP:
        {
//            [_name setHidden:NO];
//            [_babyNameLabel setHidden:YES];
//            [_babySexLabel setHidden:YES];
        }
            break;
        case GROUPDETAILHEADER_BABY:
        {
//            [_name setHidden:YES];
//            [_babyNameLabel setHidden:NO];
//            [_babySexLabel setHidden:NO];
        }
            break;
        default:
            break;
    }
}


@end
