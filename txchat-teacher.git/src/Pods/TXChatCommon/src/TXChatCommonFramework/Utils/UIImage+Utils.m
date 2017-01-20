//
//  UIImage+Utils.m
//  TXChatCommonFramework
//
//  Created by Cloud on 15/6/2.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UIImage+Utils.h"
//#import <ImageIO/ImageIO.h>

@implementation UIImage (Utils)

+ (UIImage *)imageWithBundleNamed:(NSString *)name andBundleName:(NSString *)bundle{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@",bundle,name]];
}

- (UIImage *)imageTo4b3AtSize:(CGSize)size
{
    if (size.height / size.width != 3.0 / 4.0)
        return nil;
    
    // 倍数
    CGFloat widthMultiple = self.size.width / 4.0;
    CGFloat heightMultiple = self.size.height / 3.0;
    
    // 宽高先缩放到4:3
    CGFloat scale = 0;
    // 缩放已倍数小的为准
    if (widthMultiple < heightMultiple) {
        // 图片比目标大小大时才缩放
        if (self.size.width > size.width)
            scale = size.width / self.size.width;
    }
    // 高的倍数小 or 高宽倍数相等
    else {
        // 图片比目标大小大时才缩放
        if (self.size.height > size.height)
            scale = size.height / self.size.height;
    }
    
    UIImage *img = self;
    
    // 需要缩放
    if (scale != 0) {
        img = [self imageToScale:scale];
    }
    
    // 需要裁剪
    if (widthMultiple != heightMultiple) {
        img = [img imageTo4b3];
    }
    
    return img;
}

- (UIImage *)imageToScale:(float)scale
{
    CGSize size = CGSizeMake(self.size.width * scale, self.size.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)imageTo4b3
{
    // 倍数
    CGFloat widthMultiple = self.size.width / 4.0;
    CGFloat heightMultiple = self.size.height / 3.0;
    
    CGRect rect = CGRectNull;
    // 倍数大的裁剪
    if (widthMultiple > heightMultiple) {
        CGFloat newWidth = heightMultiple * 4.0;
        rect = CGRectMake((self.size.width - newWidth) / 2, 0, newWidth, self.size.height);
    } else if (heightMultiple > widthMultiple) {
        CGFloat newHeight = widthMultiple * 3.0;
        rect = CGRectMake(0, (self.size.height - newHeight) / 2, self.size.width, newHeight);
    }
    
    if (CGRectIsNull(rect)) {
        return self;
    } else {
        UIImage *image4b3 = [self newImageAtRect:rect];
        return image4b3;
    }
}


// 图片裁剪
- (UIImage *)newImageAtRect:(CGRect)rect
{
    rect = CGRectMake(rect.origin.x * self.scale, rect.origin.y * self.scale, rect.size.width * self.scale, rect.size.height * self.scale);
    
    CGImageRef imgref = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *img = [UIImage imageWithCGImage:imgref];
    CGImageRelease(imgref);
    return img;
}

- (UIImage *)imageToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *sizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return sizeImage;
}

+ (CGFloat)scaleForPickImage:(UIImage *)image maxWidthPixelSize:(CGFloat)maxWidthPixelSize
{
    if (!image) {
        return 1.f;
    }
    CGFloat scale = 1.f;
    CGSize imageSize = image.size;
    if (imageSize.width > maxWidthPixelSize) {
        scale = maxWidthPixelSize / imageSize.width;
    }
    return scale;
}

+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)scale
{
    if (!image) {
        return nil;
    }
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}




//private method
//maxPixelSize MUST BE a valid value.
//+ (UIImage *)thumbImageFromLargeImage:(UIImage *)image withConfirmedMaxPixelSize:(CGFloat)maxPixelSize
//{
//    // Create the image source (from path)
//    NSData *imageData = UIImagePNGRepresentation(image);
//    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
////    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef) [NSURL fileURLWithPath:filePath], NULL);
//    
//    // To create image source from UIImage, use this
//    // NSData* pngData =  UIImagePNGRepresentation(image);
//    // CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
//    
//    // Create thumbnail options
//    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
//                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
//                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
//                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(maxPixelSize)
//                                                           };
//    // Generate the thumbnail
//    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
//    CFRelease(src);
//    
//    UIImage *retImage = [[UIImage alloc] initWithCGImage:thumbnail];
//    CFRelease(thumbnail);
//    return retImage;
//}
@end
