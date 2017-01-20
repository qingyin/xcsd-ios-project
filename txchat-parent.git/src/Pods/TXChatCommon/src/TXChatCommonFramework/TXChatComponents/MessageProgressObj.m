//
//  MessageProgressObj.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/16.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "MessageProgressObj.h"

@interface MessageProgressObj()

@property (nonatomic,copy) MessageProgressBlock progressBlock;
@end

@implementation MessageProgressObj

- (instancetype)initWithProgressBlock:(MessageProgressBlock)block
{
    self = [super init];
    if (self) {
        _progressBlock = block;
    }
    return self;
}
- (void)setProgress:(float)progress forMessage:(EMMessage *)message forMessageBody:(id<IEMMessageBody>)messageBody
{
    _progressBlock(progress);
}
@end
