//
//  NSString+Utils.m
//  TXChat
//
//  Created by lyt on 15/7/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSString+Photo.h"

@implementation NSString (Photo)

//格式化 图片链接
-(NSString *)getFormatPhotoUrl:(CGFloat)width hight:(CGFloat)hight
{
    if(!self)
    {
        return self;
    }
    if(width > 0 && hight > 0)
    {
        if(width < 100 && hight < 100)
        {
            return [NSString stringWithFormat:@"%@?imageView2/1/w/%ld/h/%ld", self, (long)(2*width), (long)(2*hight)];
        }
        else
        {
            return [NSString stringWithFormat:@"%@?imageView2/1/format/jpg/w/%ld/h/%ld", self, (long)(2*width), (long)(2*hight)];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%@?imageView2/1/format/jpg", self];;
    }
}

//格式化 图片链接
-(NSString *)getFormatPhotoUrl
{
    if(!self)
    {
        return self;
    }
    return [NSString stringWithFormat:@"%@?imageView2/1/format/jpg", self];;
}


@end
