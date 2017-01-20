//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatDaoBase.h"
#import "TXCheckIn.h"


@interface TXCheckInDao : TXChatDaoBase {

}

- (NSArray *)queryCheckIns:(int64_t)maxCheckInId count:(int64_t)count error:(NSError **)outError;

- (TXCheckIn *)queryLastCheckIn;

- (void)addCheckIn:(TXCheckIn *)txCheckIn error:(NSError **)outError;

- (void)deleteAllCheckIn;

@end