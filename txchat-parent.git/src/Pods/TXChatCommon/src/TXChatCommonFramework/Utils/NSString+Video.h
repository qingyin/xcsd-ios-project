//
//  NSString+Video.h
//  TXChatTeacher
//
//  Created by lyt on 15/11/20.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Video)

//格式化 视频链接
-(NSString *)getFormatVideoUrl:(CGFloat)width hight:(CGFloat)hight;

//格式化 视频链接
-(NSString *)getFormatVideoUrl;

@end
