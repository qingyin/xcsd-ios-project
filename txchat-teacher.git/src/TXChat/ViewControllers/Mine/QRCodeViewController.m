//
//  QRCodeViewController.m
//  TXChat
//
//  Created by Cloud on 15/8/17.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "QRCodeViewController.h"
#import "QRCodeGenerator.h"

@implementation QRCodeViewController

- (void)viewDidLoad{
    self.titleStr = @"我的二维码";
    [super viewDidLoad];
    [self createCustomNavBar];
    
    TXUser *user = [[TXChatClient sharedInstance] getCurrentUser:nil];
    NSString *str = [NSString stringWithFormat:@"check_in://%lld",user.userId];
    UIImage *qrImg = [self createQRForString:str];
    
    UIImageView *qrImgView = [[UIImageView alloc] initWithImage:qrImg];
    qrImgView.frame = CGRectMake(0, 0, qrImg.size.width, qrImg.size.height);
    [self.view addSubview:qrImgView];
    
    qrImgView.centerX = kScreenWidth/2;
    qrImgView.centerY = self.customNavigationView.maxY + (self.view.height_ - self.customNavigationView.maxY)/2;
}

- (void)onClickBtn:(UIButton *)sender{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}



/**
 *  创建二维码
 */
- (UIImage *)createQRForString:(NSString *)qrString {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    return [self createNonInterpolatedUIImageFormCIImage:qrFilter.outputImage withSize:kScreenWidth - 100];
#else
    UIImage *img = [QRCodeGenerator qrImageForString:qrString imageSize:kScreenWidth - 100];
    return img;
    
#endif
}

/**
 *  将CIImage转换成UIImage
 *
 *  @param image CIImage
 *  @param size  生成UIImage的宽
 *
 *  @return UIImage
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(cs);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *retImg = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return retImg;
}

@end
