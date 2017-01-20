//
//  UserListTableViewCell.m
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UserListTableViewCell.h"
#import "EMSDImageCache.h"
#import "UIImageView+EMWebCache.h"

@implementation UserListTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    
    WEAKSELF
    [_nameLabel setFont:kFontTitle];
    [_nameLabel setTextColor:KColorTitleTxt];
    [_seperatorLine setBackgroundColor:kColorLine];
    [_seperatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).with.offset(kEdgeInsetsLeft);
        make.right.mas_equalTo(weakSelf).with.offset(0);
        make.height.mas_equalTo(kLineHeight);
        make.top.mas_equalTo(weakSelf.mas_bottom).with.offset(-kLineHeight);
    }];
    
    [_rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).with.offset(-kEdgeInsetsLeft);
        make.centerY.mas_equalTo(weakSelf);
        make.size.mas_equalTo(_rightArrow.image.size);
        
    }];
    CGFloat margin = 10.0f;
    CGFloat headerWidth = 40.0f;
    [_header4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_rightArrow.mas_left).with.offset(-margin);
        make.size.mas_equalTo(CGSizeMake(headerWidth, headerWidth));
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [_header3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_header4.mas_left).with.offset(-margin);
        make.size.mas_equalTo(CGSizeMake(headerWidth, headerWidth));
        make.centerY.mas_equalTo(self.contentView);
    }];
    [_header2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_header3.mas_left).with.offset(-margin);
        make.size.mas_equalTo(CGSizeMake(headerWidth, headerWidth));
        make.centerY.mas_equalTo(self.contentView);
    }];
    [_header1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_header2.mas_left).with.offset(-margin);
        make.size.mas_equalTo(CGSizeMake(headerWidth, headerWidth));
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.contentView setBackgroundColor:kColorWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setHeaderList:(NSArray *)headerList
{
    [_header1 setHidden:YES];
    [_header2 setHidden:YES];
    [_header3 setHidden:YES];
    [_header4 setHidden:YES];
    _headerList = headerList;
    if(_headerList != nil && [_headerList count] > 0)
    {
        if([_headerList count] >= 1)
        {
            NSString *imageName = [_headerList objectAtIndex:0];
            [_header1 TX_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            [_header1 setHidden:NO];
            _header1.layer.cornerRadius = 8.0f/2.0f;
            _header1.layer.masksToBounds = YES;
        }
        if([_headerList count] >= 2)
        {
            NSString *imageName = [_headerList objectAtIndex:1];
            [_header2 TX_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            [_header2 setHidden:NO];
            _header2.layer.cornerRadius = 8.0f/2.0f;
            _header2.layer.masksToBounds = YES;
        }
        if([_headerList count] >= 3)
        {
            NSString *imageName = [_headerList objectAtIndex:2];
            [_header3 TX_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            [_header3 setHidden:NO];
            _header3.layer.cornerRadius = 8.0f/2.0f;
            _header3.layer.masksToBounds = YES;
        }
        if([_headerList count] >= 4)
        {
            NSString *imageName = [_headerList objectAtIndex:3];
            [_header4 TX_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
            [_header4 setHidden:NO];
            _header4.layer.cornerRadius = 8.0f/2.0f;
            _header4.layer.masksToBounds = YES;
        }
    }
}
@end
