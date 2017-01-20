//
//  TXUser+NSCoding.m
//  TXChat
//
//  Created by Cloud on 15/6/13.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXUser+NSCoding.h"

@implementation TXUser (NSCoding)

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.nickname forKey:@"nickName"];
    [aCoder encodeObject:self.nicknameFirstLetter forKey:@"nickNameFirstLetter"];
    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    [aCoder encodeInt64:self.childUserId forKey:@"childUserId"];
    [aCoder encodeObject:self.mobilePhoneNumber forKey:@"mobilePhoneNumber"];
    [aCoder encodeInt:self.userType forKey:@"userType"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.userId = [aDecoder decodeInt64ForKey:@"userId"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickName"];
        self.nicknameFirstLetter = [aDecoder decodeObjectForKey:@"nickNameFirstLetter"];
        self.avatarUrl = [aDecoder decodeObjectForKey:@"avatarUrl"];
        self.childUserId = [aDecoder decodeInt64ForKey:@"childUserId"];
        self.mobilePhoneNumber = [aDecoder decodeObjectForKey:@"mobilePhoneNumber"];
        self.userType = [aDecoder decodeIntForKey:@"userType"];
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"userId : %lld\n",self.userId];
    result = [result stringByAppendingFormat:@"username : %@\n",self.username];
    result = [result stringByAppendingFormat:@"nickName : %@\n",self.nickname];
    result = [result stringByAppendingFormat:@"nickNameFirstLetter : %@\n",self.nicknameFirstLetter];
    result = [result stringByAppendingFormat:@"avatarUrl : %@\n",self.avatarUrl];
    result = [result stringByAppendingFormat:@"childUserId : %lld\n",self.childUserId];
    result = [result stringByAppendingFormat:@"mobilePhoneNumber : %@\n",self.mobilePhoneNumber];
    result = [result stringByAppendingFormat:@"userType : %d\n",(int)self.userType];
    return result;
}


@end
