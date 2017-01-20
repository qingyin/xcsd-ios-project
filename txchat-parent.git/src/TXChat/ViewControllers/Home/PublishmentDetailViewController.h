//
//  PublishmentDetailViewController.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface PublishmentDetailViewController : BaseViewController

@property (nonatomic) BOOL addRequestToolView;
@property (nonatomic) TXHomePostType postType;

@property (nonatomic, copy) NSString *articleId;

- (instancetype)initWithLinkURLString:(NSString *)urlString;

- (instancetype)initWithWXYPushId:(NSString *)pushId;

@end
