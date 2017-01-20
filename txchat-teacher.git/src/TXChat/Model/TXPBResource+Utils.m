//
//  TXPBResource+Utils.m
//  TXChatParent
//
//  Created by lyt on 16/1/20.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXPBResource+Utils.h"
#import "NSObject+EXTParams.h"

@implementation TXPBResource (Utils)


-(void)addLikedNumber:(int64_t)likedNumber
{

    NSNumber *liked = [self extParamForKey:KTXPBRESOURCELIKED];
    if(liked)
    {
        [self setTXExtParams:@(liked.longLongValue+likedNumber) forKey:KTXPBRESOURCELIKED];
    }
    else
    {
        [self setTXExtParams:@(self.likedCount+likedNumber) forKey:KTXPBRESOURCELIKED];
    }
    [self setTXExtParams:@(YES) forKey:KTXPBRESOURCEISLIKED];
}

-(int64_t)getLikedNumber
{
    int64_t count = 0;
    
    NSNumber *liked = [self extParamForKey:KTXPBRESOURCELIKED];
    if(liked)
    {
        count = liked.longLongValue;
    }
    else
    {
        count = self.likedCount;
    }
    return count;
}

-(BOOL)isLiked
{
    BOOL isLiked = NO;
    NSNumber *liked = [self extParamForKey:KTXPBRESOURCELIKED];
    if(liked)
    {
        isLiked = liked.boolValue;
    }
    else
    {
        isLiked = self.liked;
    }
    return isLiked;
}

-(void)addViewedNumber:(int64_t)viewedNumber
{
    NSNumber *viewed = [self extParamForKey:KTXPBRESOURCEVIEWED];
    if(viewed)
    {
        [self setTXExtParams:@(viewed.longLongValue+viewedNumber) forKey:KTXPBRESOURCEVIEWED];
    }
    else
    {
        [self setTXExtParams:@(self.viewedCount+viewedNumber) forKey:KTXPBRESOURCEVIEWED];
    }
}

-(int64_t)getViewedNumber
{
    int64_t count = 0;
    NSNumber *viewed = [self extParamForKey:KTXPBRESOURCEVIEWED];
    if(viewed)
    {
        count = viewed.longLongValue;
    }
    else
    {
        count = self.viewedCount;
    }
    return count;
}


@end
