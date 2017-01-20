//
//  ReadUserListView.m
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "ReadUserListView.h"
#import "NotifyUserView.h"

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
    WEAKSELF
    CGFloat padding = 15.0f;
    if(_countLabel == nil)
    {
        _countLabel = [UILabel new];
        [_countLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_countLabel];
        if(_isRead)
        {
            [_countLabel setText:[NSString stringWithFormat:@"已读(%lu)", (unsigned long)[_userList count]]];
            [_countLabel setTextColor:[UIColor grayColor]];
        }
        else
        {
            [_countLabel setText:[NSString stringWithFormat:@"未读(%lu)", (unsigned long)[_userList count]]];
            [_countLabel setTextColor:[UIColor redColor]];
        }
        [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).with.offset(padding);
            make.top.mas_equalTo(weakSelf);
            make.size.mas_equalTo(CGSizeMake(200, 30));
        }];
    }
    
    if(_sepratorLine == nil)
    {
        _sepratorLine = [UIView new];
        [self addSubview:_sepratorLine];
        [_sepratorLine setBackgroundColor:[UIColor grayColor]];
//        __weak typeof(_countLabel) label = _countLabel;
        // by mey
        __weak __typeof(&*_countLabel) label=_countLabel;

        [_sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(label.mas_left).with.offset(0);
            make.top.mas_equalTo(label.mas_bottom).with.offset(1);
//            make.size.mas_equalTo(CGSizeMake(100, 0.5f));
            make.height.mas_equalTo(0.5f);
            make.right.mas_equalTo(weakSelf).with.offset(-padding);
        }];
    }
    
    //图片
    NotifyUserView *lastView = nil;
    CGFloat padding1 = 10.0f;
//    CGFloat txtPadding = 20.0f;
    CGFloat photoHight = 70.0f;
    NSInteger count = 5;
//    CGFloat width = (weakSelf.frame.size.width-(count +1)*padding1)/count*1.0f;
    CGFloat width = 45;
    
    for(NSInteger index = 0; index < [_userList count]; index++)
    {
//        UIImageView *photoImage  = [UIImageView new];
//        [photoImage setImage:[UIImage imageNamed:[_userList objectAtIndex:index]]];
        NotifyUserView *userView =  [[[NSBundle mainBundle] loadNibNamed:@"NotifyUserView" owner:self options:nil] objectAtIndex:0];
        [userView.headerImg setImage:[UIImage imageNamed:@"third_selected"]];
        [userView setBackgroundColor:[UIColor lightGrayColor]];
        [userView.nameLabel setText:[_userList objectAtIndex:index]];
        [self addSubview:userView];
        //第一个
        if(lastView == nil)
        {
//            __weak typeof(_sepratorLine) line = _sepratorLine;
            // by mey
            __weak __typeof(&*_sepratorLine) line=_sepratorLine;
            [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.top.mas_equalTo(line.mas_bottom).with.offset(padding);
                make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding1);
                make.size.mas_equalTo(CGSizeMake(width, photoHight));
            }];
        }
        else
        {
            //左排第一个
            if(index %count == 0)
            {
                [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(weakSelf.mas_left).with.offset(padding1 );
                    make.top.mas_equalTo(lastView.mas_bottom).with.offset(padding1);
                    make.size.mas_equalTo(CGSizeMake(width, photoHight));
                    
                }];
            }
            else//左排第2，3
            {
                [userView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(lastView.mas_right).with.offset(padding1);
                    make.top.mas_equalTo(lastView.mas_top).with.offset(0);
                    make.size.mas_equalTo(CGSizeMake(width, photoHight));
                    
                }];
            }
            
        }
        lastView = userView;
        
//        UILabel *label = [UILabel new];
//        [label setText:[_userList objectAtIndex:index]];
//        [self addSubview:label];
//        [label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(lastView.mas_bottom);
//            make.left.mas_equalTo(lastView);
//            make.size.mas_equalTo(CGSizeMake(width, txtPadding));
//        }];
        
    }
    
    
    
}



@end
