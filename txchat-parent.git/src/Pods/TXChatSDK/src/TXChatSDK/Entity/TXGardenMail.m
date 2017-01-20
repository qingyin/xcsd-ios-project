//
// Created by lingqingwan on 6/29/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXGardenMail.h"


@implementation TXGardenMail {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _gardenMailId = [resultSet longLongIntForColumn:@"garden_mail_id"];
    _gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    _gardenName = [resultSet stringForColumn:@"garden_name"];
    _gardenAvatarUrl = [resultSet stringForColumn:@"garden_avatar_url"];
    _isAnonymous = [resultSet boolForColumn:@"is_anonymous"];
    _fromUserId = (TXPBPostType) [resultSet intForColumn:@"from_user_id"];
    _fromUsername = [resultSet stringForColumn:@"from_user_name"];
    _fromUserAvatarUrl = [resultSet stringForColumn:@"from_user_avatar_url"];
    _isRead = [resultSet boolForColumn:@"is_read"];
    _content = [resultSet stringForColumn:@"content"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBGardenMail *)txpbGardenMail {
    _gardenMailId = txpbGardenMail.id;
    _gardenId = txpbGardenMail.gardenId;
    _gardenName = txpbGardenMail.gardenName;
    _gardenAvatarUrl = txpbGardenMail.gardenAvatarUrl;
    _content = txpbGardenMail.content;
    self.createdOn = txpbGardenMail.createdOn;
    _isAnonymous = txpbGardenMail.anonymous;
    _fromUserId = txpbGardenMail.fromUserId;
    _fromUsername = txpbGardenMail.fromUsername;
    _fromUserAvatarUrl = txpbGardenMail.fromUserAvatarUrl;
    self.updatedOn = txpbGardenMail.updateOn;
    _isRead = txpbGardenMail.hasRead;
    return self;
}


@end