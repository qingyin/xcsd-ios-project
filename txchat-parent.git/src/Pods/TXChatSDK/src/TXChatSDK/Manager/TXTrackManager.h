//
//  TXTrackManager.h
//  TXChatSDK
//
//  Created by lingqingwan on 10/22/15.
//  Copyright © 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"

@interface TXTrackManager : TXChatManagerBase

/**
 * 获取专辑列表
 */
- (NSArray *)queryAlbums:(int64_t)maxAlbumId
                   count:(int64_t)count;

/**
 * 获取指定专辑中的音视频列表
 */
- (NSArray *)queryTracksByAlbumId:(int64_t)albumId
                       maxTrackId:(int64_t)maxTrackId
                            count:(int64_t)count;

/**
 * 加入最近播放列表
 */
- (void)addTrackToRecentlyPlayedList:(int64_t)trackId;

/**
 * 获取最近播放列表
 */
- (NSArray *)queryRecentlyPlayedTracks;

/**
 * 重置音轨播放进度
 */
- (void)resetTrackPlayProgressValue:(int64_t)trackId
                      progressValue:(int64_t)progressValue;

/**
 * 获取播放进度
 */
- (int64_t)queryTrackPlayProgressValue:(int64_t)trackId;

@end
