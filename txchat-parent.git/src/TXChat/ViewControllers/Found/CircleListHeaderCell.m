//
//  CircleListHeaderCell.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CircleListHeaderCell.h"
#import "UIButton+EMWebCache.h"
#import <UIImageView+Utils.h>
#import "CircleListViewController.h"
#import "CircleHomeViewController.h"
#import "CircleNewCommentsViewController.h"
#import <SDiPhoneVersion.h>
#import "CirclePhotosViewController.h"

@interface CircleListHeaderCell ()
{
    UIView *_coverView;
    UILabel *_nameLb;
    UIButton *_portraitBtn;
    UIImageView *_coverImgView;
}

@end

@implementation CircleListHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.clipsToBounds = YES;
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
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, _coverImgView.maxY, kScreenWidth, 40)];
        btnView.backgroundColor = kColorWhite;
        [self.contentView addSubview:btnView];
        [btnView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, btnView.height_ - kLineHeight, kScreenWidth, kLineHeight)]];
        [btnView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kScreenWidth/2, 8, kLineHeight, btnView.height_ - 16)]];
        
        UIView *gapView = [[UIView alloc] initWithFrame:CGRectMake(0, btnView.maxY, kScreenWidth, 10)];
        gapView.backgroundColor = kColorBackground;
        [self.contentView addSubview:gapView];
        [gapView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, gapView.height_ - kLineHeight, kScreenWidth, kLineHeight)]];
        
        UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        photoBtn.titleLabel.font = kFontMiddle;
        photoBtn.frame = CGRectMake(0, 0, kScreenWidth/2, btnView.height_);
        [photoBtn setImage:[UIImage imageNamed:@"qzq-xc"] forState:UIControlStateNormal];
        [photoBtn setTitle:@"班级相册" forState:UIControlStateNormal];
        photoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [photoBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [btnView addSubview:photoBtn];
        [photoBtn handleControlEvent:UIControlEventTouchUpInside withBlock:^(id sender) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CircleListViewController *avc = (CircleListViewController *)_listVC;
                CirclePhotosViewController *photosVC = [[CirclePhotosViewController alloc] init];
                [avc.navigationController pushViewController:photosVC animated:YES];
            });
        }];
        
        UIButton *atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        atBtn.titleLabel.font = kFontMiddle;
        atBtn.frame = CGRectMake(photoBtn.maxX, 0, kScreenWidth/2, btnView.height_);
        [atBtn setTitle:@"与我相关" forState:UIControlStateNormal];
        atBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        [atBtn setImage:[UIImage imageNamed:@"qzq-xg"] forState:UIControlStateNormal];
        [atBtn setTitleColor:kColorBlack forState:UIControlStateNormal];
        [atBtn addTarget:self action:@selector(onNewsBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnView addSubview:atBtn];
        
        BOOL isPlus = SDiPhoneVersion.deviceSize ==iPhone55inch?YES:NO;
        UIView *portraitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
        portraitView.layer.cornerRadius = isPlus?6:4;
        portraitView.layer.masksToBounds = YES;
        portraitView.backgroundColor = kColorWhite;
        [_coverView addSubview:portraitView];
        
        _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitBtn setBackgroundImage:[UIImage imageNamed:@"userDefaultIcon"] forState:UIControlStateNormal];
        _portraitBtn.layer.cornerRadius = isPlus?6:4;
        _portraitBtn.backgroundColor = kColorClear;
        _portraitBtn.layer.masksToBounds = YES;
        _portraitBtn.adjustsImageWhenHighlighted = NO;
        _portraitBtn.frame = CGRectMake(_coverImgView.width_ - 10 - 56, _coverImgView.height_ - 68, 56, 56);
        [_portraitBtn addTarget:self action:@selector(onPortraitBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_portraitBtn];
        
        portraitView.center = _portraitBtn.center;
        
        //昵称
        _nameLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLb.font = [UIFont boldSystemFontOfSize:18.5f];
        _nameLb.textColor = kColorWhite;
        _nameLb.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLb];
        
        //新消息白色背景
        self.newsBgView = [[UIView alloc] initWithFrame:CGRectMake(0, gapView.maxY, kScreenWidth, 18)];
        _newsBgView.backgroundColor = kColorWhite;
        [self.contentView addSubview:_newsBgView];

        //新消息
        UIImage *imgArrow = [UIImage imageNamed:@"_newmessage"];
        self.newsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _newsBtn.backgroundColor = kColorBackground;
        [_newsBtn setTitleColor:kColorGray1 forState:UIControlStateNormal];
        _newsBtn.layer.cornerRadius = 2.f;
        _newsBtn.layer.masksToBounds = YES;
        [_newsBtn setImage:imgArrow forState:UIControlStateNormal];
        _newsBtn.adjustsImageWhenHighlighted = NO;
        _newsBtn.titleLabel.font = [UIFont systemFontOfSize:11.f];
        _newsBtn.frame = CGRectMake((kScreenWidth - 100)/2, _newsBgView.maxY, 100, 22);
        [_newsBtn addTarget:self action:@selector(onNewsBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_newsBtn];
    }
    return self;
}

- (void)onNewsBtn:(UIButton *)btn{
    if ([_listVC isKindOfClass:[CircleListViewController class]]) {
        CircleListViewController *avc = (CircleListViewController *)_listVC;
        avc.isShowNews = NO;
        [[TXChatClient sharedInstance] setCountersDictionaryValue:0 forKey:TX_COUNT_FEED_COMMENT];
        
        CircleNewCommentsViewController *commentsVC = [[CircleNewCommentsViewController alloc] init];
        [avc.navigationController pushViewController:commentsVC animated:YES];
        
    }
    if ([btn.titleLabel.text isEqualToString:@"@ 与我相关"]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_CIRCLE object:nil];
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
     [_portraitBtn TX_setImageWithURL:[NSURL URLWithString:[portrait getFormatPhotoUrl:60 hight:60]] forState:UIControlStateNormal placeholderImage:nil];
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
    return isShow ? (coverHeight + 40 + 10 + 18 + 22 + 18) : (coverHeight + 40 + 10) ;
}



@end
