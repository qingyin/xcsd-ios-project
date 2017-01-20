//
// Created by lingqingwan on 7/15/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXPost.h"


@implementation TXPost {

}
- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet {
    SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
    _postId = [resultSet longLongIntForColumn:@"post_id"];
    _title = [resultSet stringForColumn:@"title"];
    _summary = [resultSet stringForColumn:@"summary"];
    _content = [resultSet stringForColumn:@"content"];
    _coverImageUrl = [resultSet stringForColumn:@"cover_image_url"];
    _postType = (TXPBPostType) [resultSet intForColumn:@"post_type"];
    _groupId = [resultSet longLongIntForColumn:@"group_id"];
    _orderValue = [resultSet longLongIntForColumn:@"order_value"];
    _postUrl = [resultSet stringForColumn:@"post_url"];
    _gardenId= [resultSet longLongIntForColumn:@"garden_id"];
    return self;
}

- (instancetype)loadValueFromPbObject:(TXPBPost *)txpbPost groupId:(int64_t)groupId {
    _postId = txpbPost.id;
    _groupId = groupId;
    _postType = txpbPost.postType;
    _coverImageUrl = txpbPost.coverImageUrl;
    _content = txpbPost.content;
    _summary = txpbPost.summary;
    _title = txpbPost.title;
    self.createdOn = txpbPost.createdOn;
    _orderValue = txpbPost.orderValue;
    _postUrl = txpbPost.postUrl;
    return self;
}


@end