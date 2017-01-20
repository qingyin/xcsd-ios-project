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
    UIView *_levelView;
    UIImageView *_levelNameView;
    UIView *_gapView;
    UIView *_lineView;
}

@end

@implementation CircleListHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        
        CGFloat coverHeight = 223;
        if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
            coverHeight = 261;
        }else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            coverHeight = 288;
        }

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
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _coverImgView.height_ - 80, kScreenWidth, 70)];
        bgView.image = [UIImage imageNamed:@"qzq_header_bg"];
        [self.contentView addSubview:bgView];
        
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
        _nameLb.font = [UIFont systemFontOfSize:18.5f];
        _nameLb.textColor = kColorWhite;
        _nameLb.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_nameLb];
        
        _levelView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_levelView];
        
        UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, _coverImgView.maxY, kScreenWidth, 40)];
        btnView.backgroundColor = kColorWhite;
        [self.contentView addSubview:btnView];
        [btnView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, btnView.height_ - kLineHeight, kScreenWidth, kLineHeight)]];
        [btnView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(kScreenWidth/2, 8, kLineHeight, btnView.height_ - 16)]];
        
        _gapView = [[UIView alloc] initWithFrame:CGRectZero];
        _gapView.backgroundColor = kColorBackground;
        _gapView.clipsToBounds = YES;
        [self.contentView addSubview:_gapView];
        [_gapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(btnView.mas_bottom);
            make.height.mas_equalTo(0);
        }];
        [_gapView addSubview:[[UIView alloc] initLineWithFrame:CGRectMake(0, 10 * kScale - kLineHeight, kScreenWidth, kLineHeight)]];
        
        _levelNameView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _levelNameView.image = [UIImage imageNamed:@"fx-xxbg"];
        _levelNameView.clipsToBounds = YES;
        [self.contentView addSubview:_levelNameView];
        [_levelNameView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(_gapView.mas_bottom);
            make.height.mas_equalTo(26);
        }];

        
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
                photosVC.departmentId = avc.departmentId;
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

        //新消息
        UIImage *imgArrow = [UIImage imageNamed:@"_newmessage"];
        self.newsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _newsBtn.backgroundColor = kColorBackground;
        [_newsBtn setTitleColor:kColorGray1 forState:UIControlStateNormal];
        _newsBtn.layer.cornerRadius = 2.f;
        _newsBtn.layer.masksToBounds = YES;
        [_newsBtn setImage:imgArrow forState:UIControlStateNormal];
        _newsBtn.adjustsImageWhenHighlighted = NO;
        _newsBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [self.contentView addSubview:_newsBtn];
        [_newsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo((kScreenWidth - 100)/2);
            make.top.mas_equalTo(_levelNameView.mas_bottom).offset(16);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(22);
        }];
        [_newsBtn addTarget:self action:@selector(onNewsBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
        [self.contentView addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(_newsBtn.mas_bottom).offset(16 - kLineHeight);
            make.height.mas_equalTo(kLineHeight);
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

- (void)setPortrait:(NSString *)portrait andNickname:(NSString *)nickName andLevel:(int)level andLevelName:(NSString *)levelName{
    NSString *imgStr = [portrait getFormatPhotoUrl:60 hight:60];
     [_portraitBtn TX_setImageWithURL:[NSURL URLWithString:imgStr] forState:UIControlStateNormal placeholderImage:nil];
    _nameLb.text = nickName;
    [_nameLb sizeToFit];
    _nameLb.frame = CGRectMake(_portraitBtn.minX - 10 - _nameLb.width_ , _portraitBtn.maxY - 20 - _nameLb.height_,_nameLb.width_, _nameLb.height_);
    //移除旧视图
    for (UIView *subLevelView in _levelNameView.subviews) {
        [subLevelView removeFromSuperview];
    }
    if (!levelName || !levelName.length) {
        [_levelNameView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [_gapView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10 * kScale);
        }];
    }else{
        [_gapView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.font = kFontTiny;
        [btn setTitleColor:kColorOrange forState:UIControlStateDisabled];
        [btn setImage:[UIImage imageNamed:@"qzq-xz"] forState:UIControlStateDisabled];
        [btn setTitle:levelName forState:UIControlStateDisabled];
        btn.enabled = NO;
        [_levelNameView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(_levelNameView.mas_height);
        }];
    }
    //移除旧视图
    for (UIView *subLevelView in _levelView.subviews) {
        [subLevelView removeFromSuperview];
    }
    int sunCount = level/9;
    int moonCount = (level%9)/3;
    int starCount = level%3;
    CGFloat X = 0;
    for (int i = 0; i < sunCount; ++i) {
        UIImageView *sunImgView = [[UIImageView alloc] initWithFrame:CGRectMake(X, (_levelView.height_ - 13)/2, 13, 13)];
        sunImgView.image = [UIImage imageNamed:@"sun"];
        [_levelView addSubview:sunImgView];
        X += 18;
    }
    for (int i = 0; i < moonCount; ++i) {
        UIImageView *moonImgView = [[UIImageView alloc] initWithFrame:CGRectMake(X, (_levelView.height_ - 13)/2, 13, 13)];
        moonImgView.image = [UIImage imageNamed:@"moon"];
        [_levelView addSubview:moonImgView];
        X += 18;
    }
    for (int i = 0; i < starCount; ++i) {
        UIImageView *starImgView = [[UIImageView alloc] initWithFrame:CGRectMake(X, (_levelView.height_ - 13)/2, 13, 13)];
        starImgView.image = [UIImage imageNamed:@"star"];
        [_levelView addSubview:starImgView];
        X += 18;
    }
    _levelView.frame = CGRectMake(_nameLb.maxX - X + 5, _nameLb.maxY, X + 5, _portraitBtn.height_ - _nameLb.height_ - 17);
}


+(CGFloat)GetHeaderCellHeight:(BOOL)isShow andLevelName:(NSString *)levelName{
    //新的计算方法
    CGFloat coverHeight = 223;
    if ([SDiPhoneVersion deviceSize] == iPhone47inch) {
        coverHeight = 261;
    }else if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
        coverHeight = 288;
    }

    coverHeight += 40;
    CGFloat height = isShow ? coverHeight + 16 + 16 + 22 : coverHeight;
    if (levelName && levelName.length) {
        height += 26;
    }else{
        height += (10 * kScale);
    }
    return height;
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




@end
