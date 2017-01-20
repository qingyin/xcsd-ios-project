//
// Created by lingqingwan on 7/5/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXFeed.h"

@implementation TXFeed {

}

- (instancetype)init {
    if (self = [super init]) {
        _attaches = [NSMutableArray array];
    }
    return self;
}

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _userAvatarUrl = [resultSet stringForColumn:@"user_avatar_url"];
    _userNickName = [resultSet stringForColumn:@"user_nick_name"];
    _userId = [resultSet longLongIntForColumn:@"user_id"];
    _feedId = [resultSet longLongIntForColumn:@"feed_id"];
    _content = [resultSet stringForColumn:@"content"];
    _isInbox = [resultSet boolForColumn:@"is_inbox"];
    NSString *attachesJsonString = [resultSet stringForColumn:@"attaches"];
    NSArray *attachesArray = [NSJSONSerialization JSONObjectWithData:[attachesJsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:0
                                                               error:nil];
    if (attachesArray) {
        for (NSDictionary *dictionary in attachesArray) {
            TXPBAttachBuilder *attachBuilder = [TXPBAttach builder];
            attachBuilder.attachType = (TXPBAttachType) [[dictionary valueForKey:@"type"] intValue];
            attachBuilder.fileurl = [dictionary valueForKey:@"url"];
            [_attaches addObject:[attachBuilder build]];
        }
    }

    _userType = (TXPBUserType) [resultSet longLongIntForColumn:@"user_type"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBFeed *)txpbFeed {
    _content = txpbFeed.content;
    self.createdOn = txpbFeed.createOn;
    _feedId = txpbFeed.id;
    _userId = txpbFeed.userId;
    _userNickName = txpbFeed.userNickName;
    _userAvatarUrl = txpbFeed.userAvatarUrl;
    _attaches = [NSMutableArray arrayWithArray:txpbFeed.attaches];
    _hasMoreComment = txpbFeed.hasMoreComment;
    _userType = txpbFeed.userType;
    _feedType = TXFeedTypePlain;
    return self;
}

@end