//
//  WXYArticle.h
//  WeiXueYuanDemo
//
//  Created by 陈爱彬 on 15/5/25.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ArticleType) {
    ArticleTypeNews = 0,          //新闻类型，一般位于一整块内容
    ArticleTypeFocus,             //焦点图类型，一般位于第一行
    ArticleTypeDefault,           //普通类型，一般位于列表页
};

extern CGFloat const DefaultArticleTitleFontSize;
extern CGFloat const FocusArticleTitleFontSize;
extern CGFloat const NewsArticleTitleFontSize;
extern CGFloat const NewsArticleSummaryFontSize;

extern CGFloat const DefaultArticleImageHeight;
extern CGFloat const FocusArticleImageHeight;
extern CGFloat const NewsArticleImageHeight;

@interface WXYSectionData : NSObject

/**
 *  本地数据库的index
 */
@property (nonatomic,assign) NSInteger dbIndex;
/**
 *  id
 */
@property (nonatomic) int64_t groupId;
/**
 *  时间戳
 */
@property (nonatomic,copy) NSString *timeStamp;
/**
 *  展示的时间字符串
 */
@property (nonatomic,copy) NSString *displayTimeString;
/**
 *  数量
 */
@property (nonatomic,assign)NSInteger count;
/**
 *  Section的列表内容，其中每个子项是一个WXYArticle
 */
@property (nonatomic,copy) NSArray *articleList;

/**
 *  行高
 */
@property (nonatomic) CGFloat rowHeight;

//初始化微学园Section Model
- (instancetype)initWithGroupList:(NSArray *)groupPosts;

@end

@interface WXYArticle : NSObject

/**
 *  类型
 */
@property (nonatomic,assign) ArticleType articleType;
/**
 *  文章ID
 */
@property (nonatomic) int64_t articleId;
/**
 *  文章标题
 */
@property (nonatomic,copy) NSString *articleTitle;
/**
 *  文章配图URL地址
 */
@property (nonatomic,copy) NSString *articleImageUrlString;
/**
 *  文章内容页URL地址
 */
@property (nonatomic,copy) NSString *articleUrlString;
/**
 *  文章简介
 */
@property (nonatomic,copy) NSString *articleSummary;
/**
 *  cell高度
 */
@property (nonatomic,assign) CGFloat articleCellHeight;

/**
 *  初始化文章Model
 *
 *  @param dict 网络获取的json转换后的字典
 *
 *  @return 微学园文章Model
 */
- (instancetype)initWithPBPost:(TXPost *)post;

@end
