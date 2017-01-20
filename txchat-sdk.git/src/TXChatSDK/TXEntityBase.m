//
// Created by lingiqngwan on 6/7/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <objc/runtime.h>
#import <FMDB/FMResultSet.h>
#import "TXEntityBase.h"
#import "objc_runtime_ext.h"


@implementation TXEntityBase {
}

- (TXEntityBase *)init {
    if (self = [super init]) {
        _transientProperties = [NSMutableSet set];
        [_transientProperties addObject:@"transientProperties"];
    }
    return self;
}

- (NSString *)tableName {
    return nil;
}

- (NSString *)generateReplaceIntoSql {
    NSMutableString *sql = [[NSMutableString alloc] initWithCapacity:20];

    NSString *tableName = [self tableName];
    [sql appendFormat:@"REPLACE INTO %@(", tableName];

    unsigned int totalProperties = 0;
    Class subclass = [self class];
    while (subclass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass, &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];

            const char *propertyName = property_getName(property);
            if ([[self transientProperties] containsObject:@(propertyName)] || strcmp(propertyName, "id") == 0) {
                continue;
            }

            NSString *columnName = [self camelCaseWithString:@(propertyName)];
            [sql appendFormat:@"%@,", columnName];
            totalProperties++;
        }
        free(properties);
        subclass = [subclass superclass];
    }

    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@") VALUES ("];

    for (int i = 0; i < totalProperties; ++i) {
        [sql appendFormat:@"?,"];
    }

    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@")"];

    return sql;
}

- (NSArray *)propertyValues {
    NSMutableArray *values = [NSMutableArray array];
    Class subclass = [self class];
    while (subclass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass, &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            if ([[self transientProperties] containsObject:@(propertyName)] || strcmp(propertyName, "id") == 0) {
                continue;
            }

            [values addObject:[self valueForKey:@(propertyName)]];
        }
        free(properties);
        subclass = [subclass superclass];
    }
    return values;
}

- (instancetype)loadValueFromFMResultSetInner:(FMResultSet *)resultSet {
    Class subclass = [self class];
    while (subclass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass, &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            if ([[self transientProperties] containsObject:@(propertyName)]) {
                continue;
            }

            const char *propertyType = property_getType(property);
            NSString *columnName = [self camelCaseWithString:@(propertyName)];
            if (strcmp(propertyType, @encode(long long)) == 0) {
                [self setValue:@([resultSet longLongIntForColumn:columnName]) forKey:@(propertyName)];
            } else if (strcmp(propertyType, @encode(long)) == 0) {
                [self setValue:@([resultSet longForColumn:columnName]) forKey:@(propertyName)];
            } else if (strcmp(propertyType, @encode(int)) == 0) {
                [self setValue:@([resultSet intForColumn:columnName]) forKey:@(propertyName)];
            } else if (strcmp(propertyType, @encode(BOOL)) == 0) {
                [self setValue:@([resultSet boolForColumn:columnName]) forKey:@(propertyName)];
            } else if (strcmp(propertyType, "@\"NSString\"") == 0) {
                [self setValue:[resultSet stringForColumn:columnName] forKey:@(propertyName)];
            } else {
                NSLog(@"==================================================");
                NSLog(@"ERROR:Unexpected property %s %s", propertyName, propertyType);
                NSLog(@"==================================================");
            }
        }
        free(properties);
        subclass = [subclass superclass];
    }
    return self;
}

- (NSArray *)describablePropertyNames {
    NSMutableArray *array = [NSMutableArray array];
    Class subclass = [self class];
    while (subclass != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass, &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            [array addObject:@(propertyName)];
        }
        free(properties);
        subclass = [subclass superclass];
    }
    return array;
}

- (NSString *)description {
    NSMutableString *propertyDescriptions = [@"" mutableCopy];
    for (NSString *key in [self describablePropertyNames]) {
        id value = [self valueForKey:key];
        [propertyDescriptions appendFormat:@";%@=%@", key, value];
    }
    return [NSString stringWithFormat:@"<%@: 0x%lx%@>", [self class], (unsigned long) self, propertyDescriptions];
}

- (NSString *)camelCaseWithString:(NSString *)string {
    return [[string stringByReplacingOccurrencesOfString:@"([a-z])([A-Z])"
                                              withString:@"$1_$2"
                                                 options:NSRegularExpressionSearch
                                                   range:NSMakeRange(0, string.length)] lowercaseString];
}

@end