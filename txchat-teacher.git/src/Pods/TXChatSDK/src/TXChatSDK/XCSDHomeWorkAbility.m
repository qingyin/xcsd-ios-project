//
//  XCSDHomeWorkAbility.m
//  Pods
//
//  Created by gaoju on 16/4/13.
//
//

#import "XCSDHomeWorkAbility.h"

@implementation XCSDHomeWorkAbility
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    _ability=(XCSDPBAbility)[resultSet longForColumn:@"ability"];
    _value=[resultSet intForColumn:@"value"];
    _rank=[resultSet intForColumn:@"rank"];
    _userId=[resultSet longLongIntForColumn:@"userId"];
    _name=[resultSet stringForColumn:@"name"];
    _avatar=[resultSet stringForColumn:@"avatar"];
    _score=[resultSet intForColumn:@"score"];
        return self;
}

- (instancetype)loadValueFromPbObject:(XCSDPBUserRank *)homeWorkAbility{
    
    _rank=homeWorkAbility.rank;
    _userId=homeWorkAbility.userId;
    _name=homeWorkAbility.name;
    _avatar=homeWorkAbility.avatar;
    _score=homeWorkAbility.score;

    return self;
}
@end
