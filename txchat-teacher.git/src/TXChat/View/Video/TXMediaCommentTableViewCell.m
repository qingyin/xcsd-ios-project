//
//  TXMediaCommentTableViewCell.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/19.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXMediaCommentTableViewCell.h"
#import "NSDate+TuXing.h"

static UILabel *_heightCalLabel;

@interface TXMediaCommentTableViewCell()
{
    CGFloat _cellWidth;
}
@property (nonatomic,strong) UIImageView *thumbImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *commentLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIView *lineView;

@end

@implementation TXMediaCommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = cellWidth;
        //头像
        _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 30, 30)];
        _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImageView.layer.cornerRadius = 1.f;
        _thumbImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_thumbImageView];
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 15, 150, 15)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = RGBCOLOR(0x49, 0x68, 0x77);
        [self.contentView addSubview:_nameLabel];
        //评论
        _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 35, _cellWidth - 58, 40)];
        _commentLabel.backgroundColor = [UIColor clearColor];
        _commentLabel.font = [UIFont systemFontOfSize:14];
        _commentLabel.textColor = RGBCOLOR(0x48, 0x48, 0x48);
        _commentLabel.numberOfLines = 0;
        [self.contentView addSubview:_commentLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.maxX, 15, _cellWidth - _nameLabel.maxX - 10, 10)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = kFontTimeTitle;
        _timeLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.tag = 4;
        [self.contentView addSubview:_timeLabel];
        //分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 75, _cellWidth - 10, kLineHeight)];
        _lineView.backgroundColor = KColorResourceLine;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

+ (UILabel *)commentLabelWithWidth:(CGFloat)width
{
    if (!_heightCalLabel) {
        _heightCalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
        _heightCalLabel.font = [UIFont systemFontOfSize:14];
        _heightCalLabel.numberOfLines = 0;
    }
    return _heightCalLabel;
}

+ (CGFloat)heightForCellWithMediaComment:(TXComment *)dict
                               cellWidth:(CGFloat)cellWidth
{
    //评论开始的位置
    CGFloat height = 35;
    NSString *commentStr = dict.content;
    UILabel *heightLabel = [[self class] commentLabelWithWidth:cellWidth - 58];
    heightLabel.text = commentStr;
    CGSize size = [heightLabel sizeThatFits:CGSizeMake(cellWidth - 58, MAXFLOAT)];
    height += size.height;
    height += 10;
    return height;
}

- (void)setComment:(TXComment *)comment
{
    if (!comment) {
        return;
    }
    _comment = comment;
    NSString *formatURLString = [comment.userAvatarUrl getFormatPhotoUrl:64 hight:64];
    [_thumbImageView TX_setImageWithURL:[NSURL URLWithString:formatURLString] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    _nameLabel.text = comment.userNickname;
    NSString *timeStr = [NSDate timeForNoticeStyle:[NSString stringWithFormat:@"%@",@(comment.createdOn / 1000)]];
    _timeLabel.text = timeStr;
    _commentLabel.text = comment.content;
    CGSize size = [_commentLabel sizeThatFits:CGSizeMake(_cellWidth - 58, MAXFLOAT)];
    _commentLabel.frame = CGRectMake(48, 35, size.width, size.height);
    _lineView.frame = CGRectMake(10, _commentLabel.maxY + 9, _cellWidth - 10, kLineHeight);
}
@end
