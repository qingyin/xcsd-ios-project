//
// Created by lingqingwan on 12/17/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "objc_runtime_ext.h"

const char *property_getType(objc_property_t property) {
    const char *propertyAttributes = property_getAttributes(property);
    NSArray *attributes = [[NSString stringWithUTF8String:propertyAttributes] componentsSeparatedByString:@","];
    NSString *propertyType = [[attributes objectAtIndex:0] substringFromIndex:1];
    return [propertyType UTF8String];
}