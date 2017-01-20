//
//  THGuideArticleTableViewCell.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THGuideArticleTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "THNumberButton.h"
#import "NSObject+EXTParams.h"

@interface THGuideArticleTableViewCell()
{
    UIImageView *_thumbImageView;
    UIView *_videoBgView;
    UILabel *_titleLabel;
    UILabel *_descLabel;
    THNumberButton *_likeButton;
    UIView *_lineView;
}
@property (nonatomic,strong) NSDictionary *attributes;

@end

@implementation THGuideArticleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //缩略图
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thumbImageView.backgroundColor = kColorCircleBg;
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbImageView];
        //视频半透视图
        _videoBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        _videoBgView.userInteractionEnabled = NO;
        [_thumbImageView addSubview:_videoBgView];
        //视频播放视图
        UIImageView *videoPlayView = [[UIImageView alloc] initWithFrame:CGRectZero];
        videoPlayView.backgroundColor = [UIColor clearColor];
        videoPlayView.image = [UIImage imageNamed:@"jsb_video_player"];
        [_videoBgView addSubview:videoPlayView];
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = kFontMiddle_b;
        _titleLabel.textColor = KColorTitleTxt;
        [self.contentView addSubview:_titleLabel];
        //简介
        UIFont *font = kFontSmall;
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = font;
        _descLabel.textColor = KColorTitleTxt;
        _descLabel.numberOfLines = 2;
        [self.contentView addSubview:_descLabel];
        //喜欢数
        _likeButton = [[THNumberButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16) normalImage:[UIImage imageNamed:@"jsb-like-a"] highlightedImage:[UIImage imageNamed:@"jsb-like-b"] selectedImage:[UIImage imageNamed:@"jsb-like-c"]];
        _likeButton.backgroundColor = [UIColor clearColor];
        _likeButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_likeButton];
        //添加分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = RGBCOLOR(0xe5, 0xe5, 0xe5);
        [self.contentView addSubview:_lineView];
        //更新布局
        [_thumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.width.equalTo(@80);
            make.height.equalTo(@60);
            make.top.equalTo(@14);
        }];
        [_videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_thumbImageView).offset(0);
        }];
        [videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@29);
            make.height.equalTo(@29);
            make.center.equalTo(_videoBgView);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_thumbImageView.mas_right).offset(kEdgeInsetsLeft);
            make.right.equalTo(_likeButton.mas_left).offset(-5);
            make.top.equalTo(_thumbImageView);
        }];
        [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_thumbImageView.mas_right).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        }];
        [_likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@16);
            make.top.equalTo(_titleLabel);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
        }];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(kLineHeight));
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
        }];
        //设置简介的attributes
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 3;
        self.attributes = @{NSFontAttributeName:font,
                            NSForegroundColorAttributeName:KColorTitleTxt,
                            NSBackgroundColorAttributeName:[UIColor clearColor],
                            NSParagraphStyleAttributeName:paragraphStyle,
                            };

    }
    return self;
}

- (void)setArticleDict:(TXPBKnowledge *)articleDict
{
    if (articleDict == nil) {
        return;
    }
    _articleDict = articleDict;
    TXPBKnowledegeContentType contentType = _articleDict.contentType;
    if (contentType == TXPBKnowledegeContentTypeKPlain) {
        //重新排版
        _thumbImageView.hidden = YES;
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.right.equalTo(_likeButton).offset(-5);
            make.top.equalTo(@14);
        }];
        [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        }];
    }else{
        _thumbImageView.hidden = NO;
        NSString *coverPicUrlString = [_articleDict.coverPicUrl getFormatPhotoUrl:160 hight:120];
        [_thumbImageView TX_setImageWithURL:[NSURL URLWithString:coverPicUrlString] placeholderImage:nil];
        if (contentType == TXPBKnowledegeContentTypeKVideo) {
            _videoBgView.hidden = NO;
        }else{
            _videoBgView.hidden = YES;
        }
        [_thumbImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.width.equalTo(@80);
            make.height.equalTo(@60);
            make.top.equalTo(@14);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_thumbImageView.mas_right).offset(kEdgeInsetsLeft);
            make.right.equalTo(_likeButton.mas_left).offset(-5);
            make.top.equalTo(_thumbImageView);
        }];
        [_descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_thumbImageView.mas_right).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        }];
    }
    //标题
    _titleLabel.text = _articleDict.title;
    //简介
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:_articleDict.pb_description attributes:_attributes];
    _descLabel.attributedText = attString;
    //赞
    int64_t thankNum = 0;
    NSNumber *extNumber = [articleDict extParamForKey:@"likedNumer"];
    if (extNumber) {
        thankNum = [extNumber longLongValue];
    }else{
        thankNum = articleDict.likedNum;
    }
    BOOL isLike = NO;
    NSNumber *extLiked = [articleDict extParamForKey:@"hasLike"];
    if (extLiked) {
        isLike = [extLiked boolValue];
    }else{
        isLike = articleDict.hasLiked;
    }
    _likeButton.numberString = [NSString stringWithFormat:@"%@",@(thankNum)];
    [_likeButton setSelected:isLike];
    //设置布局
    CGFloat likeWidth = _likeButton.adjustWidth;
    [_likeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(likeWidth));
    }];
}

@end
