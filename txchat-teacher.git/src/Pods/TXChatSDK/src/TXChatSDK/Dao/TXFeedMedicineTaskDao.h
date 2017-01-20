//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXFeedMedicineTask.h"
#import "TXChatDaoBase.h"

@interface TXFeedMedicineTaskDao : TXChatDaoBase
- (void)addFeedMedicineTask:(TXFeedMedicineTask *)txFeedMedicineTask error:(NSError **)outError;

- (NSArray *)queryFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;

- (void)deleteAllFeedMedicineTask;

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId error:(NSError **)outError;

@end