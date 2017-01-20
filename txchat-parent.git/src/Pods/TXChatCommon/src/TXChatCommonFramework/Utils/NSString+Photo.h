//
//  NSString+Utils.h
//  TXChat
//
//  Created by lyt on 15/7/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Photo)

//格式化 图片链接
-(NSString *)getFormatPhotoUrl:(CGFloat)width hight:(CGFloat)hight;

//格式化 图片链接
-(NSString *)getFormatPhotoUrl;
@end
