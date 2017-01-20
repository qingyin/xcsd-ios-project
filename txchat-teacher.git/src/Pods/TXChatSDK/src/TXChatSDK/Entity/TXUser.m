//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//
#import "TXUser.h"

@implementation TXUser {

}

- (NSString *)tableName {
    return @"user";
}

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    return [self loadValueFromFMResultSetInner:resultSet];

    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _userId = [resultSet longLongIntForColumn:@"user_id"];
    _username = [resultSet stringForColumn:@"username"];
    _avatarUrl = [resultSet stringForColumn:@"avatar_url"];
    _mobilePhoneNumber = [resultSet stringForColumn:@"mobile_phone_number"];
    _sign = [resultSet stringForColumn:@"sign"];
    _userType = (TXPBUserType) [resultSet longForColumn:@"user_type"];
    _childUserId = [resultSet longLongIntForColumn:@"child_user_id"];
    _sex = (TXPBSexType) [resultSet longForColumn:@"sex"];
    _birthday = [resultSet longLongIntForColumn:@"birthday"];
    _className = [resultSet stringForColumn:@"class_name"];
    _gardenName = [resultSet stringForColumn:@"garden_name"];
    _classId = [resultSet longLongIntForColumn:@"class_id"];
    _gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    _location = [resultSet stringForColumn:@"location"];
    _positionName = [resultSet stringForColumn:@"position_name"];
    _nickname = [resultSet stringForColumn:@"nickname"];
    _nicknameFirstLetter = [resultSet stringForColumn:@"nickname_first_letter"];
    _realName = [resultSet stringForColumn:@"real_name"];
    _parentType = (TXPBParentType) [resultSet longForColumn:@"parent_type"];
    _positionId = [resultSet longLongIntForColumn:@"position_id"];
    _guarder = [resultSet stringForColumn:@"guarder"];
    _activated = [resultSet boolForColumn:@"activated"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBUser *)txpbUser {
    _userId = txpbUser.userId;
    _username = txpbUser.userName;
    _avatarUrl = txpbUser.avatar;
    _userType = txpbUser.userType;
    _mobilePhoneNumber = txpbUser.mobile;
    _childUserId = txpbUser.childUserId;
    _userType = txpbUser.userType;
    _nickname = txpbUser.nickname;
    _nicknameFirstLetter = txpbUser.firstLetter;
    _sign = txpbUser.sign;
    _sex = txpbUser.sexType;
    _birthday = txpbUser.birthday;
    _className = txpbUser.className;
    _gardenName = txpbUser.gardenName;
    _classId = txpbUser.classId;
    _gardenId = txpbUser.gardenId;
    _location = txpbUser.address;
    _positionId = txpbUser.positionId;
    _positionName = txpbUser.positionName;
    _realName = txpbUser.realname;
    _parentType = txpbUser.parentType;
    _realName = txpbUser.realname;
    _guarder = txpbUser.guarder;
    _activated = txpbUser.activated;

    return self;
}


@end
