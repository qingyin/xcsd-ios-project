//
//  TXMediaTrackTableViewCell.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/8.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXMediaTrackTableViewCell.h"
#import "TXMediaItem.h"
#import "NSDate+TuXing.h"
#import "NSObject+EXTParams.h"
#import "TXPBResource+Utils.h"

@interface TXMediaTrackTableViewCell()
{
    CGFloat _cellWidth;
    UIImageView *_thumbImageView;
    UILabel *_titleLabel;
    UILabel *_lengthLabel;
    UILabel *_providerLabel;
    UIImageView *_viewImageView;
    UILabel *_viewCountLabel;
    UIImageView *_likeImageView;
    UILabel *_likeCountLabel;
    UILabel *_timeLabel;
    UIView *_lineView;
    UIView *_playingBgView;
    UIImageView *_mediaTypeView;
}
@end

@implementation TXMediaTrackTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                    cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = cellWidth;
        //缩略图
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 53, 53)];
        _thumbImageView.backgroundColor = kColorCircleBg;
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thumbImageView];
        //添加播放状态
        _playingBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 53, 53)];
        _playingBgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2];
        [_thumbImageView addSubview:_playingBgView];
        _mediaTypeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _mediaTypeView.center = CGPointMake(_playingBgView.width_ / 2, _playingBgView.height_ / 2);
        [_playingBgView addSubview:_mediaTypeView];
        _playingBgView.hidden = YES;
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_thumbImageView.maxX + 8, 10, _cellWidth - 90 - _thumbImageView.maxX, 18)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = RGBCOLOR(0x48, 0x48, 0x48);
        [self.contentView addSubview:_titleLabel];
        //级数
//        _lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(_thumbImageView.maxX + 8, _titleLabel.maxY + 2, 0, 15)];
//        _lengthLabel.backgroundColor = [UIColor clearColor];
//        _lengthLabel.textColor = RGBCOLOR(83, 83, 83);
//        _lengthLabel.font = [UIFont systemFontOfSize:12];
//        [self.contentView addSubview:_lengthLabel];
        //provider
//        _providerLabel = [[UILabel alloc] initWithFrame:CGRectMake(_lengthLabel.maxX, _titleLabel.maxY + 2, _cellWidth - _lengthLabel.maxX - 10, 15)];
        _providerLabel = [[UILabel alloc] initWithFrame:CGRectMake(_thumbImageView.maxX + 8, _titleLabel.maxY + 2, _cellWidth - _thumbImageView.maxX - 10, 15)];
        _providerLabel.backgroundColor = [UIColor clearColor];
        _providerLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        _providerLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_providerLabel];
        //观看数
        _viewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_thumbImageView.maxX + 8, _thumbImageView.maxY - 10, 10, 10)];
        _viewImageView.image = [UIImage imageNamed:@"media_share"];
        [self.contentView addSubview:_viewImageView];
        _viewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_viewImageView.maxX + 3, _viewImageView.minY, 40, 20)];
        _viewCountLabel.backgroundColor = [UIColor clearColor];
        _viewCountLabel.font = kFontTimeTitle;
        _viewCountLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        [self.contentView addSubview:_viewCountLabel];
        //赞数
        _likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_viewCountLabel.maxX, _thumbImageView.maxY - 10, 10, 10)];
        _likeImageView.image = [UIImage imageNamed:@"media_like"];
        [self.contentView addSubview:_likeImageView];
        _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_likeImageView.maxX + 3, _likeImageView.minY, 40, 20)];
        _likeCountLabel.backgroundColor = [UIColor clearColor];
        _likeCountLabel.font = kFontTimeTitle;
        _likeCountLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        [self.contentView addSubview:_likeCountLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_cellWidth - 80, 10, 70, 15)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = kFontTimeTitle;
        _timeLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
        //分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 72.5, _cellWidth - 10, kLineHeight)];
        _lineView.backgroundColor = KColorResourceLine;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setItem:(TXMediaItem *)item
{
    _item = item;
    //设置内容
    [_thumbImageView TX_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholderImage:nil];
    //标题
    _titleLabel.text = item.title;
    //provider
    _providerLabel.text = [NSString stringWithFormat:@"by %@",item.author];
    //观看数
    _viewCountLabel.text = [NSString stringWithFormat:@"%@",@(item.viewedCount)];
    CGSize viewSize = [_viewCountLabel sizeThatFits:CGSizeMake(100, 20)];
    _viewCountLabel.frame = CGRectMake(_viewImageView.maxX + 3, _viewImageView.minY - 2, viewSize.width > 40 ?: 40, viewSize.height);
    //赞
    _likeImageView.frame = CGRectMake(_viewCountLabel.maxX, _thumbImageView.maxY - 10, 10, 10);
    _likeCountLabel.text = [NSString stringWithFormat:@"%@",@(item.likedCount)];
    _likeCountLabel.frame = CGRectMake(_likeImageView.maxX + 3, _likeImageView.minY - 2, _cellWidth - _likeImageView.maxX - 10, viewSize.height);
    //时间
    _timeLabel.text = item.timeString;
}
- (void)setResource:(TXPBResource *)resource
{
    _resource = resource;
//    _lengthLabel.frame = CGRectMake(_thumbImageView.maxX + 8, _titleLabel.maxY + 2, 0, 15);
//    _providerLabel.frame = CGRectMake(_lengthLabel.maxX, _titleLabel.maxY + 2, _cellWidth - _lengthLabel.maxX - 10, 15);
    self.accessoryType = UITableViewCellAccessoryNone;
    //设置内容
    [_thumbImageView TX_setImageWithURL:[NSURL URLWithString:_resource.coverImage] placeholderImage:nil];
    if (resource.type == TXPBResourceTypeTAudio) {
        _mediaTypeView.image = [UIImage imageNamed:@"media_audio"];
    }else if (resource.type == TXPBResourceTypeTVideo) {
        _mediaTypeView.image = [UIImage imageNamed:@"media_video"];
    }else{
        _mediaTypeView.image = nil;
    }
    //标题
    _titleLabel.text = _resource.name;
    //provider
    _providerLabel.text = [NSString stringWithFormat:@"by %@",_resource.providerName];
//    _providerLabel.text = @"";
    //观看数
//    _viewCountLabel.text = [NSString stringWithFormat:@"%@",@(_resource.viewedCount)];
    _viewCountLabel.text = [TXPublicUtils fortmatInt64ToTenThousandStr:_resource.viewedCount];
    CGSize viewSize = [_viewCountLabel sizeThatFits:CGSizeMake(100, 20)];
    _viewCountLabel.frame = CGRectMake(_viewImageView.maxX + 3, _viewImageView.minY - 2, viewSize.width > 40 ?: 40, viewSize.height);
    //赞
    int64_t likeBudge = _resource ? [_resource getLikedNumber] : 0;
    BOOL liked = _resource ? [_resource isLiked] : 0;
    if (liked) {
        _likeImageView.image = [UIImage imageNamed:@"media_like_selected"];
    }else{
        _likeImageView.image = [UIImage imageNamed:@"media_like"];
    }
    _likeImageView.frame = CGRectMake(_viewCountLabel.maxX, _thumbImageView.maxY - 10, 10, 10);
//    _likeCountLabel.text = [NSString stringWithFormat:@"%@",@(likeBudge)];
    _likeCountLabel.text = [TXPublicUtils fortmatInt64ToTenThousandStr:likeBudge];
    _likeCountLabel.frame = CGRectMake(_likeImageView.maxX + 3, _likeImageView.minY - 2, _cellWidth - _likeImageView.maxX - 10, viewSize.height);
    //时间
    NSString *timeString = [NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(_resource.createdOn/1000)]];
    _timeLabel.text = timeString;
}
- (void)setAlbum:(TXPBAlbum *)album
{
    _album = album;
//    _lengthLabel.frame = CGRectMake(_thumbImageView.maxX + 8, _titleLabel.maxY + 2, 0, 15);
//    _providerLabel.frame = CGRectMake(_lengthLabel.maxX, _titleLabel.maxY + 2, _cellWidth - _lengthLabel.maxX - 10, 15);
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //设置内容
    [_thumbImageView TX_setImageWithURL:[NSURL URLWithString:_album.coverImage] placeholderImage:nil];
    //标题
    _titleLabel.text = _album.name;
    //provider
//    _providerLabel.text = [NSString stringWithFormat:@"by%@",_album.providerName];
    _providerLabel.text = [NSString stringWithFormat:@"%@集",@(_album.episodes)];
    //观看数
//    _viewCountLabel.text = [NSString stringWithFormat:@"%@",@(_album.viewedCount)];
    _viewCountLabel.text = [TXPublicUtils fortmatInt64ToTenThousandStr:_album.viewedCount];
    CGSize viewSize = [_viewCountLabel sizeThatFits:CGSizeMake(100, 20)];
    _viewCountLabel.frame = CGRectMake(_viewImageView.maxX + 3, _viewImageView.minY - 2, viewSize.width > 40 ?: 40, viewSize.height);
    //赞
    NSInteger likeComment;
    NSNumber *extNumber = [_album extParamForKey:@"likedCount"];
    if (extNumber) {
        likeComment = [extNumber integerValue];
    }else{
        likeComment = _album.likedCount;
    }
    _likeImageView.frame = CGRectMake(_viewCountLabel.maxX, _thumbImageView.maxY - 10, 10, 10);
//    _likeCountLabel.text = [NSString stringWithFormat:@"%@",@(likeComment)];
    _likeCountLabel.text = [TXPublicUtils fortmatInt64ToTenThousandStr:likeComment];
    _likeCountLabel.frame = CGRectMake(_likeImageView.maxX + 3, _likeImageView.minY - 2, _cellWidth - _likeImageView.maxX - 10, viewSize.height);
    //时间
    NSString *timeString = [NSDate timeForChatListStyle:[NSString stringWithFormat:@"%@", @(_album.updateOn/1000)]];
    _timeLabel.text = timeString;
}
- (void)setPlaying:(BOOL)playing
{
    _playing = playing;
    if (_playing) {
        _titleLabel.textColor = RGBCOLOR(0x41, 0xc3, 0xff);
        _playingBgView.hidden = NO;
    }else{
        _titleLabel.textColor = KColorTitleTxt;
        _playingBgView.hidden = YES;
    }
}

@end
