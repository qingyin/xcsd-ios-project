//
//  THQuestionView.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "THQuestionView.h"
#import "UILabel+ContentSize.h"
#import "UIImageView+EMWebCache.h"
#import "UIButton+EMWebCache.h"
#import "NSDate+TuXing.h"
#import <TXChatCommon/NSString+Photo.h>

static NSInteger const kImageViewTag = 100;

@interface THQuestionView()

@property (nonatomic,assign,readwrite) CGFloat questionHeight;
@property (nonatomic,strong) UIImageView *avatarImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *commentCountLabel;
@property (nonatomic,strong) UILabel *descLabel;
@property (nonatomic,strong) UIView  *photoView;
@property (nonatomic,strong) UIView  *lineView;

@end

@implementation THQuestionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //头像
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(13, 9, 32, 32)];
        _avatarImageView.backgroundColor = [UIColor clearColor];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.layer.cornerRadius = 4;
        [self addSubview:_avatarImageView];
        //姓名
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.maxX + 8, 15, 200, 20)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = KColorTitleTxt;
        [self addSubview:_nameLabel];
        //标题
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, _avatarImageView.maxY + 14, frame.size.width - 26, 25)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = kFontMiddle_b;
        _titleLabel.textColor = KColorTitleTxt;
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
        //时间
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, _titleLabel.maxY + 7, 150, 20)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = RGBCOLOR(83, 83, 83);
        [self addSubview:_timeLabel];
        //回复数
        _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeLabel.maxX, _timeLabel.minY, frame.size.width - _timeLabel.maxX - 13, 20)];
        _commentCountLabel.backgroundColor = [UIColor clearColor];
        _commentCountLabel.font = [UIFont systemFontOfSize:12];
        _commentCountLabel.textColor = RGBCOLOR(83, 83, 83);
        _commentCountLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_commentCountLabel];
        //详情
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, _timeLabel.maxY + 20, frame.size.width - 26, 50)];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.font = kFontTitle;
        _descLabel.textColor = KColorTitleTxt;
        _descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descLabel.numberOfLines = 0;
        [self addSubview:_descLabel];
        //图片
        _photoView = [[UIView alloc] initWithFrame:CGRectMake(13, _descLabel.maxY + 13, frame.size.width - 26, 115)];
        _photoView.backgroundColor = [UIColor clearColor];
        [self addSubview:_photoView];
        //分割线
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _photoView.maxY + 14, frame.size.width, kLineHeight)];
        _lineView.backgroundColor = kColorLine;
        [self addSubview:_lineView];
    }
    return self;
}
//图片点击方法
- (void)onImageButtonTapped:(UIButton *)btn
{
    NSInteger index = btn.tag - kImageViewTag;
    if (_delegate && [_delegate respondsToSelector:@selector(onQuestionPhotoTapped:)]) {
        [_delegate onQuestionPhotoTapped:index];
    }
}
//设置数据
- (void)setQuestionDict:(TXPBQuestion *)questionDict
{
    if (!questionDict) {
        return;
    }
    _questionDict = questionDict;
    //头像
    NSString *formatAvatarString = [_questionDict.authorAvatar getFormatPhotoUrl:64 hight:64];
    [_avatarImageView TX_setImageWithURL:[NSURL URLWithString:formatAvatarString] placeholderImage:[UIImage imageNamed:@"userDefaultIcon"]];
    //姓名
    _nameLabel.text = _questionDict.authorName;
    //标题
    NSString *titleStr = _questionDict.title;
    _titleLabel.text = titleStr;
    CGRect titleFrame = _titleLabel.frame;
    CGFloat titleHeight = [UILabel heightForLabelWithText:titleStr maxWidth:titleFrame.size.width font:kFontMiddle_b];
    titleFrame.size.height = titleHeight;
    _titleLabel.frame = titleFrame;
    //时间
    NSString *timeStr = [NSDate timeForNoticeStyle:[NSString stringWithFormat:@"%@",@(_questionDict.createOn / 1000)]];
    _timeLabel.text = timeStr;
    CGRect timeRect = _timeLabel.frame;
    timeRect.origin.y = _titleLabel.maxY + 7;
    _timeLabel.frame = timeRect;
    //回复数
    _commentCountLabel.text = [NSString stringWithFormat:@"%@人回答",@(_questionDict.replyNum)];
    _commentCountLabel.frame = CGRectMake(_timeLabel.maxX, _timeLabel.minY, _commentCountLabel.frame.size.width, 20);
    //详情
    NSString *descString = _questionDict.content;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 7;
    NSDictionary *attributes = @{NSFontAttributeName:kFontTitle,
                                 NSForegroundColorAttributeName:KColorTitleTxt,
                                 NSBackgroundColorAttributeName:[UIColor clearColor],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 };
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:descString attributes:attributes];
    _descLabel.attributedText = attString;
    CGRect descFrame = _descLabel.frame;
    CGSize size = [_descLabel sizeThatFits:CGSizeMake(descFrame.size.width, MAXFLOAT)];
    descFrame.origin.y = _timeLabel.maxY + 20;
    descFrame.size.height = size.height;
    _descLabel.frame = descFrame;
    //图片
    [_photoView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSArray *pics = _questionDict.attaches;
    if ([pics count] == 0) {
        //没有图片视图
        _photoView.frame = CGRectZero;
        _lineView.frame = CGRectMake(0, _descLabel.maxY + 14, self.frame.size.width, kLineHeight);
        //设置当前视图的frame
        CGRect frame = self.frame;
        frame.size.height = _descLabel.maxY + 15;
        self.frame = frame;
        //设置高度
        self.questionHeight = frame.size.height;
    }else{
        //单张图片视图
        _photoView.frame = CGRectMake(13, _descLabel.maxY + 13, self.frame.size.width - 26, 165);
        _lineView.frame = CGRectMake(0, _photoView.maxY + 14, self.frame.size.width, kLineHeight);
        UIButton *imgView = [UIButton buttonWithType:UIButtonTypeCustom];
        imgView.frame = CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height);
        imgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.imageView.clipsToBounds = YES;
        imgView.backgroundColor = kColorCircleBg;
        imgView.tag = kImageViewTag;
        TXPBAttach *attach = pics[0];
        NSString *formatURLString = [attach.fileurl getFormatPhotoUrl:_photoView.frame.size.width * 2 hight:_photoView.frame.size.height * 2];
        [imgView TX_setImageWithURL:[NSURL URLWithString:formatURLString] forState:UIControlStateNormal placeholderImage:nil];
        [imgView addTarget:self action:@selector(onImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_photoView addSubview:imgView];
        //添加角标视图
        UIImageView *photoCountBgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView.width_ - 27, imgView.height_ - 27, 27, 27)];
        photoCountBgView.image = [UIImage imageNamed:@"questionPhoto_jb"];
        [imgView addSubview:photoCountBgView];
        //添加图片数量标示
        UILabel *photoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(imgView.width_ - 19, imgView.height_ - 19, 20, 20)];
        photoCountLabel.backgroundColor = [UIColor clearColor];
        photoCountLabel.textAlignment = NSTextAlignmentCenter;
        photoCountLabel.font = [UIFont systemFontOfSize:10];
        photoCountLabel.textColor = [UIColor whiteColor];
        photoCountLabel.text = [NSString stringWithFormat:@"%@",@([pics count])];
        [imgView addSubview:photoCountLabel];
        //设置当前视图的frame
        CGRect frame = self.frame;
        frame.size.height = _photoView.maxY + 15;
        self.frame = frame;
        //设置高度
        self.questionHeight = frame.size.height;
    }
//    else{
//        //九宫格视图
//        NSInteger count = [pics count];
//        NSInteger columns = count > 2 ? 3 : 2;
//        NSInteger rows = ceilf(count / (CGFloat)columns);
//
//        CGFloat width = (self.frame.size.width - 13 * (columns + 1)) / columns;
//        float resizeWidth = floorf(width);
//        for (NSInteger i = 0; i < count; i++) {
//            CGRect picFrame = CGRectMake(13 + (resizeWidth + 13) * (i % columns), (resizeWidth + 13) * (i / columns), resizeWidth, resizeWidth);
//            UIButton *imgView = [UIButton buttonWithType:UIButtonTypeCustom];
//            imgView.frame = picFrame;
//            imgView.backgroundColor = kColorCircleBg;
//            imgView.tag = kImageViewTag + i;
//            imgView.imageView.contentMode = UIViewContentModeScaleAspectFill;
//            imgView.imageView.clipsToBounds = YES;
//            TXPBAttach *attach = pics[i];
//            NSString *formatURLString = [attach.fileurl getFormatPhotoUrl:resizeWidth * 2 hight:resizeWidth * 2];
//            [imgView sd_setImageWithURL:[NSURL URLWithString:formatURLString] forState:UIControlStateNormal];
//            [imgView addTarget:self action:@selector(onImageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//            [_photoView addSubview:imgView];
//        }
//        //设置当前视图的frame
//        _photoView.frame = CGRectMake(0, _descLabel.maxY + 13, self.frame.size.width, (resizeWidth + 13) * rows - 13);
//        _lineView.frame = CGRectMake(0, _photoView.maxY + 14, self.frame.size.width, kLineHeight);
//        CGRect frame = self.frame;
//        frame.size.height = _photoView.maxY + 15;
//        self.frame = frame;
//        //设置高度
//        self.questionHeight = frame.size.height;
//    }
}
- (void)setReplyNumber:(int64_t)replyNumber
{
    _replyNumber = replyNumber;
    _commentCountLabel.text = [NSString stringWithFormat:@"%@人回答",@(_replyNumber)];
}
@end
