//
// Created by lingqingwan on 7/6/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXComment.h"


@implementation TXComment {

}

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _commentId = [resultSet longLongIntForColumn:@"comment_id"];
    _targetId = [resultSet longLongIntForColumn:@"target_id"];
    _content = [resultSet stringForColumn:@"content"];
    _targetUserId = [resultSet longLongIntForColumn:@"target_user_id"];
    _targetType = (TXPBTargetType) [resultSet longLongIntForColumn:@"target_type"];
    _commentType = (TXPBCommentType) [resultSet longLongIntForColumn:@"comment_type"];
    _toUserId = [resultSet longLongIntForColumn:@"to_user_id"];
    _toUserNickname = [resultSet stringForColumn:@"to_user_nickname"];
    _userId = [resultSet longLongIntForColumn:@"user_id"];
    _userNickname = [resultSet stringForColumn:@"user_nickname"];
    _userAvatarUrl = [resultSet stringForColumn:@"user_avatar_url"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBComment *)txpbComment {
    _commentId = txpbComment.id;
    _targetId = txpbComment.targetId;
    _content = txpbComment.content;
    self.createdOn = txpbComment.createOn;
    _targetUserId = txpbComment.targetUserId;
    _targetType = txpbComment.targetType;
    _commentType = txpbComment.commentType;
    _toUserId = txpbComment.toUserId;
    _toUserNickname = txpbComment.toUserNickName;
    _userId = txpbComment.userId;
    _userNickname = txpbComment.userNickName;
    _userAvatarUrl = txpbComment.userAvatarUrl;
    _userTitle=txpbComment.userTitle;
    _userType=txpbComment.userType;
    
    return self;
}


@end