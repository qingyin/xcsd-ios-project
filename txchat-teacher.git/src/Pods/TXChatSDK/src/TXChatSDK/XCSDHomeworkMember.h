//
//  XCSDHomeworkMember.h
//  Pods
//
//  Created by gaoju on 16/4/5.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"



@interface XCSDHomeworkMember : TXEntityBase
@property int64_t memberId;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* avatar;
@property XCSDPBHomeworkStatus status;
@property int32_t score;
@property BOOL specialAttention;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBHomeworkMember *)homeworkMember;
@end
