//
//  MediaAlbumCollectionViewCell.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/22.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "MediaAlbumCollectionViewCell.h"
#import "UIImageView+EMWebCache.h"

@interface MediaAlbumCollectionViewCell()
{
    UIImageView *_thumbnailImgView;
    UILabel *_titleLabel;
}
@end

@implementation MediaAlbumCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _thumbnailImgView = [[UIImageView alloc] init];
        _thumbnailImgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
        _thumbnailImgView.backgroundColor = kColorCircleBg;
        _thumbnailImgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_thumbnailImgView];
        //标题
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width);
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = kColorBlack;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setupCellWithThumbnailName:(NSString *)thumbnailName
                             title:(NSString *)title
{
    int width = _thumbnailImgView.width_;
    __weak UIImageView *tmpObject = _thumbnailImgView;
    [_thumbnailImgView TX_setImageWithURL:[NSURL URLWithString:[thumbnailName getFormatPhotoUrl:width hight:width]] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            tmpObject.image = [UIImage imageNamed:@"tp_148x148"];
        }
    }];
    _titleLabel.text = title;
}
@end
