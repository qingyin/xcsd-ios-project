//
//  THArticleDetailCell.m
//  TXChatTeacher
//
//  Created by Cloud on 15/12/4.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THArticleDetailCell.h"
#import <HTCopyableLabel.h>
#import <NSMutableAttributedString+NimbusKitAttributedLabel.h>
#import "PublishmentDetailViewController.h"
#import "THGuideArticleDetailViewController.h"
#import "NSDate+TuXing.h"
#import "UIImageView+EMWebCache.h"

@interface THArticleDetailCell ()<NIAttributedLabelDelegate>
{
    UIImageView *_photoView;
    UILabel *_nameLb;
    UILabel *_positionLb;
    UILabel *_timeLb;
    HTCopyableLabel *_commentLb;
}

@end

@implementation THArticleDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorBackground;
        self.contentView.backgroundColor = kColorBackground;
        
        _photoView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoView.layer.cornerRadius = 16;
        _photoView.layer.masksToBounds = YES;
        [self.contentView addSubview:_photoView];
        [_photoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(13);
            make.top.mas_equalTo(12);
            make.width.mas_equalTo(32);
            make.height.mas_equalTo(32);
        }];
        
        _nameLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _nameLb.font = kFontMiddle_b;
        _nameLb.textColor = kColorGray;
        [self.contentView addSubview:_nameLb];
        [_nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_photoView.mas_right).offset(8);
            make.top.mas_equalTo(_photoView.mas_top).offset(1);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        
        _positionLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _positionLb.font = kFontSmall;
        _positionLb.textColor = kColorGray;
        [self.contentView addSubview:_positionLb];
        [_positionLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLb.mas_right);
            make.bottom.mas_equalTo(_nameLb.mas_bottom);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        
        _timeLb = [[UILabel alloc] initClearColorWithFrame:CGRectZero];
        _timeLb.font = kFontMini;
        _timeLb.textColor = kColorGray;
        [self.contentView addSubview:_timeLb];
        [_timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLb.mas_left);
            make.bottom.mas_equalTo(_photoView.mas_bottom).offset(-1);
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }];
        
        UIView *lineView = [[UIView alloc] initLineWithFrame:CGRectZero];
        [self.contentView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.height.mas_equalTo(kLineHeight);
        }];
        
        _commentLb = [[HTCopyableLabel alloc] initClearColorWithFrame:CGRectZero];
        _commentLb.delegate = self;
        _commentLb.textColor = kColorBlack;
        _commentLb.font = kFontMiddle;
        _commentLb.numberOfLines = 0;
        _commentLb.autoDetectLinks = YES;
        //下划线
        _commentLb.linksHaveUnderlines = NO;
        [self.contentView addSubview:_commentLb];
        [_commentLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_nameLb.mas_left);
            make.top.mas_equalTo(_photoView.mas_bottom).offset(13);
            make.height.mas_equalTo(0);
        }];
        
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(kScreenWidth);
            make.bottom.mas_equalTo(_commentLb.mas_bottom).offset(12);
        }];
 
        
    }
    return self;
}

- (void)setDetailDic:(id)detailDic{
    NSString *name = nil;
    NSString *position = nil;
    NSString *time = nil;
    NSString *content = nil;
    NSString *photoUrl = nil;
    if ([detailDic isKindOfClass:[TXComment class]]) {
        TXComment *comment = detailDic;
        name = comment.userNickname;
        position = comment.userTitle;
        time = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", @(comment.createdOn/1000)]];
        content = comment.content;
        photoUrl = comment.userAvatarUrl;
    }else{
        TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
        name = user.nickname;
        position = @"";
        time = [NSDate timeForCircleStyle:[NSString stringWithFormat:@"%@", detailDic[@"time"]]];
        content = detailDic[@"comment"];
        photoUrl = user.avatarUrl;
    }
    NSString *urlStr = [photoUrl getFormatPhotoUrl:32 hight:32];
    [_photoView TX_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];

    
    _nameLb.text = name;
    [_nameLb sizeToFit];
    [_nameLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_nameLb.width_);
        make.height.mas_equalTo(_nameLb.height_);
    }];
    
    _positionLb.text = position;
    [_positionLb sizeToFit];
    [_positionLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_positionLb.width_);
        make.height.mas_equalTo(_positionLb.height_);
    }];
    
    _timeLb.text = time;
    [_timeLb sizeToFit];
    [_timeLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(_timeLb.width_);
        make.height.mas_equalTo(_timeLb.height_);
    }];
    
    //内容
    NSString *str = content;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
    [attributedString nimbuskit_setTextColor:kColorBlack];
    [attributedString nimbuskit_setFont:kFontMiddle];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:4];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
    _commentLb.attributedText = attributedString;
    CGSize size = [_commentLb sizeThatFits:CGSizeMake(kScreenWidth - 66, MAXFLOAT)];
    [_commentLb mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
        make.height.mas_equalTo(size.height);
    }];

}

#pragma mark - NIAttributedLabelDelegate
- (void)attributedLabel:(NIAttributedLabel*)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    NSString *resultStr = [result.URL absoluteString];
    //跳转到网页链接
    PublishmentDetailViewController *detailVc = [[PublishmentDetailViewController alloc] initWithLinkURLString:resultStr];
    [_listVC.navigationController pushViewController:detailVc animated:YES];
    return;
}

@end
