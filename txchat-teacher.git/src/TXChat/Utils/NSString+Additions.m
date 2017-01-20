//
//  NSString+Additions.m
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/9.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "NSString+Additions.h"
#import <CoreText/CoreText.h>

@implementation NSString (Additions)

#pragma mark - CoreText排版
- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace{
    return [self sizeWithConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX) fromFont:font1 lineSpace:lineSpace];
}

- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)font1 lineSpace:(float)lineSpace{
    CGFloat minimumLineHeight = font1.pointSize,maximumLineHeight = minimumLineHeight, linespace = lineSpace;
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)font1.fontName,font1.pointSize,NULL);
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    //Apply paragraph settings
    CTTextAlignment alignment = kCTLeftTextAlignment;
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]){
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    },6);
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,(NSString*)kCTFontAttributeName,(__bridge id)style,(NSString*)kCTParagraphStyleAttributeName,nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    //    [self clearEmoji:string start:0 font:font1];
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)string;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGSize result = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [string length]), NULL, size, NULL);
    CFRelease(framesetter);
    CFRelease(font);
    CFRelease(style);
    string = nil;
    attributes = nil;
    return result;
}
//获取需要绘制出文本的行数
- (NSInteger)numberOfLinesWithConstrainedToWidth:(CGFloat)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace
{
    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    CGFloat minimumLineHeight = font1.pointSize,maximumLineHeight = minimumLineHeight, linespace = lineSpace;
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)font1.fontName,font1.pointSize,NULL);
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    //Apply paragraph settings
    CTTextAlignment alignment = kCTLeftTextAlignment;
    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[6]){
        {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(linespace), &linespace},
        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
    },6);
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)font,(NSString*)kCTFontAttributeName,(__bridge id)style,(NSString*)kCTParagraphStyleAttributeName,nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self attributes:attributes];
    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)string;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    //填写路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path,NULL,CGRectMake(0, 0,(size.width),(size.height)));
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [string length]), path, NULL);
    //获取行数
    CFArrayRef lines = CTFrameGetLines(frameRef);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    //释放数据
    CGPathRelease(path);
    CFRelease(frameRef);
    CFRelease(framesetter);
    CFRelease(font);
    CFRelease(style);
    string = nil;
    attributes = nil;
    return numberOfLines;
}
@end
