//
// Created by lingiqngwan on 6/7/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMResultSet.h>
#import "TXPBChat.pb.h"

#define SET_BASE_PROPERTIES_FROM_RESULT_SET(object)                                             \
    object.id = [resultSet longLongIntForColumn:@"id"];                                         \
    object.updatedOn = [resultSet longLongIntForColumn:@"updated_on"];                          \
    object.createdOn = [resultSet longLongIntForColumn:@"created_on"];                          \


@interface TXEntityBase : NSObject
@property(nonatomic) int64_t id;
@property(nonatomic) int64_t updatedOn;
@property(nonatomic) int64_t createdOn;

@property(nonatomic, strong) NSMutableSet *transientProperties;

- (NSString *)tableName;

- (NSString *)generateReplaceIntoSql;

- (NSArray *)propertyValues;

- (instancetype)loadValueFromFMResultSetInner:(FMResultSet *)resultSet;

- (NSArray *)describablePropertyNames;

@end