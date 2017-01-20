//
//  PublishmentListTableViewCell.m
//  TXChat
//
//  Created by 陈爱彬 on 15/6/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "PublishmentListTableViewCell.h"
#import "HomePublishmentEntity.h"
#import "UIImageView+EMWebCache.h"

@interface PublishmentListTableViewCell()
{
    CGFloat _cellWidth;
    UILabel *_titleLabel;
    UILabel *_descriptionLabel;
    UILabel *_timeLabel;
    UIImageView *_thunbnailImageView;
    UIView *_lineView;
}
@end

@implementation PublishmentListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = width;
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = kFontLarge_1;
        _titleLabel.textColor = RGBCOLOR(16, 16, 16);
        [self.contentView addSubview:_titleLabel];
        //简介
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = kFontSubTitle;
        _descriptionLabel.textColor = KColorNewSubTitleTxt;
        _descriptionLabel.numberOfLines = 2;
        [self.contentView addSubview:_descriptionLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = kFontTimeTitle;
        _timeLabel.textColor = KColorNewTimeTxt;
        [self.contentView addSubview:_timeLabel];
        //缩略图
        _thunbnailImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _thunbnailImageView.backgroundColor = kColorCircleBg;
        _thunbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thunbnailImageView.clipsToBounds = YES;
        [self.contentView addSubview:_thunbnailImageView];
        //分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = KColorNewLine;
        [self.contentView addSubview:_lineView];
        //更新布局
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            //            make.height.equalTo(@25);
            make.top.equalTo(@10);
        }];
        [_descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.right.equalTo(_titleLabel);
            make.top.equalTo(_timeLabel.mas_bottom).offset(5);
            //            make.height.equalTo(@50);
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleLabel);
            make.right.equalTo(_titleLabel);
            make.top.equalTo(_titleLabel.mas_bottom).offset(2);
        }];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(self.contentView).offset(0);
            make.height.equalTo(@(kLineHeight));
            make.bottom.equalTo(@92);
        }];
    }
    return self;
}

- (void)setEntity:(HomePublishmentEntity *)entity
{
    _entity = entity;
    //设置是否已读
    if (_entity.isRead) {
        _titleLabel.textColor = RGBCOLOR(88, 88, 88);
    }else{
        _titleLabel.textColor = RGBCOLOR(16, 16, 16);
    }
    //设置内容
    BOOL isImageExist = NO;
    _titleLabel.text = _entity.title;
    _descriptionLabel.text = _entity.descriptionString;
    _timeLabel.text = _entity.timeString;
    if (_entity.imageUrlString && [_entity.imageUrlString length]) {
        isImageExist = YES;
        __weak typeof(UIImageView *) weakImageView = _thunbnailImageView;
        EMSDWebImageOptions option = EMSDWebImageRetryFailed | EMSDWebImageContinueInBackground;
        
        [_thunbnailImageView sd_setImageWithURL:[NSURL URLWithString:_entity.imageUrlString] placeholderImage:nil options:option completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                __strong typeof(weakImageView) strongImageView = weakImageView;
                if (strongImageView) {
                    TXAsyncRunInMain(^{
                        strongImageView.image = [UIImage imageNamed:@"tp_148x148"];
                    });
                }
            }
        }];
    }
    CGFloat rowHeight = [_entity rowHeight];
    //设置frame
    if (isImageExist) {
        _thunbnailImageView.hidden = NO;
        [_thunbnailImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(12);
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.height.equalTo(@70);
            make.width.equalTo(@70);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_thunbnailImageView.mas_right).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(@10);
        }];
    }else{
        _thunbnailImageView.hidden = YES;
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(@10);
        }];
    }
    [_lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(self.contentView).offset(0);
        make.height.equalTo(@(kLineHeight));
        make.top.equalTo(@(rowHeight - 1));
    }];

}

@end
