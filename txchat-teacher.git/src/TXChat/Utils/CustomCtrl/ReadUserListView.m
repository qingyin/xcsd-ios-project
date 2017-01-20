//
//  ReadUserListView.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ReadUserListView.h"
#import "NotifyUserView.h"
#import "UIImageView+EMWebCache.h"
#import "NSString+Photo.h"
#import <SDiPhoneVersion.h>

@interface ReadUserListView()
{
    BOOL _isRead;
}

@property(nonatomic, strong)UIView *sepratorLine;
@property(nonatomic, strong)UILabel *countLabel;

@end

@implementation ReadUserListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isRead = YES;
    }
    return self;
}
-(id)initWithReadStatus:(BOOL)isRead
{
    self = [super init];
    if(self)
    {
        _isRead = isRead;
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
-(void)layoutSubviews
{
    [super layoutSubviews];
 
}

-(void)setupSubViews
{
    
    for(UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    CGFloat padding = kEdgeInsetsLeft;
//    if(_countLabel == nil)
    {
        _countLabel = [UILabel new];
        [_countLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_countLabel];
        if(_isRead)
        {
            [_countLabel setText:[NSString stringWithFormat:@"已读(%lu)", (unsigned long)[_userList count]]];
            [_countLabel setTextColor:kColorGray];
        }
        else
        {
            [_countLabel setText:[NSString stringWithFormat:@"未读(%lu)", (unsigned long)[_userList count]]];
            [_countLabel setTextColor:KColorAppMain];
        }
        [_countLabel setFont:kFontSmall];
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).with.offset(padding);
            make.top.mas_equalTo(weakSelf);
            make.size.mas_equalTo(CGSizeMake(200, 30));
        }];
    }
    
//    if(_sepratorLine == nil)
    {
        _sepratorLine = nil;
        _sepratorLine = [UIView new];
        [self addSubview:_sepratorLine];
        [_sepratorLine setBackgroundColor:kColorLine];
        __weak typeof(_countLabel) label = _countLabel;
        [_sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(label.mas_left).with.offset(0);
            make.top.mas_equalTo(label.mas_bottom).with.offset(1);
            make.height.mas_equalTo(kLineHeight);
            make.right.mas_equalTo(weakSelf).with.offset(0);
        }];
    }
    CGFloat scaleSize = 1.0;
    if ([SDiPhoneVersion deviceSize] == iPhone55inch)
    {
        scaleSize = 1.5;
    }
    //图片
    NotifyUserView *lastView = nil;
    CGFloat padding1 = 10.0f;
    CGFloat topPadding = 10.0f;
    CGFloat photoWidth = 70.0f;
    CGFloat photoHight = 70.0*scaleSize;
    NSInteger count = 4;
    CGFloat viewWidth = kScreenWidth;
    if((viewWidth - 2*kEdgeInsetsLeft)/(photoWidth+padding1)  > count)
    {
        count = (viewWidth - 2*kEdgeInsetsLeft)/(photoWidth+padding1);
        padding1 = (viewWidth - 2*kEdgeInsetsLeft - count*photoWidth)/(count -1);
    }
    else
    {
        padding1 = (viewWidth - 2*kEdgeInsetsLeft - count*photoWidth)/(count -1);
    }
    _countByLine = count;
    
    for(NSInteger index = 0; index < [_userList count]; index++)
    {
        TXPBNoticeMember *noticeMember = [_userList objectAtIndex:index];
        NotifyUserView *userView =  [[[NSBundle mainBundle] loadNibNamed:@"NotifyUserView" owner:self options:nil] objectAtIndex:0];
        [userView.headerImg TX_setImageWithURL:[NSURL URLWithString:[noticeMember.avatar getFormatPhotoUrl:photoWidth hight:photoHight]] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
        [userView setBackgroundColor:[UIColor clearColor]];
        [userView.nameLabel setText:noticeMember.nickname];
        [self addSubview:userView];
        //第一个
        if(lastView == nil)
        {
            __weak typeof(_sepratorLine) line = _sepratorLine;
            [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(line.mas_bottom).with.offset(topPadding);
                make.left.mas_equalTo(weakSelf.mas_left).with.offset(kEdgeInsetsLeft);
                make.size.mas_equalTo(CGSizeMake(photoWidth, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(weakSelf.mas_left).with.offset(kEdgeInsetsLeft );
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(topPadding);
                    make.size.mas_equalTo(CGSizeMake(photoWidth, photoHight));
                    
                }];
            }
            else//左排第2，3
            {
                [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.mas_right).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                    make.size.mas_equalTo(CGSizeMake(photoWidth, photoHight));
                    
                }];
            }
            
        }
        lastView = userView;
        
    }
    
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        if(lastView != nil)
//        {
//            make.bottom.mas_equalTo(lastView.mas_bottom).with.offset(topPadding);
//        }
//        else
//        {
//            make.bottom.mas_equalTo(_sepratorLine.mas_bottom).with.offset(topPadding);
//
//        }
//    }];
}



@end
