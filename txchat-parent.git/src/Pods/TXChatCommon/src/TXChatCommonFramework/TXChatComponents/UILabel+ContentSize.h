//
//  UILabel+ContentSize.h
//  UCAuctionPlatform
//
//  Created by 陈 爱彬 on 14-3-18.
//  Copyright (c) 2014年 iShinetech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ContentSize)

- (CGSize)contentSize;

+ (CGSize)contentSizeForLabelWithText:(NSString *)text
                             maxWidth:(CGFloat)width
                                 font:(UIFont *)font;

+ (CGFloat)heightForLabelWithText:(NSString *)text
                         maxWidth:(CGFloat)width
                             font:(UIFont *)font;

+ (CGFloat)widthForLabelWithText:(NSString *)text
                       maxHeight:(CGFloat)height
                            font:(UIFont *)font;

+ (instancetype)labelWithFontSize:(CGFloat) fontSize;
+ (instancetype)labelWithFontSize:(CGFloat)fontSize text:(NSString *)text;
+ (instancetype)labelWithFontSize:(CGFloat)fontSize text:(NSString *)text LineBreak:(BOOL) isLineBreak;

@end
