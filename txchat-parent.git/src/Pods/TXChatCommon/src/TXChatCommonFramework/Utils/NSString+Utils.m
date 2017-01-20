//
//  NSString+Utils.m
//  TXChatCommonFramework
//
//  Created by Cloud on 15/6/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (Utils)

+ (BOOL)isValidateMobile:(NSString *)mobile{
    NSString *numberRegex = @"^1\\d{10}$";
    NSPredicate *numbersTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
    return [numbersTest evaluateWithObject:mobile];
}

- (BOOL)containsString:(NSString *)aString
{
    NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
    return range.location != NSNotFound;
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
