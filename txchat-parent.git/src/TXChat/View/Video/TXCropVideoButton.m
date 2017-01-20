//
//  TXCropVideoButton.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 16/6/28.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXCropVideoButton.h"

@interface TXCropVideoButton()
{
    UIImageView *_videoThumbView;
    UIView *_coverView;
    UIView *_borderView;
    UIView *_bottomView;
    UILabel *_lengthLabel;
}
@end

@implementation TXCropVideoButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //缩略图
        _videoThumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:_videoThumbView];
        //遮罩
        _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _coverView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        _coverView.userInteractionEnabled = NO;
        [self addSubview:_coverView];
        //底部效果
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 17, frame.size.width, 17)];
        _bottomView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        _bottomView.userInteractionEnabled = NO;
        [self addSubview:_bottomView];
        //视频icon
        UIImageView *videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(6, _bottomView.minY + 3, 10, 10)];
        videoIcon.image = [UIImage imageNamed:@"crop_videoIcon"];
        [self addSubview:videoIcon];
        //时长
        _lengthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _bottomView.minY, frame.size.width - 26, 17)];
        _lengthLabel.backgroundColor = [UIColor clearColor];
        _lengthLabel.userInteractionEnabled = NO;
        _lengthLabel.font = [UIFont systemFontOfSize:9];
        _lengthLabel.textColor = [UIColor whiteColor];
        _lengthLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_lengthLabel];
        //边框
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height )];
        _borderView.backgroundColor = [UIColor clearColor];
        _borderView.userInteractionEnabled = NO;
        _borderView.layer.cornerRadius = 2.f;
        _borderView.layer.masksToBounds = YES;
        _borderView.layer.borderColor = RGBCOLOR(0xfa, 0xf9, 0xf9).CGColor;
        _borderView.layer.borderWidth = 1;
        [self addSubview:_borderView];
        //默认隐藏边框
        _borderView.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    //设置效果
    _coverView.hidden = selected;
    _borderView.hidden = !selected;
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    _videoThumbView.image = thumbImage;
}
- (void)setVideoLength:(NSString *)videoLength
{
    _videoLength = videoLength;
    _lengthLabel.text = _videoLength;
}
@end
