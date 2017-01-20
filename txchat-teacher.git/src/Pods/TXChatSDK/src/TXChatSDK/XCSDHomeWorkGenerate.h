//
//  XCSDHomeWorkGenerate.h
//  Pods
//
//  Created by gaoju on 16/4/6.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"

@interface XCSDHomeWorkGenerate : TXEntityBase
@property (nonatomic) int64_t childUserId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* avatar;
@property (nonatomic) int32_t generateCount;
@property (nonatomic) int32_t remainMaxCount;
@property (nonatomic) BOOL specialAttention;


- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBGenerateHomeworkResponseUserHomework *)homeWork;
@end
