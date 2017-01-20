//
//  NSDictionary+Utils.m
//  TXChat
//
//  Created by lyt on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSDictionary+Utils.h"

@implementation NSDictionary (Utils)

//是否包含key
- (BOOL)containsKey: (NSString *)key
{
    BOOL retVal = 0;
    NSArray *allKeys = [self allKeys];
    retVal = [allKeys containsObject:key];
    return retVal;
}

@end
