//
//  NSString+Utils.h
//  TXChatCommonFramework
//
//  Created by Cloud on 15/6/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

//验证手机号
+ (BOOL)isValidateMobile:(NSString *)mobile;
- (BOOL)containsString:(NSString *)aString;
- (NSString *)md5;
- (NSString *)trim;

@end
