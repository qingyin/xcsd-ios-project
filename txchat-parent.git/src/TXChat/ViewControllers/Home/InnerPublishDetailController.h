//
//  PublishmentDetailViewController.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface InnerPublishDetailController : BaseViewController

@property (nonatomic) BOOL addRequestToolView;
@property (nonatomic) TXHomePostType postType;

@property (nonatomic, copy) NSString *articleId;

@property (nonatomic, copy) NSString *articleTitle;

@property (nonatomic, copy) NSString *coverImageUrl;

@property (nonatomic, copy) NSString *shareMsg;

- (instancetype)initWithLinkURLString:(NSString *)urlString;

- (instancetype)initWithWXYPushId:(NSString *)pushId;

@end
