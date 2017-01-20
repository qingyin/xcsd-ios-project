//
// Created by lingqingwan on 9/23/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TXBlockingQueue : NSObject
- (void)put:(NSObject *)object;

- (NSObject *)take;

- (void)removeAll;
@end