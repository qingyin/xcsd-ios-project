//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "TXChatDef.h"

@class TXEntityBase;

#define FILL_OUT_ERROR_IF_NULL(errorMessage)                                                    \
    if (outError && !*outError) {                                                               \
        *outError = TX_ERROR_MAKE(TX_STATUS_UN_KNOW_ERROR, errorMessage );                      \
    }

#define SET_BASE_PROPERTIES_FROM_RESULT_SET(object)                                             \
    object.id = [resultSet longLongIntForColumn:@"id"];                                         \
    object.updatedOn = [resultSet longLongIntForColumn:@"updated_on"];                          \
    object.createdOn = [resultSet longLongIntForColumn:@"created_on"];                          \


@interface TXChatDaoBase : NSObject {
    FMDatabaseQueue *_databaseQueue;
}

- (instancetype)initWithFMDatabaseQueue:(FMDatabaseQueue *)fmDatabaseQueue;

- (void)insertObject:(TXEntityBase *)object error:(NSError **)error;

@end