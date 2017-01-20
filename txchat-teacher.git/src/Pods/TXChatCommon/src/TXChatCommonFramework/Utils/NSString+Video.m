//
//  NSString+Video.m
//  TXChatTeacher
//
//  Created by lyt on 15/11/20.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSString+Video.h"

@implementation NSString (Video)
//格式化 视频链接
-(NSString *)getFormatVideoUrl:(CGFloat)width hight:(CGFloat)hight
{
    if(!self)
    {
        return self;
    }
    if(width > 0 && hight > 0)
    {
        return [NSString stringWithFormat:@"%@?vframe/jpg/offset/0/w/%ld/h/%ld", self, (long)(2*width), (long)(2*hight)];
    }
    else
    {
        return [NSString stringWithFormat:@"%@?vframe/jpg/offset/0", self];
    }
}

//格式化 视频链接
-(NSString *)getFormatVideoUrl
{
    if(!self)
    {
        return self;
    }
    return [NSString stringWithFormat:@"%@?vframe/jpg/offset/0", self];
}

@end
