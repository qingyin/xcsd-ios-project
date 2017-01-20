//
//  THAnswerCommentTableViewCell.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/2.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THAnswerCommentTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "UILabel+ContentSize.h"
#import "MLEmojiLabel.h"
#import "THAnswerDetailViewController.h"
#import "NSDate+TuXing.h"

static MLEmojiLabel *_heightCalLabel;

@interface THAnswerCommentTableViewCell()
<MLEmojiLabelDelegate>
{
    CGFloat _cellWidth;
}
@property (nonatomic,strong) UIImageView *avatarImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) MLEmojiLabel *commentLabel;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *replyButton;
@property (nonatomic,strong) UIView *lineView;

@end

@implementation THAnswerCommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellWidth = cellWidth;
        //头像
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 15, 32, 32)];
        _avatarImageView.backgroundColor = kColorClear;
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 4;
        _avatarImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_avatarImageView];
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.maxX + 8, 13, 100, 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = kFontSubTitle;
        _nameLabel.textColor = KColorTitleTxt;
        [self.contentView addSubview:_nameLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.maxX + 8, _nameLabel.maxY - 4, 200, 20)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = RGBCOLOR(83, 83, 83);
        [self.contentView addSubview:_timeLabel];
        //回复
        _commentLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(_nameLabel.minX, _avatarImageView.maxY + 12, cellWidth - 13 - _nameLabel.minX, 30)];
        _commentLabel.backgroundColor = kColorClear;
        _commentLabel.disableThreeCommon = YES;
        _commentLabel.font = kFontMiddle;
        _commentLabel.emojiDelegate = self;
        [_commentLabel setTextColor:KColorTitleTxt];
        NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
        [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor clearColor] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
        _commentLabel.activeLinkAttributes = mutableActiveLinkAttributes;
        _commentLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _commentLabel.numberOfLines = 0;
        [self.contentView addSubview:_commentLabel];
        //回复
        _replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _replyButton.frame = CGRectMake(cellWidth - 29, _commentLabel.maxY + 5, 16, 16);
        [_replyButton setImage:[UIImage imageNamed:@"jsb-comment-a"] forState:UIControlStateNormal];
        [_replyButton setImage:[UIImage imageNamed:@"jsb-comment-b"] forState:UIControlStateHighlighted];
        [_replyButton addTarget:self action:@selector(onCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_replyButton];
        //删除
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(cellWidth - 85, _commentLabel.maxY + 5, 16, 16);
        [_deleteButton setImage:[UIImage imageNamed:@"jsb-delete-a"] forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage imageNamed:@"jsb-delete-b"] forState:UIControlStateHighlighted];
        [_deleteButton addTarget:self action:@selector(onDeleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
        //分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(13, _replyButton.maxY + 15, cellWidth - 26, kLineHeight)];
        _lineView.backgroundColor = kColorLine;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

+ (MLEmojiLabel *)commentLabelWithWidth:(CGFloat)width
{
    if (!_heightCalLabel) {
        _heightCalLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        _heightCalLabel.backgroundColor = kColorClear;
        _heightCalLabel.disableThreeCommon = YES;
        _heightCalLabel.font = kFontMiddle;
        [_heightCalLabel setTextColor:KColorTitleTxt];
        NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
        [mutableActiveLinkAttributes setValue:(__bridge id)[[UIColor clearColor] CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
        _heightCalLabel.activeLinkAttributes = mutableActiveLinkAttributes;
        _heightCalLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _heightCalLabel.numberOfLines = 0;
    }
    return _heightCalLabel;
}

+ (CGFloat)heightForCellWithAnswerComment:(TXComment *)dict
                                cellWidth:(CGFloat)cellWidth
{
    //回复开始的位置
    CGFloat height = 15 + 32 + 12;
    //计算回复高度,13+32+8+13
    NSString *commentStr = dict.content;
    int64_t replyId = dict.toUserId;
    int64_t commentUserId = dict.userId;
    NSString *replyName = dict.toUserNickname;
    if (replyId != 0 && replyName && [replyName length]) {
        if (commentUserId == replyId) {
            NSString *replyStr = @"回复 自己 :";
            commentStr = [replyStr stringByAppendingString:commentStr];
        }else{
            NSString *replyStr = [NSString stringWithFormat:@"回复 %@ :",replyName];
            commentStr = [replyStr stringByAppendingString:commentStr];
        }
    }
    MLEmojiLabel *heightLabel = [[self class] commentLabelWithWidth:cellWidth - 66];
    [heightLabel setEmojiText:commentStr];
    CGSize size = [heightLabel sizeThatFits:CGSizeMake(cellWidth - 66, MAXFLOAT)];
    height += size.height;
    //底部视图高度，5+16+15
    height += 36;
    return height;
}

- (void)setAnswerComment:(TXComment *)answerComment
{
    if (!answerComment) {
        return;
    }
    _answerComment = answerComment;
    //头像
    NSString *formatURLString = [_answerComment.userAvatarUrl getFormatPhotoUrl:64 hight:64];
    [_avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatURLString] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    //姓名
    NSString *nameStr = _answerComment.userNickname;
    _nameLabel.text = nameStr;
    CGFloat nameWidth = [UILabel widthForLabelWithText:nameStr maxHeight:20 font:kFontSubTitle];
    _nameLabel.frame = CGRectMake(_avatarImageView.maxX + 8, 15, nameWidth, 20);
    //时间
    NSString *timeStr = [NSDate timeForNoticeStyle:[NSString stringWithFormat:@"%@",@(_answerComment.createdOn / 1000)]];
    _timeLabel.text = timeStr;
    //描述
    _commentLabel.feedComment = _answerComment;
    NSString *answerStr = _answerComment.content;
    NSString *replyName = _answerComment.toUserNickname;
    int64_t toUserId = _answerComment.toUserId;
    NSString *userName = _answerComment.userNickname;
    int64_t replyId = _answerComment.userId;
    if (replyId != 0 && replyName && [replyName length]) {
        _commentLabel.replyUserName = userName;
        _commentLabel.replyUser = @(replyId);
        if (replyId == toUserId) {
            replyName = @"自己";
        }
        NSString *replyStr = [NSString stringWithFormat:@"回复 %@ :",replyName];
        answerStr = [replyStr stringByAppendingString:answerStr];
    }
    [_commentLabel setEmojiText:answerStr];
    CGSize size = [_commentLabel sizeThatFits:CGSizeMake(_cellWidth - 13 - _nameLabel.minX, MAXFLOAT)];
    _commentLabel.frame = CGRectMake(_nameLabel.minX, _avatarImageView.maxY + 12, _cellWidth - 13 - _nameLabel.minX, size.height);
    if (replyName && replyName.length) {
        [_commentLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",@(replyId)]] withRange:[answerStr rangeOfString:replyName]];
    }
    //回复
    _replyButton.frame = CGRectMake(_cellWidth - 29, _commentLabel.maxY + 5, 16, 16);
    //删除
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (currentUser && currentUser.userId == answerComment.userId) {
        _deleteButton.hidden = NO;
        _deleteButton.frame = CGRectMake(_cellWidth - 85, _commentLabel.maxY + 5, 16, 16);
    }else{
        _deleteButton.hidden = YES;
    }
    //分割线
    _lineView.frame = CGRectMake(13, _replyButton.maxY + 14, _cellWidth - 26, kLineHeight);
}

- (void)attributedLabel:(MLEmojiLabel *)emojiLabel didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result
{
    NSString *replyName = emojiLabel.replyUserName;
    NSString *replyId = emojiLabel.replyUser;
//    NSDictionary *comment = emojiLabel.feedComment;
    if (!result) {
        //回复这条评论
        [self onCommentButtonTapped];
    }else{
        //回复这条评论
        if (_answerVc && [_answerVc respondsToSelector:@selector(replyCommentWithUserName:userId:comment:)]) {
            [_answerVc replyCommentWithUserName:replyName userId:[replyId longLongValue] comment:_answerComment];
        }
    }
}
- (void)onCommentButtonTapped
{
    //回复这条评论
    NSString *userName = _answerComment.userNickname;
    int64_t replyId = _answerComment.userId;
    if (_answerVc && [_answerVc respondsToSelector:@selector(replyCommentWithUserName:userId:comment:)]) {
        [_answerVc replyCommentWithUserName:userName userId:replyId comment:_answerComment];
    }
}
- (void)onDeleteButtonTapped
{
    //删除这条评论
    if (_answerVc && [_answerVc respondsToSelector:@selector(deleteCommentWithId:)]) {
        [_answerVc deleteCommentWithId:_answerComment.commentId];
    }
}
@end
