//
//  UIImage+Rotate.m
//  TXChatParent
//
//  Created by lyt on 15/11/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UIImage+Rotate.h"

@implementation UIImage (Rotate)

CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

+ (UIImage *)mainBundleImage:(NSString *)imageName{
    
    NSString *path;
    
    if ([UIScreen mainScreen].scale > 2) {
        path = [[NSBundle mainBundle] pathForResource:[imageName stringByAppendingString:@"@3x"] ofType:@"png"];
    }else{
        path = [[NSBundle mainBundle] pathForResource:[imageName stringByAppendingString:@"@2x"] ofType:@"png"];
    }
    if (path) {
        return [UIImage imageWithContentsOfFile:path];
    }else {
        return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
    }
    
    return nil;
    
//    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", imageName]];
//    
//    return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}


@end
