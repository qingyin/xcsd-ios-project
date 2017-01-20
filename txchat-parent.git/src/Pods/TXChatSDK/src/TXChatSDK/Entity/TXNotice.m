//
// Created by lingqingwan on 6/11/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXNotice.h"


@implementation TXNotice {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _sentOn = [resultSet longLongIntForColumn:@"sent_on"];
    _content = [resultSet stringForColumn:@"content"];
    _fromUserId = [resultSet longLongIntForColumn:@"from_user_id"];
    _noticeId = [resultSet longLongIntForColumn:@"notice_id"];
    _isInbox = [resultSet boolForColumn:@"is_inbox"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    _attaches = attaches.length == 0
            ? [NSMutableArray array]
            : [[attaches componentsSeparatedByString:@","] mutableCopy];
    _isRead = [resultSet boolForColumn:@"is_read"];
    _senderAvatar = [resultSet stringForColumn:@"sender_avatar"];
    _senderName = [resultSet stringForColumn:@"sender_name"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBNotice *)txpbNotice {
    _content = txpbNotice.content;
    _fromUserId = txpbNotice.sendUserId;
    _noticeId = txpbNotice.id;
    _sentOn = txpbNotice.sendTime;
    _attaches = [[NSMutableArray alloc] init];
    for (uint i = 0; i < txpbNotice.attaches.count; ++i) {
        TXPBAttach *txpbAttach = txpbNotice.attaches[i];
        [_attaches addObject:txpbAttach.fileurl];
    }
    _isRead = txpbNotice.isRead;
    self.createdOn = txpbNotice.sendTime;
    _senderAvatar = txpbNotice.senderAvatar;
    _senderName = txpbNotice.senderName;
    return self;
}


@end