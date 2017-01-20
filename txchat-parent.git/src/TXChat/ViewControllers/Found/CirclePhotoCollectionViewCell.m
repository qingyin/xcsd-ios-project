//
//  CirclePhotoCollectionViewCell.m
//  TXChatParent
//
//  Created by Cloud on 15/9/23.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "CirclePhotoCollectionViewCell.h"
#import "UIImageView+EMWebCache.h"

@interface CirclePhotoCollectionViewCell ()
{
    UIImageView *_thumbnailImgView;
}

@end

@implementation CirclePhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _thumbnailImgView = [[UIImageView alloc] init];
        _thumbnailImgView.clipsToBounds = YES;
        _thumbnailImgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _thumbnailImgView.backgroundColor = kColorCircleBg;
        _thumbnailImgView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_thumbnailImgView];
    }
    return self;
}


- (void)setupCellWithThumbnailName:(NSString *)thumbnailName
{
    int width = _thumbnailImgView.width_;
    __weak UIImageView *tmpObject = _thumbnailImgView;
    [_thumbnailImgView TX_setImageWithURL:[NSURL URLWithString:[thumbnailName getFormatPhotoUrl:width hight:width]] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            tmpObject.image = [UIImage imageNamed:@"tp_148x148"];
        }
    }];
}

@end
