//
//  NSObject+EXTParams.h
//  TXChat
//
//  Created by 陈爱彬 on 15/9/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EXTParams)

- (void)setTXExtParams:(id)param forKey:(NSString *)key;

- (id)extParamForKey:(NSString *)key;

- (void)removeTXExtParamsForKey:(NSString *)key;

- (void)removeAllTXExtParams;

@end
