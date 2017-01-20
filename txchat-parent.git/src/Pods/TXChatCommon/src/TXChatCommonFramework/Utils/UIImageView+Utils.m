//
//  UIImageView+Utils.m
//  TXChatCommonFramework
//
//  Created by Cloud on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UIImageView+Utils.h"

@implementation UIImageView (Utils)

+(UIImage*)originImage:(UIImage *)image   scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 andSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    
    [image2 drawInRect:CGRectMake(0, 0, size.width, size.height)];
    [image1 drawInRect:CGRectMake((size.width - image1.size.width)/2, (size.height - image1.size.height)/2, image1.size.width, image1.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

+ (UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


@end
