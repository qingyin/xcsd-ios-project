//
//  XCSDHomeWorkRank.h
//  Pods
//
//  Created by gaoju on 16/3/18.
//
//

#import <Foundation/Foundation.h>
#import "TXEntityBase.h"
//#import "TXPBChat.pb.h"
#import "XCSDHomework.pb.h"

@interface XCSDHomeWorkRank : TXEntityBase
@property (nonatomic) int32_t rank;
@property (nonatomic) int64_t userId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic) int32_t score;

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

- (instancetype)loadValueFromPbObject:(XCSDPBUserRank*)xcsdHomeWorkRank;

@end
