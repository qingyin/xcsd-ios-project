//
//  UIImageView+TXSDImage.h
//  TXChatTeacher
//
//  Created by lyt on 15/12/31.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIButton+EMWebCache.h>
@interface UIButton (TXSDImage)

- (void)TX_setImageWithURL:(NSURL *)url forState:(UIControlState )state placeholderImage:(UIImage *)placeholder;

- (void)TX_setImageWithURL:(NSURL *)url forState:(UIControlState )state placeholderImage:(UIImage *)placeholder completed:(EMSDWebImageCompletionBlock)completedBlock;

@end
