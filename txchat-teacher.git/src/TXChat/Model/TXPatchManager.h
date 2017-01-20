//
//  TXPatchManager.h
//  TXChat
//
//  Created by 陈爱彬 on 15/8/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXPatchManager : NSObject

+ (TXPatchManager *)sharedManager;

- (void)startEngine;

@end
