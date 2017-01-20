//
//  WXYArticleTableViewCell.h
//  WeiXueYuanDemo
//
//  Created by 陈爱彬 on 15/5/25.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WXYSectionData;
@class WXYArticle;
@protocol WXYArticleCellTapDelegate <NSObject>

- (void)tappedOnCellWithArticle:(WXYArticle *)article;

@end

@interface WXYArticleTableViewCell : UITableViewCell

@property (nonatomic,weak) id<WXYArticleCellTapDelegate>delegate;
@property (nonatomic,copy) WXYSectionData *articleData;

@end
