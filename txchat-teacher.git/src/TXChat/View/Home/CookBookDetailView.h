//
//  CookBookDetailView.h
//  TXChat
//
//  Created by 陈爱彬 on 15/7/8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CookBookDetailView : UIView

@property (nonatomic,strong) UIWebView *webView;

- (instancetype)initWithFrame:(CGRect)frame
                       postId:(SInt64)postId
                     postType:(TXHomePostType)postType;

//开始请求
- (void)startRecipeRequest;

@end
