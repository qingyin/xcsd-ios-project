//
//  NSString+MessageInputView.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/9.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MessageInputView)

- (NSString *)stringByTrimingWhitespace;

- (NSUInteger)numberOfLines;

+ (NSString *)transferJsonStr:(NSString *)src;

//是否包含emoji
+ (BOOL)stringContainsEmoji:(NSString *)string;

@end
