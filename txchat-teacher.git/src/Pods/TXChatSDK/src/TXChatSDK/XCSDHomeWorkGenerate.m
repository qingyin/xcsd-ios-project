//
//  XCSDHomeWorkGenerate.m
//  Pods
//
//  Created by gaoju on 16/4/6.
//
//

#import "XCSDHomeWorkGenerate.h"

@implementation XCSDHomeWorkGenerate
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    _childUserId=[resultSet longLongIntForColumn:@"childUserId"];
    _name=[resultSet stringForColumn:@"name"];
    _avatar=[resultSet stringForColumn:@"avatar"];
    _generateCount=[resultSet intForColumn:@"generateCount"];
    _remainMaxCount=[resultSet intForColumn:@"remainMaxCount"];
    _specialAttention=[resultSet boolForColumn:@"specialAttention"];
    return self;
}

- (instancetype)loadValueFromPbObject:(XCSDPBGenerateHomeworkResponseUserHomework *)homeWork{
    
    _childUserId=homeWork.childUserId;
    _name=homeWork.name;
    _avatar=homeWork.avatar;
    _generateCount=homeWork.generateCount;
    _remainMaxCount=homeWork.remainMaxCount;
    _specialAttention=homeWork.specialAttention;
    return self;
    
}
@end
