//
//  XCSDHomeWorkAbility.h
//  Pods
//
//  Created by gaoju on 16/4/13.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
#import "XCSDHomework.pb.h"
#import "XCSDLearningAbility.pb.h"

@interface XCSDHomeWorkAbility : TXEntityBase
@property (nonatomic) XCSDPBAbility ability;
@property (nonatomic) int32_t value;
@property (nonatomic) int32_t rank;
@property (nonatomic) int64_t userId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic) int32_t score;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBUserRank *)homeWorkAbility;
@end
