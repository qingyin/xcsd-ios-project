//
//  TXPatchManager.m
//  TXChat
//
//  Created by 陈爱彬 on 15/8/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXPatchManager.h"
//#import <JSPatch/JSPatch.h>

@implementation TXPatchManager

//创建单例
+ (instancetype)sharedManager
{
    static TXPatchManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
//        [JSPatch startWithAppKey:@"968e51339ee9673c"];
    }
    return self;
}
#pragma mark - Public
//开启Engine
- (void)startEngine
{
    DDLogDebug(@"开启JSPatchEngine");
}
@end
