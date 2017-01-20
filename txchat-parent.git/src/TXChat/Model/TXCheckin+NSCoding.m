//
//  TXCheckin+NSCoding.m
//  TXChat
//
//  Created by Cloud on 15/6/13.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXCheckIn+NSCoding.h"

@implementation TXCheckIn (NSCoding)

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt64:self.checkInId forKey:@"checkinId"];
    [aCoder encodeObject:self.cardCode forKey:@"cardCode"];
    [aCoder encodeObject:self.attaches forKey:@"attaches"];
    [aCoder encodeInt64:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeInt64:self.checkInTime forKey:@"checkinTime"];
    [aCoder encodeInt64:self.gardenId forKey:@"gardenId"];
    [aCoder encodeInt64:self.machineId forKey:@"machineId"];
    [aCoder encodeInt64:self.clientKey forKey:@"clientKey"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.checkInId = [aDecoder decodeInt64ForKey:@"checkinId"];
        self.cardCode = [aDecoder decodeObjectForKey:@"cardCode"];
        self.attaches = [aDecoder decodeObjectForKey:@"attaches"];
        self.userId = [aDecoder decodeInt64ForKey:@"userId"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.checkInTime = [aDecoder decodeInt64ForKey:@"checkinTime"];
        self.gardenId = [aDecoder decodeInt64ForKey:@"gardenId"];
        self.machineId = [aDecoder decodeInt64ForKey:@"machineId"];
        self.clientKey = [aDecoder decodeInt64ForKey:@"clientKey"];
        self.parentName = [aDecoder decodeObjectForKey:@"parentName"];
        self.className = [aDecoder decodeObjectForKey:@"className"];
    }
    return self;
}

- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"checkinId : %lld\n",self.checkInId];
    result = [result stringByAppendingFormat:@"cardCode : %@\n",self.cardCode];
    result = [result stringByAppendingFormat:@"attaches : %@\n",self.attaches];
    result = [result stringByAppendingFormat:@"userId : %lld\n",self.userId];
    result = [result stringByAppendingFormat:@"username : %@\n",self.username];
    result = [result stringByAppendingFormat:@"checkinTime : %lld\n",self.checkInTime];
    result = [result stringByAppendingFormat:@"gardenId : %lld\n",self.gardenId];
    result = [result stringByAppendingFormat:@"machineId : %lld\n",self.machineId];
    result = [result stringByAppendingFormat:@"clientKey : %lld\n",self.clientKey];
    result = [result stringByAppendingFormat:@"parentName:%@\n",self.parentName];
    result = [result stringByAppendingFormat:@"className:%@\n",self.className];
    return result;
}


@end
