//
//  UIImage+Utils.h
//  TXChatCommonFramework
//
//  Created by Cloud on 15/6/2.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

+ (UIImage *)imageWithBundleNamed:(NSString *)name andBundleName:(NSString *)bundle;
- (UIImage *)imageTo4b3AtSize:(CGSize)size;

- (UIImage *)imageToSize:(CGSize)size;

+ (CGFloat)scaleForPickImage:(UIImage *)image maxWidthPixelSize:(CGFloat)maxWidthPixelSize;
+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)scale;

//+ (UIImage *)thumbImageFromLargeImage:(UIImage *)image withConfirmedMaxPixelSize:(CGFloat)maxPixelSize;

@end
