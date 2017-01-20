//
//  THQuestionAnswerTableViewCell.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THQuestionAnswerTableViewCell.h"
#import "UIImageView+EMWebCache.h"
#import "UILabel+ContentSize.h"
#import "NSDate+TuXing.h"
#import "THNumberButton.h"
#import "THQuestionDetailViewController.h"
#import "NSObject+EXTParams.h"
#import <UIButton+EMWebCache.h>

static UILabel *_heightCalLabel;

@interface THQuestionAnswerTableViewCell()
{
    CGFloat _cellWidth;
}
@property (nonatomic,strong) UIButton *avatarImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *positionLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *answerLabel;
@property (nonatomic,strong) THNumberButton *likeButton;
@property (nonatomic,strong) THNumberButton *commentButton;
@property (nonatomic,strong) THNumberButton *deleteButton;
@property (nonatomic,strong) UIView *lineView;

@end
@implementation THQuestionAnswerTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.top.left.bottom.equalTo(self);
        }];
        
        _cellWidth = cellWidth;
        //头像
        _avatarImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarImageView.frame = CGRectMake(13, 15, 32, 32);
        _avatarImageView.backgroundColor = kColorClear;
//        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.cornerRadius = 4;
        _avatarImageView.layer.masksToBounds = YES;
        [_avatarImageView addTarget:self action:@selector(onAvatarButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_avatarImageView];
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.maxX + 8, 13, 100, 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = kFontSubTitle;
        _nameLabel.textColor = KColorTitleTxt;
        [self.contentView addSubview:_nameLabel];
        //职位
        _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.maxX + 4, 15, 150, 20)];
        _positionLabel.backgroundColor = [UIColor clearColor];
        _positionLabel.font = [UIFont systemFontOfSize:12];
        _positionLabel.textColor = KColorTitleTxt;
        [self.contentView addSubview:_positionLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.maxX + 8, _nameLabel.maxY - 4, 200, 20)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = RGBCOLOR(83, 83, 83);
        [self.contentView addSubview:_timeLabel];
        //评论
        _answerLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.minX, _avatarImageView.maxY + 12, cellWidth - 13 - _nameLabel.minX, 30)];
        _answerLabel.backgroundColor = [UIColor clearColor];
        _answerLabel.font = kFontMiddle;
        _answerLabel.textColor = KColorTitleTxt;
        _answerLabel.numberOfLines = 6;
        _answerLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_answerLabel];
        //评论数
        _commentButton = [[THNumberButton alloc] initWithFrame:CGRectMake(cellWidth - 29, _answerLabel.maxY + 5, 16, 16) normalImage:[UIImage imageNamed:@"jsb-comment-a"] highlightedImage:[UIImage imageNamed:@"jsb-comment-b"]];
        _commentButton.backgroundColor = [UIColor clearColor];
        [_commentButton addTarget:self action:@selector(onCommentButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_commentButton];
        //赞
        _likeButton = [[THNumberButton alloc] initWithFrame:CGRectMake(_commentButton.minX - 40, _answerLabel.maxY + 5, 16, 16) normalImage:[UIImage imageNamed:@"jsb-like-a"] highlightedImage:[UIImage imageNamed:@"jsb-like-b"] selectedImage:[UIImage imageNamed:@"jsb-like-c"]];
        _likeButton.backgroundColor = [UIColor clearColor];
        [_likeButton addTarget:self action:@selector(onLikeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_likeButton];
        //删除
        _deleteButton = [[THNumberButton alloc] initWithFrame:CGRectMake(_likeButton.minX - 40, _answerLabel.maxY + 5, 16, 16) normalImage:[UIImage imageNamed:@"jsb-delete-a"] highlightedImage:[UIImage imageNamed:@"jsb-delete-b"]];
        _deleteButton.backgroundColor = [UIColor clearColor];
        [_deleteButton addTarget:self action:@selector(onDeleteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_deleteButton];
        
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.deleteButton.mas_bottom);
        }];
        //分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(13, _likeButton.maxY + 15, cellWidth - 26, kLineHeight)];
        _lineView.backgroundColor = kColorLine;
        [self.contentView addSubview:_lineView];
    }
    return self;
}

+ (UILabel *)answerLabelWithWidth:(CGFloat)width
{
    if (!_heightCalLabel) {
        _heightCalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
        _heightCalLabel.font = kFontMiddle;
        _heightCalLabel.numberOfLines = 6;
    }
    return _heightCalLabel;
}
+ (CGFloat)heightForCellWithQuestionAnswer:(TXPBQuestionAnswer *)dict
                                 cellWidth:(CGFloat)cellWidth
{
    //答案开始的位置
    CGFloat height = 15 + 32 + 12;
    //计算答案高度,13+32+8+13
    NSString *answerStr = dict.content;
//    CGFloat answerHeight = [UILabel heightForLabelWithText:answerStr maxWidth:cellWidth - 66 font:kFontMiddle];
//    height += answerHeight;
    UILabel *heightLabel = [[self class] answerLabelWithWidth:cellWidth - 66];
    heightLabel.text = answerStr;
    CGSize size = [heightLabel sizeThatFits:CGSizeMake(cellWidth - 66, MAXFLOAT)];
    height += size.height;
    //底部视图高度，5+16+15
    height += 36;
    return height;
}

- (void)setQuestionAnswer:(TXPBQuestionAnswer *)questionAnswer
{
    if (!questionAnswer) {
        return;
    }
    _questionAnswer = questionAnswer;
    //判断是否是专家，如果不是专家，return掉响应事件
    if (_questionAnswer.userType != TXPBUserTypeExpert) {
        _avatarImageView.userInteractionEnabled = NO;
    }else{
        _avatarImageView.userInteractionEnabled = YES;
    }
    //头像
    NSString *formatURLString = [_questionAnswer.authorAvatar getFormatPhotoUrl:64 hight:64];
    [_avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatURLString] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    //姓名
    NSString *nameStr = _questionAnswer.authorName;
    _nameLabel.text = nameStr;
    CGFloat nameWidth = [UILabel widthForLabelWithText:nameStr maxHeight:20 font:kFontSubTitle];
    _nameLabel.frame = CGRectMake(_avatarImageView.maxX + 8, 15, nameWidth, 20);
    //职位
    _positionLabel.text = _questionAnswer.authorTitle;
    _positionLabel.frame = CGRectMake(_nameLabel.maxX + 4, 15, _cellWidth - _nameLabel.maxX - 10, 20);
    //时间
    NSString *timeStr = [NSDate timeForNoticeStyle:[NSString stringWithFormat:@"%@",@(_questionAnswer.createOn / 1000)]];
    _timeLabel.text = timeStr;
    //描述
    NSString *answerStr = _questionAnswer.content;
    _answerLabel.text = answerStr;
//    CGFloat answerHeight = [UILabel heightForLabelWithText:answerStr maxWidth:_cellWidth - 13 - _nameLabel.minX font:kFontMiddle];
    UILabel *heightLabel = [[self class] answerLabelWithWidth:_cellWidth - 13 - _nameLabel.minX];
    heightLabel.text = answerStr;
    CGSize size = [heightLabel sizeThatFits:CGSizeMake(_cellWidth - 13 - _nameLabel.minX, MAXFLOAT)];
    _answerLabel.frame = CGRectMake(_nameLabel.minX, _avatarImageView.maxY + 12, _cellWidth - 13 - _nameLabel.minX, size.height);
    //评论数
    int64_t replyNum = 0;
    NSNumber *extReply = [_questionAnswer extParamForKey:@"replyNumber"];
    if (extReply) {
        replyNum = [extReply longLongValue];
    }else{
        replyNum = _questionAnswer.replyNum;
    }
    _commentButton.numberString = [NSString stringWithFormat:@"%@",@(replyNum)];
    CGFloat commentWidth = _commentButton.adjustWidth;
    _commentButton.frame = CGRectMake(_cellWidth - 13 - commentWidth, _answerLabel.maxY + 5, commentWidth, 16);
    //喜欢数
    int64_t thankNum = 0;
    NSNumber *extNumber = [_questionAnswer extParamForKey:@"thankNum"];
    if (extNumber) {
        thankNum = [extNumber longLongValue];
    }else{
        thankNum = _questionAnswer.thankNum;
    }
    BOOL isLike = NO;
    NSNumber *extLiked = [_questionAnswer extParamForKey:@"hasThanked"];
    if (extLiked) {
        isLike = [extLiked boolValue];
    }else{
        isLike = _questionAnswer.hasThanked;
    }
    [_likeButton setSelected:isLike];
    _likeButton.numberString = [NSString stringWithFormat:@"%@",@(thankNum)];
    CGFloat likeWidth = _likeButton.adjustWidth;
    _likeButton.frame = CGRectMake(_commentButton.minX - 24 - likeWidth, _answerLabel.maxY + 5, likeWidth, 16);
    //删除
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (currentUser && currentUser.userId == _questionAnswer.authorId) {
        _deleteButton.hidden = NO;
        _deleteButton.frame = CGRectMake(_likeButton.minX - 50, _answerLabel.maxY + 5, 16, 16);
    }else{
        _deleteButton.hidden = YES;
    }
    //分割线
    _lineView.frame = CGRectMake(13, _likeButton.maxY + 14, _cellWidth - 26, kLineHeight);
}
//回复
- (void)onCommentButtonTapped
{
    if ([_detailVc respondsToSelector:@selector(replyAnswerWithComment:)]) {
        [_detailVc replyAnswerWithComment:_questionAnswer];
    }
}
//喜欢
- (void)onLikeButtonTapped
{
    if ([_detailVc respondsToSelector:@selector(likeAnswerWithComment:)]) {
        [_detailVc likeAnswerWithComment:_questionAnswer];
    }
}
//删除
- (void)onDeleteButtonTapped
{
    if ([_detailVc respondsToSelector:@selector(deleteAnswerWithId:)]) {
        [_detailVc deleteAnswerWithId:_questionAnswer.id];
    }
}
//头像
- (void)onAvatarButtonTapped
{
    if ([_detailVc respondsToSelector:@selector(onAvtarTappedWithComment:)]) {
        [_detailVc onAvtarTappedWithComment:_questionAnswer];
    }
}
@end
