//
//  TXDepartment+Utils.m
//  TXChat
//
//  Created by lyt on 15-7-3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//
#import <TXChatClient.h>
#import "TXDepartment+Utils.h"

@implementation TXDepartment (Utils)

-(NSString *)getKindergartenName
{
    TXUser *loginUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if(loginUser.gardenName != nil)
    {
        return loginUser.gardenName;
    }
    return @"";
}

-(NSString *)getFormatAvatarUrl:(CGFloat)width hight:(CGFloat)hight
{
    if(self.avatarUrl != nil && [self.avatarUrl length] > 0)
    {
        return [self.avatarUrl getFormatPhotoUrl:width hight:hight];
    }
    return  nil;
}


@end
