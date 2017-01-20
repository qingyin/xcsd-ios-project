//
//  TXPBLeave+Util.m
//  TXChatTeacher
//
//  Created by Cloud on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXPBLeave+Util.h"

static void *IsCompletedKey = (void *)@"IsCompletedKey";

@implementation TXPBLeave (Util)

- (NSNumber *)isCompleted{
    return objc_getAssociatedObject(self, IsCompletedKey);
}

- (void)setIsCompleted:(NSNumber *)isCompleted{
    objc_setAssociatedObject(self, IsCompletedKey, isCompleted, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
