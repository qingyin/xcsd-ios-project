//
// Created by lingqingwan on 6/12/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <FMDB/FMResultSet.h>
#import "TXCheckIn.h"


@implementation TXCheckIn {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    _clientKey = [resultSet longLongIntForColumn:@"client_key"];
    _userId = [resultSet longLongIntForColumn:@"user_id"];
    _username = [resultSet stringForColumn:@"username"];
    _gardenId = [resultSet longLongIntForColumn:@"garden_id"];
    _machineId = [resultSet longLongIntForColumn:@"machine_id"];
    _checkInId = [resultSet longLongIntForColumn:@"checkin_id"];
    _checkInTime = [resultSet longLongIntForColumn:@"checkin_time"];
    _className = [resultSet stringForColumn:@"class_name"];
    _parentName = [resultSet stringForColumn:@"parent_name"];
    _cardCode = [resultSet stringForColumn:@"card_code"];
    NSString *attaches = [resultSet stringForColumn:@"attaches"];
    _attaches = attaches.length == 0 ?
            [NSMutableArray array] :
            [[attaches componentsSeparatedByString:@","] mutableCopy];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBCheckin *)txpbCheckIn {
    _cardCode = txpbCheckIn.cardCode;
    _checkInId = txpbCheckIn.id;
    _checkInTime = txpbCheckIn.checkinTime;
    _clientKey = 0;
    _gardenId = txpbCheckIn.gardenId;
    _userId = txpbCheckIn.userId;
    _username = txpbCheckIn.userName;
    _attaches = [[NSMutableArray alloc] init];
    [_attaches addObject:[txpbCheckIn attach].fileurl];
    _className = txpbCheckIn.className;
    _parentName = txpbCheckIn.parentName;
    return self;
}

@end