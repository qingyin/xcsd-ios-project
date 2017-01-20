//
//  WXYArticleTableViewCell.m
//  WeiXueYuanDemo
//
//  Created by 陈爱彬 on 15/5/25.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "WXYArticleTableViewCell.h"
#import "WXYArticle.h"
#import "UIImageView+EMWebCache.h"
#import "UILabel+ContentSize.h"

static NSInteger const kArticleButtonTag = 100;
static CGFloat const kTimeFontSize = 12;

@interface WXYArticleTableViewCell()
{
    CGFloat screenWidth;
    //时间
    UILabel *_timeLabel;
    //焦点图或者普通图承载背景view
    UIView *_articleContentView;
    //新闻类型视图
    UIView *_newsContentView;
    UIButton *_newsContentButton;
    UILabel *_newsTitleLabel;
    UIImageView *_newsImageView;
    UILabel *_newsSummaryLabel;
    UIView *_newsLineView;
    UILabel *_newsReadLabel;
    UIImageView *_newsArrowImageView;
}
@end

@implementation WXYArticleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
        //时间视图
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, screenWidth - 260, 20)];
        _timeLabel.backgroundColor = [UIColor colorWithRed:195.f/255.f green:195.f/255.f blue:195.f/255.f alpha:1.f];
        _timeLabel.layer.cornerRadius = 5.f;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.font = [UIFont systemFontOfSize:kTimeFontSize];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_timeLabel];
        //焦点图或者普通图承载背景view
        if ([reuseIdentifier isEqualToString:@"normalCellIndentify"]) {
            _articleContentView = [[UIView alloc] initWithFrame:CGRectMake(15, 48, screenWidth - 30, 40)];
            _articleContentView.backgroundColor = [UIColor whiteColor];
            _articleContentView.layer.masksToBounds = YES;
            _articleContentView.layer.cornerRadius = 5.f;
            _articleContentView.layer.borderWidth = kLineHeight;
            _articleContentView.layer.borderColor = RGBCOLOR(201, 202, 202).CGColor;
            [self.contentView addSubview:_articleContentView];
        }else{
            /*新闻类型视图*/
            _newsContentView = [[UIView alloc] initWithFrame:CGRectMake(15, 48, screenWidth - 30, 40)];
            _newsContentView.backgroundColor = [UIColor whiteColor];
            _newsContentView.layer.masksToBounds = YES;
            _newsContentView.layer.cornerRadius = 5.f;
            _newsContentView.layer.borderWidth = kLineHeight;
            _newsContentView.layer.borderColor = RGBCOLOR(201, 202, 202).CGColor;
            [self.contentView addSubview:_newsContentView];
            //按钮
            _newsContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _newsContentButton.tag = kArticleButtonTag;
            _newsContentButton.backgroundColor = [UIColor clearColor];
            [_newsContentButton setBackgroundImage:nil forState:UIControlStateNormal];
            [_newsContentButton setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:223.f/255.f green:223.f/255.f blue:223.f/255.f alpha:1.f]] forState:UIControlStateHighlighted];
            _newsContentButton.frame = CGRectMake(0, 0, CGRectGetWidth(_newsContentView.frame), CGRectGetHeight(_newsContentView.frame));
            [_newsContentButton addTarget:self action:@selector(onArticleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_newsContentView addSubview:_newsContentButton];
            //标题
            _newsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screenWidth - 80, 30)];
            _newsTitleLabel.backgroundColor = [UIColor clearColor];
            _newsTitleLabel.textColor = [UIColor blackColor];
            _newsTitleLabel.font = [UIFont systemFontOfSize:NewsArticleTitleFontSize];
            _newsTitleLabel.numberOfLines = 0;
            [_newsContentView addSubview:_newsTitleLabel];
            //图片
            _newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, screenWidth - 50, NewsArticleImageHeight)];
            _newsImageView.backgroundColor = [UIColor colorWithRed:232.f/255.f green:232.f/255.f blue:232.f/255.f alpha:1.f];
            _newsImageView.contentMode = UIViewContentModeScaleAspectFill;
            _newsImageView.clipsToBounds = YES;
            [_newsContentView addSubview:_newsImageView];
            //简介
            _newsSummaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, screenWidth - 50, 30)];
            _newsSummaryLabel.backgroundColor = [UIColor clearColor];
            _newsSummaryLabel.textColor = [UIColor grayColor];
            _newsSummaryLabel.font = [UIFont systemFontOfSize:NewsArticleSummaryFontSize];
            _newsSummaryLabel.numberOfLines = 0;
            [_newsContentView addSubview:_newsSummaryLabel];
            //分割线
            _newsLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(_newsContentView.frame), kLineHeight)];
            _newsLineView.backgroundColor = [UIColor colorWithRed:235.f/255.f green:237.f/255.f blue:240.f/255.f alpha:1.f];
            [_newsContentView addSubview:_newsLineView];
            //阅读全文
            _newsReadLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 200, 35)];
            _newsReadLabel.backgroundColor = [UIColor clearColor];
            _newsReadLabel.textColor = [UIColor blackColor];
            _newsReadLabel.font = [UIFont systemFontOfSize:14];
            _newsReadLabel.text = @"阅读全文";
            [_newsContentView addSubview:_newsReadLabel];
            //设置箭头
            _newsArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 8, 12)];
            _newsArrowImageView.image = [UIImage imageNamed:@"rightArrow"];
            [_newsContentView addSubview:_newsArrowImageView];
        }
    }
    return self;
}

- (void)setArticleData:(WXYSectionData *)articleData
{
    _articleData = articleData;
    //处理时间字符串
    _timeLabel.text = articleData.displayTimeString;
    CGFloat width = [UILabel widthForLabelWithText:articleData.displayTimeString maxHeight:screenWidth - 20 font:[UIFont systemFontOfSize:kTimeFontSize]];
    _timeLabel.frame = CGRectMake((screenWidth - width - 10) / 2, 10, width + 10, 20);
    //分别加载对应内容
    if (_articleData.count == 1) {
        [self setupNewsArticleCell];
    }else{
        [self setupNormalArticleCell];
    }
}
- (void)setupNewsArticleCell
{
    WXYArticle *article = _articleData.articleList[0];
    //标题
    _newsTitleLabel.text = article.articleTitle;
    //图片
    _newsImageView.image = nil;
    [_newsImageView TX_setImageWithURL:[NSURL URLWithString:article.articleImageUrlString] placeholderImage:nil];
    //简介
    _newsSummaryLabel.text = article.articleSummary;
    /*调整Frame*/
    //背景图
    _newsContentView.frame = CGRectMake(15, 48, screenWidth - 30, _articleData.rowHeight - 64);
    _newsContentButton.frame = CGRectMake(0, 0, screenWidth - 30, _articleData.rowHeight - 64);
    //标题frame
    CGFloat titleHeight = [UILabel heightForLabelWithText:article.articleTitle maxWidth:screenWidth - 80 font:[UIFont systemFontOfSize:NewsArticleTitleFontSize]];
    _newsTitleLabel.frame = CGRectMake(10, 10, screenWidth - 80, titleHeight);
    //图片frame
    _newsImageView.frame = CGRectMake(10, CGRectGetMaxY(_newsTitleLabel.frame) + 10, screenWidth - 50, NewsArticleImageHeight);
    //简介frame
    if (article.articleSummary && [article.articleSummary length]) {
        CGFloat summaryHeight = [UILabel heightForLabelWithText:article.articleSummary maxWidth:screenWidth - 50 font:[UIFont systemFontOfSize:NewsArticleSummaryFontSize]];
        _newsSummaryLabel.frame = CGRectMake(10, CGRectGetMaxY(_newsImageView.frame) + 10, screenWidth - 50, summaryHeight);
    }else{
        _newsSummaryLabel.frame = CGRectMake(10, CGRectGetMaxY(_newsImageView.frame), screenWidth - 50, 0);
    }
    //分割线frame
    _newsLineView.frame = CGRectMake(0, CGRectGetMaxY(_newsSummaryLabel.frame) + 9, CGRectGetWidth(_newsContentView.frame), kLineHeight);
    //阅读全文frame
    _newsReadLabel.frame = CGRectMake(10, CGRectGetMaxY(_newsLineView.frame), 200, 35);
    //箭头frame
    _newsArrowImageView.frame = CGRectMake(CGRectGetWidth(_newsContentView.frame) - 22, CGRectGetMaxY(_newsLineView.frame) + 11, 8, 12);
}
- (void)setupNormalArticleCell
{
    //调整frame
    _articleContentView.frame = CGRectMake(15, 48, screenWidth - 30, _articleData.rowHeight - 64);
    //移除已有视图
    [_articleContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //添加新视图
    CGFloat offset = 0;
    for (NSInteger i = 0; i < [_articleData.articleList count]; i++) {
        WXYArticle *article = (WXYArticle *)_articleData.articleList[i];
        if (article.articleType == ArticleTypeFocus) {
            /*焦点图类型*/
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = kArticleButtonTag + i;
            btn.backgroundColor = [UIColor clearColor];
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:223.f/255.f green:223.f/255.f blue:223.f/255.f alpha:1.f]] forState:UIControlStateHighlighted];
            btn.frame = CGRectMake(0, offset, CGRectGetWidth(_articleContentView.frame), article.articleCellHeight);
            [btn addTarget:self action:@selector(onArticleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_articleContentView addSubview:btn];
            //添加图片
            UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(btn.frame) - 20, CGRectGetHeight(btn.frame) - 20)];
            topImageView.backgroundColor = [UIColor colorWithRed:232.f/255.f green:232.f/255.f blue:232.f/255.f alpha:1.f];
            topImageView.contentMode = UIViewContentModeScaleAspectFill;
            topImageView.clipsToBounds = YES;
            [topImageView TX_setImageWithURL:[NSURL URLWithString:article.articleImageUrlString] placeholderImage:nil];
            [btn addSubview:topImageView];
            //添加标题条和背景
            CGFloat titleHeight = [UILabel heightForLabelWithText:article.articleTitle maxWidth:CGRectGetWidth(btn.frame) - 30 font:[UIFont systemFontOfSize:FocusArticleTitleFontSize]];
            UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(btn.frame) - titleHeight - 20, CGRectGetWidth(btn.frame) - 20, titleHeight + 10)];
            topBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            [btn addSubview:topBgView];
            UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(topBgView.frame) + 5, CGRectGetWidth(btn.frame) - 30, titleHeight)];
            topLabel.backgroundColor = [UIColor clearColor];
            topLabel.font = [UIFont systemFontOfSize:FocusArticleTitleFontSize];
            topLabel.textColor = [UIColor whiteColor];
            topLabel.numberOfLines = 0;
            topLabel.text = article.articleTitle;
            [btn addSubview:topLabel];
            //添加分割线
            if (i != [_articleData.articleList count] - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(btn.frame) - 1, CGRectGetWidth(btn.frame), kLineHeight)];
                lineView.backgroundColor = [UIColor colorWithRed:235.f/255.f green:237.f/255.f blue:240.f/255.f alpha:1.f];
                [btn addSubview:lineView];
            }
            //更新偏移量
            offset += article.articleCellHeight;
        }else{
            /*普通类型*/
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = kArticleButtonTag + i;
            btn.frame = CGRectMake(0, offset, CGRectGetWidth(_articleContentView.frame), article.articleCellHeight);
            [btn setBackgroundImage:nil forState:UIControlStateNormal];
            [btn setBackgroundImage:[self createImageWithColor:[UIColor colorWithRed:223.f/255.f green:223.f/255.f blue:223.f/255.f alpha:1.f]] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(onArticleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_articleContentView addSubview:btn];
            //添加标题条和背景
            UILabel *normalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, CGRectGetWidth(btn.frame) - 80, CGRectGetHeight(btn.frame) - 10)];
            normalLabel.backgroundColor = [UIColor clearColor];
            normalLabel.font = [UIFont systemFontOfSize:DefaultArticleTitleFontSize];
            normalLabel.textColor = [UIColor blackColor];
            normalLabel.numberOfLines = 0;
            normalLabel.text = article.articleTitle;
            [btn addSubview:normalLabel];
            //添加图片
            UIImageView *normalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) - 50, 9, DefaultArticleImageHeight, DefaultArticleImageHeight)];
            normalImageView.backgroundColor = [UIColor colorWithRed:232.f/255.f green:232.f/255.f blue:232.f/255.f alpha:1.f];
            normalImageView.contentMode = UIViewContentModeScaleAspectFill;
            normalImageView.clipsToBounds = YES;
            [normalImageView TX_setImageWithURL:[NSURL URLWithString:article.articleImageUrlString] placeholderImage:nil];
            [btn addSubview:normalImageView];
            //添加分割线
            if (i != [_articleData.articleList count] - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(btn.frame) - 1, CGRectGetWidth(btn.frame), kLineHeight)];
                lineView.backgroundColor = [UIColor colorWithRed:235.f/255.f green:237.f/255.f blue:240.f/255.f alpha:1.f];
                [btn addSubview:lineView];
            }
            //更新偏移量
            offset += article.articleCellHeight;
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//按钮响应方法
- (void)onArticleButtonTapped:(UIButton *)btn
{
    if (_delegate && [_delegate respondsToSelector:@selector(tappedOnCellWithArticle:)]) {
        NSInteger index = btn.tag - kArticleButtonTag;
        WXYArticle *article = (WXYArticle *)_articleData.articleList[index];
        [_delegate tappedOnCellWithArticle:article];
    }
}
//Color转图片
- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
