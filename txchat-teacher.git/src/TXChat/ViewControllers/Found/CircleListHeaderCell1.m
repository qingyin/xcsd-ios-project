//
//  CircleListHeaderCell.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleListHeaderCell1.h"
#import "UIButton+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "CircleListViewController.h"
#import "CircleHomeViewController.h"
#import "CircleNewCommentsViewController.h"
#import <SDiPhoneVersion.h>

@interface CircleListHeaderCell1 ()
{
    UIView *_coverView;
    UILabel *_nameLb;
    UIButton *_portraitBtn;
    UIImageView *_coverImgView;
}

@end

@implementation CircleListHeaderCell1

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat coverHeight = 223;
        if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
            coverHeight = 261;
        }else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            coverHeight = 288;
        }

        //        UIImage *coverImg = [UIImage imageNamed:@"circile_cover"];
        UIImage *coverImg = [UIImage imageNamed:@"feedTopbg"];
        
        //头像
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        _coverView.clipsToBounds = YES;
        _coverView.frame = CGRectMake(0, 0, kScreenWidth, coverHeight + 37);
        [self.contentView addSubview:_coverView];
        
        //封面
        _coverImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _coverImgView.clipsToBounds = YES;
        _coverImgView.image = coverImg;
        _coverImgView.frame = CGRectMake(0, 0, _coverView.width_, coverHeight);
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        [_coverView addSubview:_coverImgView];
        
        BOOL isPlus = SDiPhoneVersion.deviceSize ==iPhone55inch?YES:NO;
        UIView *portraitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
        portraitView.layer.cornerRadius = isPlus?6:4;
        portraitView.layer.masksToBounds = YES;
        portraitView.backgroundColor = kColorWhite;
        [_coverView addSubview:portraitView];
        
        _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitBtn setBackgroundImage:[UIImage imageNamed:@"userDefaultIcon"] forState:UIControlStateNormal];
        _portraitBtn.layer.cornerRadius = isPlus?6:4;
        _portraitBtn.layer.masksToBounds = YES;
        _portraitBtn.backgroundColor = kColorClear;
        _portraitBtn.adjustsImageWhenHighlighted = NO;
        _portraitBtn.frame = CGRectMake(_coverImgView.width_ - 10 - 56, _coverImgView.height_ - 68, 56, 56);
        [_portraitBtn addTarget:self action:@selector(onPortraitBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_portraitBtn];
        
        portraitView.center = _portraitBtn.center;
        
        //昵称
        _nameLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLb.font = [UIFont systemFontOfSize:18.5f];
        _nameLb.textColor = kColorWhite;
        _nameLb.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLb];
        
        //新消息
        self.newsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _newsBtn.backgroundColor = kColorBackground;
        [_newsBtn setTitleColor:kColorGray1 forState:UIControlStateNormal];
        _newsBtn.layer.cornerRadius = 3.f;
        _newsBtn.layer.masksToBounds = YES;
        _newsBtn.adjustsImageWhenHighlighted = NO;
        _newsBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        _newsBtn.frame = CGRectMake((kScreenWidth - 95)/2, _portraitBtn.maxY, 95, 20);
        [self.contentView addSubview:_newsBtn];
        
        [_newsBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_listVC isKindOfClass:[CircleListViewController class]]) {
                    CircleListViewController *avc = (CircleListViewController *)_listVC;
                    avc.isShowNews = NO;
                    [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED_COMMENT];
                    
                    CircleNewCommentsViewController *commentsVC = [[CircleNewCommentsViewController alloc] init];
                    [avc.navigationController pushViewController:commentsVC animated:YES];
                    
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:@(YES)];
            });
        }];
    }
    return self;
}

- (void)onPortraitBtn{
    if ([_listVC isKindOfClass:[CircleListViewController class]]) {
        NSError *error = nil;
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:&error];
        CircleListViewController *tmpVC = _listVC;
        CircleHomeViewController *avc = [[CircleHomeViewController alloc] init];
        avc.userId = user.userId;
        avc.portraitUrl = user.avatarUrl;
        avc.nickName = user.nickname;
        [tmpVC.navigationController pushViewController:avc animated:YES];
    }
}

- (void)setPortrait:(NSString *)portrait andNickname:(NSString *)nickName{
    [_portraitBtn TX_setImageWithURL:[NSURL URLWithString:[portrait getFormatPhotoUrl:60 hight:60] ] forState:UIControlStateNormal placeholderImage:nil];
    _nameLb.text = nickName;
    [_nameLb sizeToFit];
    _nameLb.frame = CGRectMake(_portraitBtn.minX - 10 - _nameLb.width_ , _portraitBtn.maxY - 6 - _nameLb.height_,_nameLb.width_, _nameLb.height_);
}


+(CGFloat)GetHeaderCellHeight:(BOOL)isShow {
    //新的计算方法
    CGFloat coverHeight = 223;
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        coverHeight = 261;
    }else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        coverHeight = 288;
    }
    return isShow ? coverHeight + 57 : coverHeight + 37;
    //    return isShow ? 280 : 260;
    //    UIImage *coverImg = [UIImage imageNamed:@"circile_cover"];
    //    if (isShow) {
    //        return coverImg.size.height + 35 + 25;
    //    }else{
    //        return coverImg.size.height + 35;
    //    }
}



@end
