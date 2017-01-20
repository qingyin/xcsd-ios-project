//
//  THQuestionListTableViewCell.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THQuestionListTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "NSDate+TuXing.h"
#import "NSObject+EXTParams.h"
#import "NSString+Additions.h"
#import <TXChatCommon/NSString+Photo.h>

@interface THQuestionListTableViewCell()
{
    CGFloat _cellWidth;
    UIImageView *_avatarImageView;
    UILabel *_nameLabel;
    UILabel *_timeLabel;
    UILabel *_titleLabel;
    UILabel *_contentLabel;
    UILabel *_commentCountLabel;
}
@property (nonatomic,strong) NSDictionary *attributes;
@end

@implementation THQuestionListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)width
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(self);
            make.bottom.mas_equalTo(0);
        }];
        
        _cellWidth = width;
        //白色背景底
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
        bgView.backgroundColor = kColorWhite;
        [self.contentView addSubview:bgView];
        //头像
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarImageView.backgroundColor = kColorCircleBg;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.layer.cornerRadius = 4;
        [self.contentView addSubview:_avatarImageView];
        //名称
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:13];
        _nameLabel.textColor = RGBCOLOR(0x7a, 0x8b, 0x9b);
        [self.contentView addSubview:_nameLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:9];
        _timeLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        [self.contentView addSubview:_timeLabel];
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = KColorTitleTxt;
        [self.contentView addSubview:_titleLabel];
        //简介
        UIFont *font = [UIFont systemFontOfSize:14];
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = font;
        _contentLabel.textColor = KColorTitleTxt;
        _contentLabel.numberOfLines = 2;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_contentLabel];
        //评论数
        _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:10];
        _commentCountLabel.textAlignment = NSTextAlignmentRight;
        _commentCountLabel.textColor = RGBCOLOR(0x83, 0x83, 0x83);
        [self.contentView addSubview:_commentCountLabel];
        //更新布局
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.left.equalTo(self.contentView).offset(0);
            make.right.equalTo(self.contentView).offset(0);
            make.bottom.equalTo(self.contentView).offset(0);
        }];
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.width.equalTo(@28);
            make.height.equalTo(@28);
            make.top.equalTo(@13);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(8);
            make.right.equalTo(_commentCountLabel.mas_left).offset(-5);
            make.top.equalTo(_avatarImageView);
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(8);
//            make.top.equalTo(_nameLabel.mas_bottom).offset(6);
            make.bottom.equalTo(_avatarImageView);
            make.width.equalTo(_nameLabel);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(_avatarImageView.mas_bottom).offset(8);
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kEdgeInsetsLeft);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
            make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        }];
        [_commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_nameLabel);
            make.right.equalTo(self.contentView).offset(-kEdgeInsetsLeft);
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

+ (CGFloat)heightForCellWithQuestion:(TXPBQuestion *)dict
                        contentWidth:(CGFloat)contentWidth
{
    NSInteger lines = 0;
    NSNumber *lineNumber = [dict extParamForKey:@"contentLine"];
    if (lineNumber) {
        lines = [lineNumber integerValue];
    }else{
        if (!dict.content || ![dict.content length]) {
            lines = 0;
        }else{
            lines = [dict.content numberOfLinesWithConstrainedToWidth:contentWidth - 20 fromFont:[UIFont systemFontOfSize:14] lineSpace:3];
            if (lines > 1) {
                lines = 2;
            }
        }
        [dict setTXExtParams:@(lines) forKey:@"contentLine"];
    }
    if (lines == 0) {
        return 76;
    }else if (lines == 1) {
        return 96;
    }else{
        return 116;
    }
}

+ (CGFloat)heightForCellWithCommunion:(TXPBCommunionMessage *)dict
                         contentWidth:(CGFloat)contentWidth
{
    NSInteger lines = 0;
    NSNumber *lineNumber = [dict extParamForKey:@"contentLine"];
    if (lineNumber) {
        lines = [lineNumber integerValue];
    }else{
        if (!dict.content || ![dict.content length]) {
            lines = 0;
        }else{
            lines = [dict.content numberOfLinesWithConstrainedToWidth:contentWidth - 20 fromFont:[UIFont systemFontOfSize:14] lineSpace:3];
            if (lines > 1) {
                lines = 2;
            }
        }
        [dict setTXExtParams:@(lines) forKey:@"contentLine"];
    }
    if (lines == 0) {
        return 76;
    }else if (lines == 1) {
        return 96;
    }else{
        return 116;
    }
}

- (void)setQuestionDict:(TXPBQuestion *)questionDict
{
    if (questionDict == nil) {
        return;
    }
    _questionDict = questionDict;
    NSString *formatAvatarString = [_questionDict.authorAvatar getFormatPhotoUrl:60 hight:60];
    [_avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatAvatarString] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    _nameLabel.text = _questionDict.authorName;
    NSString *timeStr = [NSDate timeForShortStyle:[NSString stringWithFormat:@"%@",@(_questionDict.createOn / 1000)]];
    _timeLabel.text = timeStr;
    _titleLabel.text = _questionDict.title;
    //设置content
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:_questionDict.content attributes:_attributes];
    _contentLabel.attributedText = attString;
    //回答数
    int64_t replyNum = 0;
    NSNumber *extNumber = [_questionDict extParamForKey:@"replyNumber"];
    if (extNumber) {
        replyNum = [extNumber longLongValue];
    }else{
        replyNum = _questionDict.replyNum;
    }
    _commentCountLabel.text = [NSString stringWithFormat:@"%@人回答",@(replyNum)];
}

- (void)setCommunionMessage:(TXPBCommunionMessage *)communionMessage
{
    if (communionMessage == nil) {
        return;
    }
    _communionMessage = communionMessage;
    NSString *formatAvatarString = [_communionMessage.optUserAvater getFormatPhotoUrl:60 hight:60];
    [_avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatAvatarString] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    _nameLabel.text = _communionMessage.optUserName;
    NSString *userTitle = _communionMessage.optUserTitle;
    _timeLabel.text = userTitle;
    _titleLabel.text = _communionMessage.title;
    //设置content
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:_communionMessage.content attributes:_attributes];
    _contentLabel.attributedText = attString;
    //操作类型
    _commentCountLabel.text = [self communionTipForMessage:_communionMessage];
    //更新布局
    if (userTitle && [userTitle length]) {
        //有称谓
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(8);
            make.right.equalTo(_commentCountLabel.mas_left).offset(-5);
            make.top.equalTo(_avatarImageView);
        }];
    }else{
        //无称谓
        [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(8);
            make.right.equalTo(_commentCountLabel.mas_left).offset(-5);
            make.centerY.equalTo(_avatarImageView);
        }];
    }
}
//获取表述的字符串
- (NSString *)communionTipForMessage:(TXPBCommunionMessage *)message
{
    NSString *communionTip = @"";
    TXPBCommunionAction action = message.action;
    NSString *objString = [self communionObjTypeStringWithMessage:message];
    switch (action) {
        case TXPBCommunionActionAAnswer: {
            //回答
            communionTip = [NSString stringWithFormat:@"回答了%@",objString];
            break;
        }
        case TXPBCommunionActionAThank: {
            //感谢
            communionTip = [NSString stringWithFormat:@"对%@表示感谢",objString];
            break;
        }
        case TXPBCommunionActionAFavorite: {
            //收藏
            communionTip = [NSString stringWithFormat:@"收藏了%@",objString];
            break;
        }
        case TXPBCommunionActionAFollow: {
            //收藏
            communionTip = [NSString stringWithFormat:@"关注了%@",objString];
            break;
        }
        case TXPBCommunionActionAReply: {
            //收藏
            communionTip = [NSString stringWithFormat:@"回复了%@",objString];
            break;
        }
        default: {
            break;
        }
    }
    return communionTip;
}
- (NSString *)communionObjTypeStringWithMessage:(TXPBCommunionMessage *)message
{
    NSString *objString = @"";
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    BOOL isTargetMe = NO;
    if (currentUser.userId == message.toUserId) {
        //针对我的操作
        isTargetMe = YES;
    }
    TXPBCommunionObjType objType = message.objType;
    switch (objType) {
        case TXPBCommunionObjTypeTQuestion: {
            //问题
            if (isTargetMe) {
                objString = @"你的问题";
            }else{
                objString = @"该问题";
            }
            break;
        }
        case TXPBCommunionObjTypeTKnowledge: {
            //宝典文章
            if (isTargetMe) {
                objString = @"你的文章";
            }else{
                objString = @"该文章";
            }
            break;
        }
        case TXPBCommunionObjTypeTExpert: {
            //专家
            if (isTargetMe) {
                objString = @"你";
            }else{
                objString = @"该专家";
            }
            break;
        }
        case TXPBCommunionObjTypeTAnswer: {
            //答案
            if (isTargetMe) {
                objString = @"你的答案";
            }else{
                objString = @"该答案";
            }
            break;
        }
        default: {
            break;
        }
    }
    return objString;

}
- (void)setIsRead:(BOOL)isRead
{
    _isRead = isRead;
    //设置已读状态
    if (_isRead) {
        _titleLabel.textColor = RGBCOLOR(130, 130, 130);
        _contentLabel.textColor = RGBCOLOR(130, 130, 130);
    }else{
        _titleLabel.textColor = KColorTitleTxt;
        _contentLabel.textColor = KColorTitleTxt;
    }

}
@end
