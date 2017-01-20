//
//  TXChatListTableViewCell.m
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "TXChatListTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import <SDiPhoneVersion.h>
#import "CommonUtils.h"
#import "UIImageView+TXSDImage.h"

@interface TXChatListTableViewCell()
{
    BOOL _is6Plus;
    CGFloat _cellWidth;
    UIImageView *_avatarImageView;
    UIImageView *_maskImageView;
    UILabel *_conversationTitleLabel;
    UILabel *_detailMsgLabel;
    UILabel *_timeLabel;
//    UIImageView *_unReadImageView;
    UIView *_unReadImageView;
    UILabel *_unReadCountLabel;
    UIView *_lineView;
}
@end

@implementation TXChatListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = width;
        _is6Plus = NO;
        if ([SDiPhoneVersion deviceSize] == iPhone55inch) {
            _is6Plus = YES;
        }
        self.contentView.backgroundColor = [UIColor whiteColor];
        //头像
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.backgroundColor = [UIColor clearColor];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 4;
        _avatarImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_avatarImageView];
        //标题
        _conversationTitleLabel = [[UILabel alloc] init];
        _conversationTitleLabel.backgroundColor = [UIColor clearColor];
        _conversationTitleLabel.font = kMessageFontTitle;
        _conversationTitleLabel.textColor = KColorNewTitleTxt;
        [self.contentView addSubview:_conversationTitleLabel];
        //副标题
        _detailMsgLabel = [[UILabel alloc] init];
        _detailMsgLabel.backgroundColor = [UIColor clearColor];
        _detailMsgLabel.font = kMessageFontSubTitle;
        _detailMsgLabel.textColor = KColorNewSubTitleTxt;
        [self.contentView addSubview:_detailMsgLabel];
        //时间
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = kMessageFontTimeTitle;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.textColor = KColorNewTimeTxt;
        [self.contentView addSubview:_timeLabel];
        //未读数
        _unReadImageView = [[UIView alloc] init];
        _unReadImageView.backgroundColor = RGBCOLOR(0xef, 0x38, 0x38);
        _unReadImageView.layer.masksToBounds = YES;
        _unReadImageView.layer.cornerRadius = 8;
//        _unReadImageView.clipsToBounds = YES;
        [self.contentView addSubview:_unReadImageView];
        _unReadCountLabel = [[UILabel alloc] init];
        _unReadCountLabel.backgroundColor = [UIColor clearColor];
        _unReadCountLabel.textColor = [UIColor whiteColor];
        _unReadCountLabel.font = [UIFont systemFontOfSize:11];
        _unReadCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_unReadCountLabel];
        //分割线
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = KColorNewLine;
        [self.contentView addSubview:_lineView];
        if (_is6Plus) {
            _avatarImageView.frame = CGRectMake(14, 14, 47, 47);
            _conversationTitleLabel.font = [UIFont systemFontOfSize:17];
            _conversationTitleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 14, 12, width - 130 - CGRectGetMaxX(_avatarImageView.frame), 30);
            _detailMsgLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 14, CGRectGetMaxY(_conversationTitleLabel.frame) - 4, width - 20 - CGRectGetMaxX(_avatarImageView.frame), 25);
            _timeLabel.frame = CGRectMake(width - 117, 12, 105, 20);
            _unReadImageView.frame = CGRectMake(52, 6, 16, 16);
            _unReadCountLabel.frame = CGRectMake(52, 6, 16, 15);
            _lineView.frame = CGRectMake(10, 74, width - 10, kLineHeight);
        }else{
            _avatarImageView.frame = CGRectMake(10, 12, 40, 40);
            _conversationTitleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 10, 7, width - 125 - CGRectGetMaxX(_avatarImageView.frame), 30);
            _detailMsgLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 10, CGRectGetMaxY(_conversationTitleLabel.frame) - 7, width - 20 - CGRectGetMaxX(_avatarImageView.frame), 25);
            _timeLabel.frame = CGRectMake(width - 115, 8, 105, 20);
            _unReadImageView.frame = CGRectMake(42, 5, 16, 16);
            _unReadCountLabel.frame = CGRectMake(42, 5, 16, 16);
            _lineView.frame = CGRectMake(10, 63, width - 10, kLineHeight);
        }
    }
    return self;
}

- (void)setConversationData:(id<TXChatConversationData>)itemData
{
    if (!itemData) {
        return;
    }
    _conversationData = itemData;
    //图片名称
    [_avatarImageView TX_setImageWithURL:[NSURL URLWithString:[_conversationData avatarRemoteUrlString]] placeholderImage: itemData.isService ? [UIImage imageNamed:@"xx_customService"] : [UIImage imageNamed:_conversationData.avatarImageName]];
    //标题
    _conversationTitleLabel.text = _conversationData.displayName;
    //详细内容
    _detailMsgLabel.text = _conversationData.detailMsg;
    //时间
    _timeLabel.text = _conversationData.time;
    //设置frame
    if (_detailMsgLabel.text && [_detailMsgLabel.text length]) {
        //有详情内容
        if (_is6Plus) {
            _conversationTitleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 14, 12, _cellWidth - 130 - CGRectGetMaxX(_avatarImageView.frame), 30);
            _detailMsgLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 14, CGRectGetMaxY(_conversationTitleLabel.frame) - 4, _cellWidth - 20 - CGRectGetMaxX(_avatarImageView.frame), 25);
        }else{
            _conversationTitleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 10, 7, _cellWidth - 125 - CGRectGetMaxX(_avatarImageView.frame), 30);
            _detailMsgLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 10, CGRectGetMaxY(_conversationTitleLabel.frame) - 7, _cellWidth - 20 - CGRectGetMaxX(_avatarImageView.frame), 25);
        }
    }else {
        //无详情内容
        if (_is6Plus) {
            _conversationTitleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 14, 22, _cellWidth - 135 - CGRectGetMaxX(_avatarImageView.frame), 30);
        }else{
            _conversationTitleLabel.frame = CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + 10, 17, _cellWidth - 125 - CGRectGetMaxX(_avatarImageView.frame), 30);
        }
    }
    //未读数
    if ([itemData isEnableShowRedDot]) {
        NSInteger count = [itemData unReadCount];
        if (count == 0) {
            _unReadImageView.hidden = YES;
            _unReadCountLabel.hidden = YES;
        }else{
            _unReadImageView.hidden = NO;
            if ([itemData isEnableUnreadCountDisplay]) {
                if (_is6Plus) {
                    CGFloat width = 16;
                    CGFloat startX = 52;
                    if (count >= 100) {
                        width = 28;
                        startX = 40;
                    }else if (count >= 10) {
                        width = 21;
                        startX = 47;
                    }
                    _unReadImageView.frame = CGRectMake(startX, 6, width, 16);
                    _unReadCountLabel.frame = CGRectMake(startX, 6, width, 16);
                    _unReadImageView.layer.cornerRadius = 8.f;
                    _unReadCountLabel.hidden = NO;
                    if (count >= 100) {
                        _unReadCountLabel.text = @"99+";
                    }else{
                        _unReadCountLabel.text = [NSString stringWithFormat:@"%@",@(count)];
                    }
                }else{
                    CGFloat width = 16;
                    CGFloat startX = 42;
                    if (count >= 100) {
                        width = 28;
                        startX = 30;
                    }else if (count >= 10) {
                        width = 21;
                        startX = 37;
                    }
                    _unReadImageView.frame = CGRectMake(startX, 5, width, 16);
                    _unReadCountLabel.frame = CGRectMake(startX, 5, width, 16);
                    _unReadImageView.layer.cornerRadius = 8.f;
                    _unReadCountLabel.hidden = NO;
                    if (count >= 100) {
                        _unReadCountLabel.text = @"99+";
                    }else{
                        _unReadCountLabel.text = [NSString stringWithFormat:@"%@",@(count)];
                    }
                }
            }else{
                if (_is6Plus) {
                    _unReadImageView.frame = CGRectMake(55, 9, 10, 10);
                    _unReadImageView.layer.cornerRadius = 5.f;
                    _unReadCountLabel.hidden = YES;
                }else{
                    _unReadImageView.frame = CGRectMake(45, 8, 10, 10);
                    _unReadImageView.layer.cornerRadius = 5.f;
                    _unReadCountLabel.hidden = YES;
                }
            }
        }
    }else{
        _unReadImageView.hidden = YES;
        _unReadCountLabel.hidden = YES;
    }
}

- (void)setIsBottomCell:(BOOL)isBottomCell
{
    _isBottomCell = isBottomCell;
    _lineView.hidden = _isBottomCell;
}
//防止点击时红点被系统修改为透明色
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        _unReadImageView.backgroundColor = RGBCOLOR(0xef, 0x38, 0x38);
    }
}
@end
