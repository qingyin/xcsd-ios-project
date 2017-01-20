//
//  UIView+Utils.h
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Utils)

@property (nonatomic) CGFloat width_;
@property (nonatomic) CGFloat height_;
@property (nonatomic) CGFloat maxX;
@property (nonatomic) CGFloat maxY;
@property (nonatomic) CGFloat minX;
@property (nonatomic) CGFloat minY;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;

- (id)initClearColorWithFrame:(CGRect)frame;
- (id)initLineWithFrame:(CGRect)frame;
- (UIView*)subviewWithFirstResponder;
- (void)removeAllSubviews;

- (void)sl_setCornerRadius:(CGFloat) cornerRadius;

@end

@interface UIButton (Utils)

- (UIEdgeInsets)setImageEdgeInsetsFromOriginOffSet:(CGVector)vector imageSize:(CGSize)size;
- (UIEdgeInsets)setImageEdgeInsetsFromCenterOffSet:(CGVector)vector imageSize:(CGSize)size;

@end
