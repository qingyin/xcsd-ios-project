//
//  TXUser+Utils.m
//  TXChat
//
//  Created by lyt on 15-6-19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXUser+Utils.h"

@implementation TXUser (Utils)
//获取性别
-(NSString *)getSexStr
{
    
    TXUser *child = [[TXChatClient sharedInstance] getUserByUserId:self.childUserId error:nil];
    if(child == nil)
    {
        return [self convertStrBySex:self.sex];
    }
    else
    {
        return  [self convertStrBySex:child.sex];
    }
}


-(NSString *)convertStrBySex:(TXPBSexType) sex
{
    if(sex == TXPBSexTypeFemale)
    {
        return @"女";
    }
    return @"男";
}

-(NSString *)getFormatAvatarUrl:(CGFloat)width hight:(CGFloat)hight
{
    if(self.avatarUrl != nil && [self.avatarUrl length] > 0)
    {
        return [self.avatarUrl getFormatPhotoUrl:width hight:hight];
    }
    return nil;
}
//是不是园长
-(BOOL)isKindergartenLeader
{
    if(self.positionId == TXPBPositionTypePrincipal
       || self.positionId == TXPBPositionTypeVicePrincipal)
    {
        return YES;
    }
    return NO;
}


@end
