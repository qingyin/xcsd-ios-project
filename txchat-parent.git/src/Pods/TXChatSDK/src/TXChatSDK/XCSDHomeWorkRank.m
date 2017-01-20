//
//  XCSDHomeWorkRank.m
//  Pods
//
//  Created by gaoju on 16/3/18.
//
//

#import "XCSDHomeWorkRank.h"

@implementation XCSDHomeWorkRank

-(instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _rank=[resultSet intForColumn:@"rank"];
    _userId=[resultSet longLongIntForColumn:@"userId"];
    _name=[resultSet stringForColumn:@"name"];
    _avatar=[resultSet stringForColumn:@"avatar"];
    _score=[resultSet intForColumn:@"score"];
    
    return self;
}

-(instancetype)loadValueFromPbObject:(XCSDPBUserRank *)xcsdHomeWorkRank{
    _rank=xcsdHomeWorkRank.rank;
    _userId=xcsdHomeWorkRank.userId;
    _name=xcsdHomeWorkRank.name;
    _avatar=xcsdHomeWorkRank.avatar;
    _score=xcsdHomeWorkRank.score;
    
    return self;
}

@end
