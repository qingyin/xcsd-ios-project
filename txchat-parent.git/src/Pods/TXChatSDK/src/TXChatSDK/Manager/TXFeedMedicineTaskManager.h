//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"


@interface TXFeedMedicineTaskManager : TXChatManagerBase
- (NSArray *)getFeedMedicineTasks:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;

- (void)markFeedMedicineTaskAsRead:(int64_t)feedMedicineTaskId
                       onCompleted:(void (^)(NSError *error))onCompleted;

/**
* 发送喂药任务
*/
- (void)sendFeedMedicineTask:(NSString *)content
                    attaches:(NSArray/*<TXPBAttach>*/ *)attaches
                   beginDate:(int64_t)beginDate
                 onCompleted:(void (^)(NSError *error, int64_t feedMedicineTaskId))onCompleted;

/**
* 获取喂药任务列表
*/
- (void)fetchFeedMedicineTasks:(int64_t)maxId
                   onCompleted:(void (^)(NSError *error, NSArray *txFeedMedicineTasks, BOOL hasMore))onCompleted;

@end