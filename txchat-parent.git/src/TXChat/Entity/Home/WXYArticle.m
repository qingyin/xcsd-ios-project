//
//  WXYArticle.m
//  WeiXueYuanDemo
//
//  Created by 陈爱彬 on 15/5/25.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import "WXYArticle.h"
#import "UILabel+ContentSize.h"
#import "NSDate+TuXing.h"
#import "NSString+MessageInputView.h"

//当前设备的屏幕宽度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

//当前设备的屏幕高度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

CGFloat const DefaultArticleTitleFontSize = 15.f;
CGFloat const FocusArticleTitleFontSize = 16.f;
CGFloat const NewsArticleTitleFontSize = 18.f;
CGFloat const NewsArticleSummaryFontSize = 14.f;

CGFloat const DefaultArticleImageHeight = 40.f;
CGFloat const FocusArticleImageHeight = 150.f;
CGFloat const NewsArticleImageHeight = 150.f;

@implementation WXYSectionData

- (instancetype)initWithGroupList:(NSArray *)groupPosts
{
    if (!groupPosts) {
        return nil;
    }
    self = [super init];
    if (self) {
        //id
//        NSArray *groupPosts = group.post;
        if (groupPosts && [groupPosts count]) {
            TXPost *post = groupPosts[0];
            _groupId = post.groupId;
            //time
            _timeStamp = [NSString stringWithFormat:@"%@",@(post.createdOn / 1000)];
            _displayTimeString = [NSDate timeForChatListStyle:_timeStamp];
            //高度
            _rowHeight = 0;
            //count
            _count = [groupPosts count];
            //判断类型
            NSMutableArray *list = [NSMutableArray array];
            if (_count == 1) {
                //新闻类型
                WXYArticle *article = [[WXYArticle alloc] initWithPBPost:post];
                article.articleType = ArticleTypeNews;
                [list addObject:article];
                //设置高度
                _rowHeight = article.articleCellHeight;
            }else if (_count > 1) {
                //整理列表数据
                [groupPosts enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                    WXYArticle *article = [[WXYArticle alloc] initWithPBPost:groupPosts[idx]];
                    if (idx == 0) {
                        article.articleType = ArticleTypeFocus;
                    }else{
                        article.articleType = ArticleTypeDefault;
                    }
                    [list addObject:article];
                    //计算行高
                    _rowHeight += article.articleCellHeight;
                }];
            }
            _articleList = [list copy];
            //添加行高margin,其中时间48高，底部16高
            _rowHeight += 64;
        }else{
            return nil;
        }
        
    }
    return self;
}
//处理字符串
- (NSString *)formaterDisplayTime:(NSString *)time
{
    if (!time || ![time length]) {
        return nil;
    }
//    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[time doubleValue]];
    NSString *str = [NSDate timeForChatListStyle:time];
//    NSString *str = [UIUtil timeForCommentListStyle:date];
    return str;
}

@end

@implementation WXYArticle

- (instancetype)initWithPBPost:(TXPost *)post
{
    if (!post) {
        return nil;
    }
    self = [super init];
    if (self) {
        //id
        _articleId = post.postId;
        //标题
        _articleTitle = post.title;
        //图片地址
        _articleImageUrlString = post.coverImageUrl;
        //url
        _articleUrlString = post.postUrl;
        //简介
        _articleSummary = post.summary;
    }
    return self;
}
- (void)setArticleType:(ArticleType)type
{
    _articleType = type;
    //计算高度
    if (_articleType == ArticleTypeNews) {
        //新闻详情类型
        CGFloat titleHeight = [UILabel heightForLabelWithText:_articleTitle maxWidth:SCREEN_WIDTH - 80 font:[UIFont systemFontOfSize:NewsArticleTitleFontSize]];
        CGFloat summaryHeight;
        CGFloat summaryBottomMargin;
        if (_articleSummary && [_articleSummary length]) {
            summaryHeight = [UILabel heightForLabelWithText:_articleSummary maxWidth:SCREEN_WIDTH - 50 font:[UIFont systemFontOfSize:NewsArticleSummaryFontSize]];
            summaryBottomMargin = 10;
        }else{
            summaryHeight = 0;
            summaryBottomMargin = 0;
        }
        CGFloat bottomReadHeight = 35;
        CGFloat titleTopMargin = 10;
        CGFloat imageTopMargin = 10;
        CGFloat imageBottomMargin = 10;
        _articleCellHeight = titleTopMargin + titleHeight + imageTopMargin + NewsArticleImageHeight + imageBottomMargin + summaryHeight + summaryBottomMargin + bottomReadHeight;
    }else if (_articleType == ArticleTypeFocus) {
        //焦点图类型
        _articleCellHeight = FocusArticleImageHeight + 20;
    }else{
        //普通类型
        CGFloat height = [UILabel heightForLabelWithText:_articleTitle maxWidth:SCREEN_WIDTH - 110 font:[UIFont systemFontOfSize:DefaultArticleTitleFontSize]];
        if (height <= DefaultArticleImageHeight) {
            _articleCellHeight = DefaultArticleImageHeight + 20;
        }else {
            _articleCellHeight = height + 10;
        }
    }
}

@end
