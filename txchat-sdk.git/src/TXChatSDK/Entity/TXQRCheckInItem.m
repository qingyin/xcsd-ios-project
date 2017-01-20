//
// Created by lingqingwan on 9/23/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXQrCheckInItem.h"


@implementation TXQrCheckInItem {

}

- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _targetUserId = [resultSet longLongIntForColumn:@"target_user_id"];
    _targetUsername = [resultSet stringForColumn:@"target_user_name"];
    _targetUserType = [resultSet stringForColumn:@"target_user_type"];
    _targetCardNumber = [resultSet stringForColumn:@"target_card_number"];
    _status = (TXQrCheckInItemStatus) [resultSet longForColumn:@"status"];
    return self;
}


@end