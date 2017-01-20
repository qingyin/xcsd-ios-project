//
//  UIImageView+Utils.h
//  TXChatCommonFramework
//
//  Created by Cloud on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Utils)

+ (UIImage*)originImage:(UIImage *)image   scaleToSize:(CGSize)size;
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 andSize:(CGSize)size;
+ (UIImage *) createImageWithColor: (UIColor *) color;

@end
