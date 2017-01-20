//
//  XCSDHomeworkMember.m
//  Pods
//
//  Created by gaoju on 16/4/5.
//
//

#import "XCSDHomeworkMember.h"

@implementation XCSDHomeworkMember
-(instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    _memberId=[resultSet longLongIntForColumn:@"memberId"];
    _name=[resultSet stringForColumn:@"name"];
    _avatar=[resultSet stringForColumn:@"avatar"];
    _status=(XCSDPBHomeworkStatus)[resultSet longForColumn:@"status"];
    _score=[resultSet intForColumn:@"score"];
    _specialAttention=[resultSet boolForColumn:@"specialAttention"];
    
    return self;
}

-(instancetype)loadValueFromPbObject:(XCSDPBHomeworkMember *)homeworkMember{
    _memberId=homeworkMember.memberId;
    _name=homeworkMember.name;
    _avatar=homeworkMember.avatar;
    _status=homeworkMember.status;
    _score=homeworkMember.score;
    _specialAttention=homeworkMember.specialAttention;
    
    return self;
}
@end
