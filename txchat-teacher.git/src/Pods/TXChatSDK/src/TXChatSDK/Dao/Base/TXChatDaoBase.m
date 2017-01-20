//
// Created by lingqingwan on 9/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <FMDB/FMDatabaseQueue.h>
#import "TXChatDaoBase.h"
#import "TXEntityBase.h"


@implementation TXChatDaoBase {

}
- (instancetype)initWithFMDatabaseQueue:(FMDatabaseQueue *)fmDatabaseQueue {
    if (self = [super init]) {
        _databaseQueue = fmDatabaseQueue;
    }
    return self;
}

- (void)insertObject:(TXEntityBase *)object error:(NSError **)error {
    object.createdOn = object.updatedOn = (int64_t) TIMESTAMP_OF_NOW;
    NSString *sql = [object generateReplaceIntoSql];

    NSLog(@"SQL REPLACE INTO %@ %@", object.tableName, object);

    [_databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL ok = [db executeUpdate:sql withArgumentsInArray:[object propertyValues]];
        if (!ok) {
            if (error && !*error) {
                NSString *errorMessage = [NSString stringWithFormat:@"ERROR:execute sql %@", sql];
                *error = TX_ERROR_MAKE(TX_STATUS_UN_KNOW_ERROR, errorMessage);
            }
        }
    }];
}


@end