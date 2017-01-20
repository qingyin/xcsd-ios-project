//
//  BroadcastVideoItem.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BroadcastVideoItem.h"

@implementation BroadcastVideoItem

- (NSString *)fileTypeExtension {
    return @".mp4";
}

//- (AUMediaType)itemType {
//    return AUMediaTypeVideo;
//}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_remotePath forKey:@"remotePath"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_ablumId forKey:@"ablumId"];
    [aCoder encodeObject:_coverUrl forKey:@"coverUrl"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[BroadcastVideoItem alloc] init];
    if (self) {
        _author = [aDecoder decodeObjectForKey:@"author"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _ablumId = [aDecoder decodeObjectForKey:@"ablumId"];
        _remotePath = [aDecoder decodeObjectForKey:@"remotePath"];
        _coverUrl = [aDecoder decodeObjectForKey:@"coverUrl"];
    }
    return self;
}

@end


@implementation BroadcastVideoAlbum

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_mediaItems forKey:@"mediaItems"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[BroadcastVideoAlbum alloc] init];
    if (self) {
        _author = [aDecoder decodeObjectForKey:@"author"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _mediaItems = [aDecoder decodeObjectForKey:@"mediaItems"];
    }
    return self;
}

- (BOOL)containsMediaType:(AUMediaType)type {
    if (type == AUMediaTypeVideo) {
        return YES;
    } else {
        return NO;
    }
}

@end