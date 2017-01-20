//
//  TXMediaItem.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/19.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXMediaItem.h"

@implementation TXMediaItem

- (NSString *)fileTypeExtension {
    return @".dat";
}

//- (AUMediaType)itemType {
//    return AUMediaTypeAudio;
//}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_remotePath forKey:@"remotePath"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_ablumId forKey:@"ablumId"];
    [aCoder encodeObject:_fileTypeExtension forKey:@"fileTypeExtension"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[TXMediaItem alloc] init];
    if (self) {
        _author = [aDecoder decodeObjectForKey:@"author"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _ablumId = [aDecoder decodeObjectForKey:@"ablumId"];
        _remotePath = [aDecoder decodeObjectForKey:@"remotePath"];
        _fileTypeExtension = [aDecoder decodeObjectForKey:@"fileTypeExtension"];
    }
    return self;
}


@end

@implementation TXMediaAudioItem

- (NSString *)fileTypeExtension {
    return @".mp3";
}

@end

@implementation TXMediaVideoItem

- (NSString *)fileTypeExtension {
    return @".mp4";
}
- (AUMediaType)itemType {
    return AUMediaTypeVideo;
}
@end

@implementation TXMediaCollection

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_uid forKey:@"uid"];
    [aCoder encodeObject:_mediaItems forKey:@"mediaItems"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [[TXMediaCollection alloc] init];
    if (self) {
        _author = [aDecoder decodeObjectForKey:@"author"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _mediaItems = [aDecoder decodeObjectForKey:@"mediaItems"];
    }
    return self;
}

- (BOOL)containsMediaType:(AUMediaType)type {
    if (type == AUMediaTypeAudio) {
        return YES;
    } else {
        return NO;
    }
}

@end