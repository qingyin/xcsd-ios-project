//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TXGardenMailManager : NSObject
/**
* 园长信箱发信
*/
- (void)sendGardenMail:(NSString *)content
           isAnonymous:(BOOL)isAnonymous
           onCompleted:(void (^)(NSError *error, int64_t gardenMailId))onCompleted;

/**
* 获取园长信箱邮件
*/
- (void)fetchGardenMails:(int64_t)maxId
             onCompleted:(void (^)(NSError *error, NSArray *txGardenMails, BOOL hasMore))onCompleted;


- (NSArray *)getGardenMails:(int64_t)maxId count:(int64_t)count error:(NSError **)outError;


- (void)markGardenMailAsRead:(int64_t)gardenMailId
                 onCompleted:(void (^)(NSError *error))onCompleted;

@end