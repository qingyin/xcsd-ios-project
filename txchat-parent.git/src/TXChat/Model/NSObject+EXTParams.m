//
//  NSObject+EXTParams.m
//  TXChat
//
//  Created by 陈爱彬 on 15/9/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "NSObject+EXTParams.h"
#import <objc/runtime.h>

static char kTXObjectExtParamsKey;

@implementation NSObject (EXTParams)

- (void)setTXExtParams:(id)param forKey:(NSString *)key
{
    NSMutableDictionary *extParams = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXObjectExtParamsKey);
    if (!extParams) {
        extParams = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &kTXObjectExtParamsKey, extParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [extParams setValue:param forKey:key];
}

- (id)extParamForKey:(NSString *)key
{
    NSMutableDictionary *extParams = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXObjectExtParamsKey);
    if (!extParams) {
        return nil;
    }
    id param = [extParams valueForKey:key];
    return param;
}
- (void)removeTXExtParamsForKey:(NSString *)key
{
    NSMutableDictionary *extParams = (NSMutableDictionary *)objc_getAssociatedObject(self, &kTXObjectExtParamsKey);
    if (!extParams)
        return;
    [extParams setValue:nil forKey:key];
}

- (void)removeAllTXExtParams
{
    objc_setAssociatedObject(self, &kTXObjectExtParamsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
