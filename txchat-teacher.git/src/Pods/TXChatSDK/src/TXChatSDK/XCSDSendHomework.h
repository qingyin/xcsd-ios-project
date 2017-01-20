//
//  XCSDSendHomework.h
//  Pods
//
//  Created by gaoju on 16/4/6.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"

@interface XCSDSendHomework : TXEntityBase
@property (nonatomic)XCSDPBStudentScope scope;
@property (nonatomic) int64_t classId;
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDSendHomework *)homeWork;

@end
