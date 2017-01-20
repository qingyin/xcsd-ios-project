//
// Created by lingqingwan on 9/22/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatDaoBase.h"
#import "TXDepartmentPhoto.h"

@interface TXDepartmentPhotoDao : TXChatDaoBase
- (NSArray *)queryDepartmentPhotos:(int64_t)departmentId
              maxDepartmentPhotoId:(int64_t)maxDepartmentPhotoId
                             count:(int64_t)count
                             error:(NSError **)outError;

- (void)addDepartmentPhoto:(TXDepartmentPhoto *)txDepartmentPhoto error:(NSError **)outError;

- (void)deleteAllDepartmentPhotosWithDepartmentId:(int64_t)departmentId;

@end