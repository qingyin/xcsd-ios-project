//
//  THNumberButton.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/8.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THNumberButton : UIControl

@property (nonatomic,copy) NSString *numberString;
@property (nonatomic,assign,readonly) CGFloat adjustWidth;

- (instancetype)initWithFrame:(CGRect)frame
                  normalImage:(UIImage *)image;

- (instancetype)initWithFrame:(CGRect)frame
                  normalImage:(UIImage *)image
             highlightedImage:(UIImage *)hImage;

- (instancetype)initWithFrame:(CGRect)frame
                  normalImage:(UIImage *)image
             highlightedImage:(UIImage *)hImage
                selectedImage:(UIImage *)sImage;

@end
