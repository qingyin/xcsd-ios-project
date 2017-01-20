//
//  TXTrackManager.m
//  TXChatSDK
//
//  Created by lingqingwan on 10/22/15.
//  Copyright © 2015 lingiqngwan. All rights reserved.
//

#import "TXTrackManager.h"
#import "TXAlbum.h"
#import "TXTrack.h"

@implementation TXTrackManager
- (NSArray *)queryAlbums:(int64_t)maxAlbumId count:(int64_t)count {
    NSMutableArray *albums = [NSMutableArray array];

    for (int64_t i = 0; i < 10; i++) {
        TXAlbum *album = [[TXAlbum alloc] init];
        album.id = i;
        album.name = [NSString stringWithFormat:@"宝宝幼教专辑-%lld", i];
        album.coverUrl = [NSString stringWithFormat:@"http://s.tx2010.com/album-%lld.jpg", i];
        album.createdOn = album.updatedOn = (int64_t) (TIMESTAMP_OF_NOW);

        [albums addObject:album];
    }

    return albums;
}

- (NSArray *)queryTracksByAlbumId:(int64_t)albumId maxTrackId:(int64_t)maxTrackId count:(int64_t)count {
    NSMutableArray *tracks = [NSMutableArray array];

    for (int64_t i = 0; i < 10; i++) {
        TXTrack *track = [[TXTrack alloc] init];
        track.id = i;
        track.createdOn = track.updatedOn = (int64_t) (TIMESTAMP_OF_NOW);
        track.duration = 20000;
        track.url = @"http://s.tx2010.com/11C95CAC-79E9-47D4-8D35-62F0C379D77B.m4a";
        track.name = [NSString stringWithFormat:@"宝宝鬼故事-音频-%lld", i];
        track.trackType = TXTrackTypeAudio;
        track.albumId = 1;

        [tracks addObject:track];
    }

    for (int64_t i = 20; i < 30; i++) {
        TXTrack *track = [[TXTrack alloc] init];
        track.id = i;
        track.createdOn = track.updatedOn = (int64_t) (TIMESTAMP_OF_NOW);
        track.duration = 20000;
        track.url = @"http://v.iseeyoo.cn/video/2010/10/25/2a9f0f4e-e035-11df-9117-001e0bbb2442_001.mp4";
        track.name = [NSString stringWithFormat:@"宝宝鬼故事-视频-%lld", i];
        track.trackType = TXTrackTypeVideo;
        track.albumId = 1;

        [tracks addObject:track];
    }

    return tracks;
}

- (void)addTrackToRecentlyPlayedList:(int64_t)trackId {

}

- (NSArray *)queryRecentlyPlayedTracks {
    return nil;
}

- (void)resetTrackPlayProgressValue:(int64_t)trackId progressValue:(int64_t)progressValue {
    [[NSUserDefaults standardUserDefaults] setInteger:(NSInteger) (progressValue)
                                               forKey:[NSString stringWithFormat:@"track-play-progress-value-%lld", trackId]];
}

- (int64_t)queryTrackPlayProgressValue:(int64_t)trackId {
    return [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"track-play-progress-value-%lld", trackId]];
}

@end
