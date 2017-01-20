//
// Created by lingqingwan on 9/22/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"


@interface TXDepartmentPhotoManager : TXChatManagerBase

- (void)fetchDepartmentPhotos:(int64_t)departmentId
         maxDepartmentPhotoId:(int64_t)maxDepartmentPhotoId
        onCompleted:(void (^)(NSError *error, NSArray *txDepartmentPhotos, int64_t totalCount, BOOL hasMore))onCompleted;


- (NSArray *)queryDepartmentPhotos:(int64_t)departmentId
              maxDepartmentPhotoId:(int64_t)maxDepartmentPhotoId
                             count:(int64_t)count
                             error:(NSError **)outError;
@end