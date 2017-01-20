//
//  UILabel+ContentSize.m
//  UCAuctionPlatform
//
//  Created by 陈 爱彬 on 14-3-18.
//  Copyright (c) 2014年 iShinetech. All rights reserved.
//

#import "UILabel+ContentSize.h"

@implementation UILabel (ContentSize)

- (CGSize)contentSize
{
    CGSize contentSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = self.lineBreakMode;
        paragraphStyle.alignment = self.textAlignment;
        
        NSDictionary * attributes = @{NSFontAttributeName : self.font,
                                      NSParagraphStyleAttributeName : paragraphStyle};

        contentSize = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, MAXFLOAT)
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                           attributes:attributes
                                              context:nil].size;

    }else{
        contentSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, MAXFLOAT) lineBreakMode:self.lineBreakMode];
    }
    
    
    return contentSize;
}

+ (CGSize)contentSizeForLabelWithText:(NSString *)text
                             maxWidth:(CGFloat)width
                                 font:(UIFont *)font
{
    CGSize contentSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
        contentSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:attributes
                                         context:nil].size;
        
    }else{
        contentSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return contentSize;
}


+ (CGFloat)heightForLabelWithText:(NSString *)text
                         maxWidth:(CGFloat)width
                             font:(UIFont *)font
{
    CGSize contentSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
        contentSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                        attributes:attributes
                                                           context:nil].size;
        
    }else{
        contentSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return contentSize.height;
    
}

+ (CGFloat)widthForLabelWithText:(NSString *)text
                       maxHeight:(CGFloat)height
                            font:(UIFont *)font
{
    CGSize contentSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary * attributes = @{NSFontAttributeName : font,
                                      NSParagraphStyleAttributeName : paragraphStyle};
        
        contentSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:attributes
                                         context:nil].size;
        
    }else{
        contentSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, height) lineBreakMode:NSLineBreakByWordWrapping];
    }
    return contentSize.width;

}

+ (instancetype)labelWithFontSize:(CGFloat)fontSize{
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    [label sizeToFit];
    return label;
}

+ (instancetype)labelWithFontSize:(CGFloat)fontSize text:(NSString *)text{
    UILabel *label = [self labelWithFontSize:fontSize];
    label.text = text;
    return label;
}
+ (instancetype)labelWithFontSize:(CGFloat)fontSize text:(NSString *)text LineBreak:(BOOL)isLineBreak{
    UILabel *label = [self labelWithFontSize:fontSize text:text];
    if (isLineBreak) {
        label.numberOfLines = 0;
    }
}


@end
