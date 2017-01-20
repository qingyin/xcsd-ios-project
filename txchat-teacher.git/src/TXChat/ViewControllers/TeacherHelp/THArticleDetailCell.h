//
//  THArticleDetailCell.h
//  TXChatTeacher
//
//  Created by Cloud on 15/12/4.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THGuideArticleDetailViewController;

@interface THArticleDetailCell : UITableViewCell

@property (nonatomic, strong) id detailDic;
@property (nonatomic, assign) THGuideArticleDetailViewController *listVC;

@end
