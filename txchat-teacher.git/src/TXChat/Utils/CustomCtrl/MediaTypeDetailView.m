//
//  MediaTypeDetailView.m
//  TXChatParent
//
//  Created by lyt on 16/1/6.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "MediaTypeDetailView.h"
@interface MediaTypeDetailView()
@property(nonatomic, strong)UIView *maskView;
@end
@implementation MediaTypeDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _resourceType = 0;
        [self setupViews];
    }
    return self;
}

-(void)setupViews
{
    _iconBtnView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_iconBtnView setImage:[UIImage imageNamed:@"ablum_default"] forState:UIControlStateNormal];
    _iconBtnView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _iconBtnView.layer.masksToBounds = YES;
    [self addSubview:_iconBtnView];
    [_iconBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(self);
        make.height.mas_equalTo(self.mas_width);
    }];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.numberOfLines = 2;
    _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentLabel.font = kFontChildSection;
    _contentLabel.textColor = kColorNavigationTitle;
    _contentLabel.text = @"";
    _contentLabel.backgroundColor = kColorWhite;
    [self addSubview:_contentLabel];
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.mas_equalTo(self);
        make.top.mas_equalTo(_iconBtnView.mas_bottom).with.offset(5);
//        make.height.mas_equalTo(30);
    }];

    UIView *maskView = [[UIView alloc] init];
    _maskView = maskView;
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconBtnView.mas_left);
        make.bottom.mas_equalTo(_iconBtnView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(20, 17));
    }];
    
    _typeImgView = [[UIImageView alloc] init];
    [_typeImgView setImage:[UIImage imageNamed:@"media_audio"]];
    [self addSubview:_typeImgView];
    [_typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(maskView);
        make.centerY.mas_equalTo(maskView);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    maskView.hidden = YES;
    _typeImgView.hidden = YES;
    
    UIColor *fillColor = [UIColor colorWithWhite:0 alpha:0.1f];
    UIView *leftLine = [[UIView alloc] init];
    leftLine.backgroundColor = fillColor;
    [_iconBtnView addSubview:leftLine];
    [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconBtnView);
        make.top.mas_equalTo(_iconBtnView.mas_top).with.offset(kLineHeight);
        make.width.mas_equalTo(kLineHeight);
        make.bottom.mas_equalTo(_iconBtnView.mas_bottom).with.offset(kLineHeight);
    }];
    
    UIView *rightLine = [[UIView alloc] init];
    rightLine.backgroundColor = fillColor;
    [_iconBtnView addSubview:rightLine];
    [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_iconBtnView);
        make.top.mas_equalTo(_iconBtnView.mas_top).with.offset(kLineHeight);
        make.width.mas_equalTo(kLineHeight);
        make.bottom.mas_equalTo(_iconBtnView.mas_bottom).with.offset(kLineHeight);
    }];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = fillColor;
    [_iconBtnView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconBtnView);
        make.top.mas_equalTo(_iconBtnView.mas_top);
        make.height.mas_equalTo(kLineHeight);
        make.right.mas_equalTo(_iconBtnView);
    }];
    
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = fillColor;
    [_iconBtnView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_iconBtnView);
        make.right.mas_equalTo(_iconBtnView);
        make.height.mas_equalTo(kLineHeight);
        make.bottom.mas_equalTo(_iconBtnView.mas_bottom);
    }];
}

-(void)setResourceType:(TXPBResourceType)resourceType
{
    _resourceType = resourceType;
    switch (_resourceType) {
        case TXPBResourceTypeTAudio: {
            _typeImgView.image = [UIImage imageNamed:@"media_audio"];
            _typeImgView.hidden = NO;
            _maskView.hidden = NO;
            break;
        }
        case TXPBResourceTypeTVideo: {
            _typeImgView.image = [UIImage imageNamed:@"media_video"];
            _typeImgView.hidden = NO;
            _maskView.hidden = NO;
            break;
        }
        case TXPBResourceTypeTPicture: {
            _typeImgView.image = [UIImage imageNamed:@"media_picture"];
            _typeImgView.hidden = NO;
            _maskView.hidden = NO;
            break;
        }
        case TXPBResourceTypeTText: {
            _typeImgView.hidden = YES;
            _maskView.hidden = YES;
            break;
        }
            default:
        {
            _typeImgView.hidden = YES;
            _maskView.hidden = YES;
            break;
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
