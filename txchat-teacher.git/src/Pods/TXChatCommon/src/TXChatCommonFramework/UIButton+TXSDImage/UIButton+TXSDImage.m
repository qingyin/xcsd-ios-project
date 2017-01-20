//
//  UIImageView+TXSDImage.m
//  TXChatTeacher
//
//  Created by lyt on 15/12/31.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "UIButton+TXSDImage.h"


@implementation UIButton (TXSDImage)

- (void)TX_setImageWithURL:(NSURL *)url forState:(UIControlState )state placeholderImage:(UIImage *)placeholder
{
    EMSDWebImageOptions option = EMSDWebImageRetryFailed | EMSDWebImageContinueInBackground;
    [self sd_setImageWithURL:url forState:state placeholderImage:placeholder options:option];
}

- (void)TX_setImageWithURL:(NSURL *)url forState:(UIControlState )state placeholderImage:(UIImage *)placeholder completed:(EMSDWebImageCompletionBlock)completedBlock
{
    EMSDWebImageOptions option = EMSDWebImageRetryFailed | EMSDWebImageContinueInBackground;
    [self sd_setImageWithURL:url forState:state placeholderImage:placeholder options:option completed:completedBlock];
}



@end
