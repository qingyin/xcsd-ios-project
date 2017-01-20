//
// Created by lingqingwan on 9/7/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXDeletedMessage.h"


@implementation TXDeletedMessage {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _msgId = [resultSet stringForColumn:@"msg_id"];
    _cmdMsgId = [resultSet stringForColumn:@"cmd_msg_id"];
    _fromUserId = [resultSet stringForColumn:@"from_user_id"];
    _toUserId = [resultSet stringForColumn:@"to_user_id"];
    _isGroup = [resultSet boolForColumn:@"is_group"];
    return self;
}

@end