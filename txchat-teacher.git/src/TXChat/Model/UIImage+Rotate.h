//
//  UIImage+Rotate.h
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Rotate)
//根据弧度旋转
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

//根据角度旋转
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

+ (UIImage *)mainBundleImage:(NSString *)imageName;

@end
