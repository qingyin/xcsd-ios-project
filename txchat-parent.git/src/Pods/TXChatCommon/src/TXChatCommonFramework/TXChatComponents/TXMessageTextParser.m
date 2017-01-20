//
//  TXMessageTextParser.m
//  TXChatCommonFramework
//
//  Created by 陈爱彬 on 15/12/21.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXMessageTextParser.h"

@implementation TXMessageTextParser

- (BOOL)parseText:(NSMutableAttributedString *)text selectedRange:(NSRangePointer)selectedRange
{
    NSArray *matches = [self matchesFromAttributedString:[text string]];
    if (!matches || ![matches count]) {
        return NO;
    }
    for (NSTextCheckingResult *result in matches) {
        NSRange range = result.range;
        UIColor *selectedColor = _highlightColor ?: [UIColor clearColor];
        NSDictionary *highlightAttribute = @{NSBackgroundColorAttributeName:selectedColor};
        [text yy_setTextUnderline:[YYTextDecoration decorationWithStyle:YYTextLineStyleSingle] range:range];
        [text yy_setTextHighlight:[YYTextHighlight highlightWithAttributes:highlightAttribute] range:range];
    }
    return YES;
}

- (NSArray *)matchesFromAttributedString:(NSString *)string {
    NSError* error = nil;
    NSDataDetector* linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
    NSRange range = NSMakeRange(0, string.length);
    
    return [linkDetector matchesInString:string options:0 range:range];
}

@end
