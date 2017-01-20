//
//  NSString+CheckIn.m
//  TXChatTeacher
//
//  Created by lyt on 15/10/13.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//
#import "NSURL+ZXURL.h"
#import "NSString+CheckIn.h"

@implementation NSString (CheckIn)
+(BOOL)isCardInfo:(NSString *)scanedUrl
{
    BOOL ret = NO;
    if(scanedUrl == nil || [scanedUrl length] == 0)
    {
        return ret;
    }
    
    if([scanedUrl containsString:KSignInUrl])
    {
        ret = YES;
    }
    return ret;
}

+(NSString *)getUserIdByUrl:(NSString *)scanedUrl
{
    NSString *userId = nil;
    if(scanedUrl == nil || [scanedUrl length] == 0)
    {
        return userId;
    }
//    NSString *codeUrl = [scanedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:scanedUrl];
    userId = [url parameterForKey:KUserIdKey];
    return userId;
}


+(NSString *)getUserNameByUrl:(NSString *)scanedUrl
{
    NSString *userNickname = nil;
    if(scanedUrl == nil || [scanedUrl length] == 0)
    {
        return userNickname;
    }
    
//    NSString *codeUrl = [scanedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:scanedUrl];
    userNickname = [url parameterForKey:KUserNameKey];
    return [userNickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString *)getUserTypeByUrl:(NSString *)scanedUrl
{
    NSString *userNickname = nil;
    if(scanedUrl == nil || [scanedUrl length] == 0)
    {
        return userNickname;
    }
    
//    NSString *codeUrl = [scanedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:scanedUrl];
    userNickname = [url parameterForKey:KUserTypeKey];
    return [userNickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(NSString *)getUserCardNumberByUrl:(NSString *)scanedUrl
{
    NSString *userNickname = nil;
    if(scanedUrl == nil || [scanedUrl length] == 0)
    {
        return userNickname;
    }
    
    //    NSString *codeUrl = [scanedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:scanedUrl];
    userNickname = [url parameterForKey:KUserCardNumberKey];
    return [userNickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
