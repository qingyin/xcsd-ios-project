//
//  UIView+Utils.m
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import "UIView+Utils.h"

@implementation UIView (Utils)

- (id)initClearColorWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initLineWithFrame:(CGRect)frame{
    self = [self initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0xe5/255.0 green:0xe5/255.0 blue:0xe5/255.0 alpha:1];
    }
    return self;
}

- (CGFloat)width_{
    return self.frame.size.width;
}

- (void)setWidth_:(CGFloat)width_ {
    CGRect frame = self.frame;
    frame.size.width = width_;
    self.frame = frame;
}

- (CGFloat)height_{
    return self.frame.size.height;
}

- (void)setHeight_:(CGFloat)height_ {
    CGRect frame = self.frame;
    frame.size.height = height_;
    self.frame = frame;
}

- (CGFloat)maxX {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setMaxX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x - frame.size.width;
    self.frame = frame;
}

- (CGFloat)maxY {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setMaxY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y - frame.size.height;
    self.frame = frame;
}

- (CGFloat)minX {
    return self.frame.origin.x;
}

- (void)setMinX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)minY {
    return self.frame.origin.y;
}

- (void)setMinY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (UIView*)subviewWithFirstResponder {
    if ([self isFirstResponder])
        return self;
    
    for (UIView *subview in self.subviews) {
        UIView *view = [subview subviewWithFirstResponder];
        if (view) return view;
    }
    
    return nil;
}

- (void)removeAllSubviews {
    while (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (void)sl_setCornerRadius:(CGFloat)cornerRadius{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (void)setBorderWithWidth:(CGFloat)width andCornerRadius:(CGFloat)radius andBorderColor:(UIColor *)color{
    
    self.layer.borderWidth = width;
    
    // 设置圆角
    self.layer.cornerRadius = radius;
    
    // 设置边框颜色
    self.layer.borderColor = [color CGColor];
    
    self.layer.masksToBounds=YES;
}

@end

@implementation UIButton (Util)

//保持图片不变形，从坐标点调整偏移
- (UIEdgeInsets)setImageEdgeInsetsFromOriginOffSet:(CGVector)vector imageSize:(CGSize)size
{
    //dx = -((self.width-size.width)/2.0-dx);
    float offsetX = self.width_ - size.width;
    float offsetY = self.height_ - size.height;
    
    UIEdgeInsets edgeInsets =  UIEdgeInsetsMake(vector.dy, vector.dx, offsetY - vector.dy, offsetX - vector.dx);
    return edgeInsets;
}

//保持图片不变形，从中心点调整偏移
- (UIEdgeInsets)setImageEdgeInsetsFromCenterOffSet:(CGVector)vector imageSize:(CGSize)size
{
    float offsetX = self.width_ - size.width;
    float offsetY = self.height_ - size.height;
    UIEdgeInsets edgeInsets =  UIEdgeInsetsMake(offsetY/2.0 + vector.dy, offsetX/2.0 + vector.dx, offsetY/2.0 - vector.dy, offsetX/2.0 - vector.dx);
    
    return edgeInsets;
}

@end

