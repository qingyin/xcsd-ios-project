//
//  THNumberButton.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/8.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THNumberButton.h"
#import "UILabel+ContentSize.h"

@interface THNumberButton()
{
    UIImageView *_logoImageView;
    UILabel *_numberLabel;
}
@property (nonatomic,assign,readwrite) CGFloat adjustWidth;
@property (nonatomic,strong) UIImage *normalImage;
@property (nonatomic,strong) UIImage *highlightedImage;
@property (nonatomic,strong) UIImage *selectedImage;

@end

@implementation THNumberButton

- (instancetype)initWithFrame:(CGRect)frame
                  normalImage:(UIImage *)image
{
    return [self initWithFrame:frame normalImage:image highlightedImage:nil];
}
- (instancetype)initWithFrame:(CGRect)frame
                  normalImage:(UIImage *)image
             highlightedImage:(UIImage *)hImage
{
    return [self initWithFrame:frame normalImage:image highlightedImage:hImage selectedImage:nil];
}
- (instancetype)initWithFrame:(CGRect)frame
                  normalImage:(UIImage *)image
             highlightedImage:(UIImage *)hImage
                selectedImage:(UIImage *)sImage
{
    self = [super initWithFrame:frame];
    if (self) {
        //保存图片
        self.normalImage = image;
        self.highlightedImage = hImage;
        self.selectedImage = sImage;
        //添加图片
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        _logoImageView.image = image;
        [self addSubview:_logoImageView];
        //添加文本
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(_logoImageView.maxX, 0, 0, frame.size.height)];
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = kFontMini;
        _numberLabel.textColor = RGBCOLOR(66, 66, 66);
        [self addSubview:_numberLabel];
    }
    return self;
}
- (void)setNumberString:(NSString *)numberString
{
    _numberString = numberString;
    //设置文本和宽度
    _numberLabel.text = _numberString;
    CGFloat width = [UILabel widthForLabelWithText:_numberString maxHeight:self.frame.size.height font:kFontMini];
    _numberLabel.frame = CGRectMake(_logoImageView.maxX + 5, 0, width, self.frame.size.height);
    _adjustWidth = width + 5 + _logoImageView.width_;
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (!self.isSelected) {
        if (highlighted) {
            _logoImageView.image = self.highlightedImage;
        }else{
            _logoImageView.image = self.normalImage;
        }
    }
}
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        _logoImageView.image = self.selectedImage;
    }else{
        _logoImageView.image = self.normalImage;
    }
}
@end
