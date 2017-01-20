//
//  MessageProgressObj.h
//  TXChat
//
//  Created by 陈爱彬 on 15/7/16.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EaseMob.h>

typedef void(^MessageProgressBlock)(float progress);

@interface MessageProgressObj : NSObject
<IEMChatProgressDelegate>

- (instancetype)initWithProgressBlock:(MessageProgressBlock)block;

@end
