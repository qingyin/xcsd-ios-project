//
//  XCSDHomeworkRemainCount.h
//  Pods
//
//  Created by gaoju on 16/4/9.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"

@interface XCSDHomeworkRemainCount : TXEntityBase
@property (nonatomic) int64_t classId;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDHomeworkRemainCount *)remain;

@end
