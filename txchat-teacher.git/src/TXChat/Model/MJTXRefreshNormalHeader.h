//
//  MJTXRefreshNormalHeader.h
//  TXChat
//
//  Created by lyt on 15/8/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MJRefreshNormalHeader.h"

@interface MJTXRefreshNormalHeader : MJRefreshStateHeader

@property (weak, nonatomic, readonly) UIImageView *arrowView;
/** 菊花的样式 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;


@end
