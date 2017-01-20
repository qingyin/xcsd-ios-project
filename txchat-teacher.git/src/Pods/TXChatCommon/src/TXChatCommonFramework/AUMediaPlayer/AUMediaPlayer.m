//
//  AUMedia.m
//  AUMedia
//
//  Created by Dev on 2/11/15.
//  Copyright (c) 2015 AppUnite. All rights reserved.
//

// Observe for current Item.
// Bind AVPLayerItem with item

#import "AUMediaPlayer.h"
#import <objc/runtime.h>
#import "NSError+AUMedia.h"

@interface AUMediaPlayer() {
    id _timeObserver;
    BOOL _shouldPlayWhenPlayerIsReady;
    BOOL _playing;
    UIBackgroundTaskIdentifier _bgTaskId;
    //是否已经快播放完毕，避免多次收到通知导致重复请求的问题
    BOOL _isHasReachedEnd;
}
@property (nonatomic, readwrite) BOOL playbackTimesAreValid;
@property (nonatomic, readwrite) NSUInteger currentPlaybackTime;
@property (nonatomic, readwrite) NSUInteger duration;

@property (nonatomic, strong) NSArray *queue;
@property (nonatomic, strong) NSArray *shuffledQueue;

@end

static const void *AVPlayerItemAssociatedItem = &AVPlayerItemAssociatedItem;

static void *AVPlayerPlaybackRateObservationContext = &AVPlayerPlaybackRateObservationContext;
static void *AVPlayerPlaybackStatusObservationContext = &AVPlayerPlaybackStatusObservationContext;
static void *AVPlayerPlaybackCurrentItemObservationContext = &AVPlayerPlaybackCurrentItemObservationContext;
static void *AVPlayerPlaybackCurrentItemOldObservationContext = &AVPlayerPlaybackCurrentItemOldObservationContext;
static void *AVPlayerPlaybackBufferEmptyObservationContext = &AVPlayerPlaybackBufferEmptyObservationContext;

@implementation AUMediaPlayer

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static AUMediaPlayer *sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _library = [[AUMediaLibrary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
        self.playbackIsResumedAfterInterruptions = YES;
        self.currentIndex = -1;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getters/setters

- (void)setQueue:(NSArray *)queue {
    _queue = queue;
    [self shuffleQueue];
}

- (void)setNowPlayingCover:(UIImage *)nowPlayingCover {
    _nowPlayingCover = nowPlayingCover;
    [self updateNowPlayingInfoCenterData];
}

#pragma mark - Player actions

- (void)playItem:(id<AUMediaItem>)item error:(NSError *__autoreleasing *)error {
    self.queue = @[item];
    self.currentIndex = 0;
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:item error:error finished:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [strongSelf isCanPlay]) {
            [strongSelf play];
        }
    }];
    //    [self play];
}

- (void)playItemQueue:(id<AUMediaItemCollection>)collection error:(NSError *__autoreleasing *)error {
    self.queue = collection.mediaItems;
    self.currentIndex = 0;
    //    id<AUMediaItem>item = _shuffle ? [self.shuffledQueue objectAtIndex:0] : [self.queue objectAtIndex:0];
    id<AUMediaItem>item = _shuffle ? [self.shuffledQueue objectAtIndex:_currentIndex] : [self.queue objectAtIndex:_currentIndex];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:item error:error finished:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [strongSelf isCanPlay]) {
            [strongSelf play];
        }
    }];
    //    [self play];
}
//播放特定index的视频
- (void)playItemQueue:(id<AUMediaItemCollection>)collection
              atIndex:(NSInteger)index
                error:(NSError *__autoreleasing *)error
{
    self.queue = collection.mediaItems;
    self.currentIndex = index;
    //    id<AUMediaItem>item = [self.queue objectAtIndex:index];
    id<AUMediaItem>item = [self.queue objectAtIndex:_currentIndex];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:item error:error finished:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf && [strongSelf isCanPlay]) {
            [strongSelf play];
        }
    }];
    //    [self play];
}

- (void)play {
    if (_player.status == AVPlayerStatusReadyToPlay) {
        [_player play];
    } else {
        _shouldPlayWhenPlayerIsReady = YES;
    }
    _playing = YES;
}

- (void)pause {
    [_player pause];
    _playing = NO;
    _shouldPlayWhenPlayerIsReady = NO;
}

- (void)stop {
    [_player pause];
    _playing = NO;
    _shouldPlayWhenPlayerIsReady = NO;
    [self replaceCurrentItemWithNewPlayerItem:nil];
    self.queue = @[];
    self.currentIndex = -1;
}

- (void)stopCurrentItem {
    [_player pause];
    _playing = NO;
    _shouldPlayWhenPlayerIsReady = NO;
    [self replaceCurrentItemWithNewPlayerItem:nil];
}
//从头开始播放
- (void)playFromBegining
{
    [_player seekToTime:kCMTimeZero];
    if ([self isCanPlay]) {
        [self play];
    }
}
- (void)playItemFromCurrentQueueAtIndex:(NSUInteger)index {
    if (index >= self.queueLength) {
        NSAssert(NO, @"Given index exceeds queue length");
        return;
    }
    
    NSError *error;
    self.currentIndex = index;
    //    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:index];
    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:_currentIndex];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:nextItem error:&error finished:^{
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
        }else{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && [strongSelf isCanPlay]) {
                [strongSelf play];
            }
        }
    }];
    
    //    if (error) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
    //        return;
    //    }
    //
    //    [self play];
}

- (BOOL)tryPlayingItemFromCurrentQueue:(id<AUMediaItem>)item {
    NSInteger index = [self findIndexForItem:item];
    if (index < 0) {
        return NO;
    }
    
    NSError *error;
    self.currentIndex = index;
    //    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:index];
    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:_currentIndex];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:nextItem error:&error finished:^{
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
        }else{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf && [strongSelf isCanPlay]) {
                [strongSelf play];
            }
        }
    }];
    
    //    if (error) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
    //        return NO;
    //    }
    //
    //    [self play];
    
    return YES;
}

- (void)playNext {
    NSError *error = nil;
    
    //    NSUInteger nextTrackIndex = (self.currentlyPlayedTrackIndex + 1) % self.queue.count;
    if (self.currentIndex < self.queue.count - 1) {
        self.currentIndex += 1;
    }else{
        if (self.repeat == AUMediaRepeatModeOn) {
            self.currentIndex = 0;
        }else{
            NSLog(@"当前已经播放到最后一首,return掉");
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : [NSError errorWithDomain:@"没有下一首可以播放" code:-10000 userInfo:nil]}];
            return;
        }
    }
    NSUInteger nextTrackIndex = self.currentIndex % self.queue.count;
    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:nextTrackIndex];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:nextItem error:&error finished:^{
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
        }else{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (strongSelf.repeat == AUMediaRepeatModeOn || nextTrackIndex > 0) {
                    [strongSelf play];
                } else {
                    [strongSelf pause];
                }
            }
        }
    }];
    
    //    if (error) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
    //        return;
    //    }
    //
    //    if (_repeat == AUMediaRepeatModeOn || nextTrackIndex > 0) {
    //        [self play];
    //    } else {
    //        [self pause];
    //    }
}

- (void)playPrevious {
    if (_currentPlaybackTime > 2) {
        [_player seekToTime:kCMTimeZero];
        return;
    }
    
    NSUInteger nextTrackIndex = 0;
    //    NSInteger currentTrackIndex = self.currentlyPlayedTrackIndex;
    NSInteger currentTrackIndex = self.currentIndex;
    if (currentTrackIndex <= 0 && _repeat == AUMediaRepeatModeOn) {
        nextTrackIndex = self.queue.count - 1;
    } else if (currentTrackIndex > 0) {
        nextTrackIndex = currentTrackIndex - 1;
    }
    self.currentIndex = nextTrackIndex;
    NSError *error;
    //    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:nextTrackIndex];
    id<AUMediaItem> nextItem = [self.playingQueue objectAtIndex:_currentIndex];
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:nextItem error:&error finished:^{
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
        }else{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (nextTrackIndex == 0 && currentTrackIndex == 0) {
                    [strongSelf pause];
                } else {
                    [strongSelf play];
                }
            }
        }
    }];
    
    //    if (error) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : error}];
    //        return;
    //    }
    //
    //    if (nextTrackIndex == 0 && currentTrackIndex == 0) {
    //        [self pause];
    //    } else {
    //        [self play];
    //    }
}

- (void)seekToMoment:(double)moment {
    if (_player.status != AVPlayerStatusReadyToPlay) {
        return;
    }
    double secsToSeek = CMTimeGetSeconds([self playerItemDuration]) * moment;
    CMTime timeToSeek = CMTimeMakeWithSeconds(secsToSeek, NSEC_PER_SEC);
    
    __weak __typeof__(self) weakSelf = self;
    [_player seekToTime:timeToSeek completionHandler:^(BOOL finished) {
        [weakSelf updateNowPlayingInfoCenterData];
    }];
}

- (void)setShuffleOn:(BOOL)shuffle {
    if (shuffle && self.queue && self.queue.count > 1) {
        [self shuffleQueue];
    }
    _shuffle = shuffle;
}

- (void)setRepeatMode:(AUMediaRepeatMode)repeat {
    _repeat = repeat;
}

- (void)toggleRepeatMode {
    NSUInteger temp = _repeat + 1;
    _repeat = temp % 3;
}

- (void)restorePlayerStateWithItem:(id<AUMediaItem>)item queue:(NSArray *)queue playbackTime:(CMTime)time error:(NSError *__autoreleasing *)error {
    if (!item) {
        return;
    }
    __weak __typeof(&*self) weakSelf=self;  //by sck
    [self updatePlayerWithItem:item error:error finished:^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.queue = queue;
            [strongSelf.player seekToTime:time];
        }
    }];
    //    self.queue = queue;
    //    [_player seekToTime:time];
}

- (void)prepareForCurrentItemReplacementWithItem:(id<AUMediaItem>)item {
    // override
}

#pragma mark - Playback info
- (BOOL)isCanPlay
{
    NSLog(@"index:%@",@(_currentIndex));
    NSLog(@"queue:%@",self.queue);
    if (_currentIndex == -1 && [self.queue count] == 0) {
        return NO;
    }
    return YES;
}
- (id<AUMediaItem>)nowPlayingItem {
    return objc_getAssociatedObject(_player.currentItem, AVPlayerItemAssociatedItem);
}
- (id<AUMediaItem>)currentItem
{
    if (_currentIndex == -1) {
        return nil;
    }
    return [self.playingQueue objectAtIndex:_currentIndex];
}

- (AUMediaPlaybackStatus)playbackStatus {
    if ([self playerIsPlaying]) {
        return AUMediaPlaybackStatusPlaying;
    } else if (_player.status == AVPlayerStatusReadyToPlay) {
        return AUMediaPlaybackStatusPaused;
    } else {
        return AUMediaPlaybackStatusPlayerInactive;
    }
}

- (NSArray *)playingQueue {
    return _shuffle ? self.shuffledQueue : self.queue;
}

- (NSInteger)currentlyPlayedTrackIndex {
    return [self findIndexForItem:self.nowPlayingItem];
}

- (NSUInteger)queueLength {
    return self.queue.count;
}

#pragma mark - Internal player methods

- (void)updatePlayerWithItem:(id<AUMediaItem>)item
                       error:(NSError * __autoreleasing*)error
                    finished:(void(^)(void))block
{
    NSParameterAssert([item uid]);
    
    [self prepareForCurrentItemReplacementWithItem:item];
    
    NSURL *url = nil;
    if ([_library itemIsDownloaded:item]) {
        url = [NSURL fileURLWithPath:[_library localPathForItem:item]];
        NSLog(@"Playback will occur from local file with url: %@", url);
    }
    if (!url) {
        url = [NSURL URLWithString:[item remotePath]];
        NSLog(@"Playback will occur from remote stream with url: %@", url);
        NSLog(@"播放的Media是:%@",[item title]);
    }
    if (!url) {
        *error = [NSError au_itemNotAvailableToPlayError];
        return;
    }
    
    if (!_player) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
        objc_setAssociatedObject(playerItem, AVPlayerItemAssociatedItem, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if ([item itemType] == AUMediaTypeAudio) {
            _recentlyPlayedAudioItem = item;
        }
        if ([item itemType] == AUMediaTypeVideo) {
            _recentlyPlayedVideoItem = item;
        }
        
        _player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        
        [playerItem addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:AVPlayerPlaybackStatusObservationContext];
        
        [playerItem addObserver:self
                     forKeyPath:@"playbackBufferEmpty"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:AVPlayerPlaybackBufferEmptyObservationContext];
        
        [_player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerPlaybackCurrentItemObservationContext];
        
        [_player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionOld
                     context:AVPlayerPlaybackCurrentItemOldObservationContext];
        
        [_player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerPlaybackRateObservationContext];
        //执行block
        block();
    } else {
        //避免replaceCurrentItemWithNewPlayerItem阻塞住主线程，改用asset的loadValuesAsynchronouslyForKeys方法
        AVAsset *asset = [AVAsset assetWithURL:url];
        [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
                objc_setAssociatedObject(playerItem, AVPlayerItemAssociatedItem, item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                if ([item itemType] == AUMediaTypeAudio) {
                    _recentlyPlayedAudioItem = item;
                }
                if ([item itemType] == AUMediaTypeVideo) {
                    _recentlyPlayedVideoItem = item;
                }
                [self replaceCurrentItemWithNewPlayerItem:playerItem];
                //执行block
                block();
            });
        }];
        //        [self replaceCurrentItemWithNewPlayerItem:playerItem];
    }
}

- (void)initPlaybackTimeObserver {
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.playbackTimesAreValid = NO;
        return;
    }
    self.playbackTimesAreValid = YES;
    
    __weak __typeof__(self) weakSelf = self;
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                              queue:NULL /* If you pass NULL, the main queue is used. */
                                                         usingBlock:^(CMTime time)
                     {
                         [weakSelf observePlaybackTime];
                     }];
}

- (void)removePlayerTimeObserver {
    if (_timeObserver)
    {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (void)observePlaybackTime
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        [self resetPlaybackTimes];
        return;
    }
    
    _playbackTimesAreValid = YES;
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        double time = CMTimeGetSeconds([self.player currentTime]);
        if ((NSUInteger)time != _currentPlaybackTime) {
            self.currentPlaybackTime = (NSUInteger)time;
        }
        if ((NSUInteger)duration != _duration) {
            self.duration = (NSUInteger)duration;
        }
    }
}

- (CMTime)playerItemDuration {
    AVPlayerItem *playerItem = [self.player currentItem];
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}

#pragma mark - KVO observer

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == AVPlayerPlaybackCurrentItemObservationContext) {
        AVPlayerItem *newPlayerItem = [change objectForKey:NSKeyValueChangeNewKey];
        
        if (!newPlayerItem || newPlayerItem == (id)[NSNull null]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlaybackStateDidChangeNotification object:nil];
        } else {
            id<AUMediaItem> item = self.nowPlayingItem;
            if ([item itemType] == AUMediaTypeAudio) {
                _recentlyPlayedAudioItem = item;
            } else if ([item itemType] == AUMediaTypeVideo) {
                _recentlyPlayedVideoItem = item;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayedItemDidChangeNotification object:nil];
        }
        //        NSLog(@"新的item已经变更了");
        _isHasReachedEnd = NO;
        [self updateNowPlayingInfoCenterData];
        
    } else if (context == AVPlayerPlaybackCurrentItemOldObservationContext) {
        AVPlayerItem *priorItem = [change objectForKey:NSKeyValueChangeOldKey];
        
        if (priorItem && priorItem != (id)[NSNull null]) {
            [priorItem removeObserver:self forKeyPath:@"status" context:AVPlayerPlaybackStatusObservationContext];
            [priorItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:AVPlayerPlaybackBufferEmptyObservationContext];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                          object:priorItem];
        }
        _isHasReachedEnd = NO;
        //        NSLog(@"旧的item已经变更了");
        
    } else if (context == AVPlayerPlaybackRateObservationContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlaybackStateDidChangeNotification object:nil];
        
        [self updateNowPlayingInfoCenterData];
        
    } else if (context == AVPlayerPlaybackStatusObservationContext) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlaybackStateDidChangeNotification object:nil];
        
        AVPlayerItemStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 it has not tried to load new media resources for playback */
            case AVPlayerItemStatusUnknown:
            {
                [self removePlayerTimeObserver];
                [self resetPlaybackTimes];
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                
                [self initPlaybackTimeObserver];
                
                if (_shouldPlayWhenPlayerIsReady) {
                    [_player play];
                    _shouldPlayWhenPlayerIsReady = NO;
                }
            }
                break;
                
            case AVPlayerItemStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self removePlayerTimeObserver];
                [self resetPlaybackTimes];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerFailedToPlayItemNotification object:nil userInfo:@{kAUMediaPlayerFailedToPlayItemNotificationUserInfoErrorKey : playerItem.error}];
            }
                break;
        }
    } else if (context == AVPlayerPlaybackBufferEmptyObservationContext) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.isPlaybackBufferEmpty) {
            //没有buffer
            if (CMTimeGetSeconds(self.player.currentTime) <
                CMTimeGetSeconds(self.player.currentItem.duration)) {
                // Not ready to play, wait until enough data is loaded
                if (_playing) {
                    //发送通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerPlayItemIsLoadingNotification object:nil userInfo:@{kAUMediaPlayerPlayItemIsLoadingNotificationUserInfoKey : @(YES)}];
                    //暂停
                    [self pause];
                    //loading 5秒再播放
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        //发送通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlayerPlayItemIsLoadingNotification object:nil userInfo:@{kAUMediaPlayerPlayItemIsLoadingNotificationUserInfoKey : @(NO)}];
                        //播放
                        [self play];
                    });
                }
            }
        }else{
            //有buffer
            if (_playing) {
                [self play];
            }
        }
        //        if (_playing) {
        //            [self play];
        //        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    //    NSLog(@"播放快要结束了");
    if (_isHasReachedEnd) {
        //        NSLog(@"已收到播放快结束的通知");
        return;
    }
    _isHasReachedEnd = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAUMediaPlaybackDidReachEndNotification object:nil];
    if (_repeat == AUMediaRepeatModeOneSong) {
        [_player seekToTime:kCMTimeZero];
        [self play];
    } else {
        //        UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
        //        newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
        //        [self playNext];
        //        if (_bgTaskId != UIBackgroundTaskInvalid) {
        //            [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        //        }
        //        _bgTaskId = newTaskId;
        [self playNext];
    }
}

#pragma mark - Helper methods

- (void)shuffleQueue {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.queue];
    NSMutableArray *shuffledArray = [NSMutableArray array];
    while ([tempArray count] > 0) {
        NSUInteger idx = arc4random() % [tempArray count];
        [shuffledArray addObject:[tempArray objectAtIndex:idx]];
        [tempArray removeObjectAtIndex:idx];
    }
    self.shuffledQueue = shuffledArray;
}

- (BOOL)playerIsPlaying {
    if (self.player.rate > 0.0f && self.player.error == nil) {
        return YES;
    }
    return NO;
}

- (NSInteger)findIndexForItem:(id<AUMediaItem>)item {
    NSArray *queue = self.playingQueue;
    
    for (NSUInteger idx = 0; idx < queue.count; idx++) {
        id<AUMediaItem> obj = [queue objectAtIndex:idx];
        if ([obj.uid isEqualToString:[item uid]]) {
            return idx;
        }
    }
    return -1;
}

- (void)replaceCurrentItemWithNewPlayerItem:(AVPlayerItem *)playerItem {
    
    if (playerItem) {
        
        [playerItem addObserver:self
                     forKeyPath:@"playbackBufferEmpty"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:AVPlayerPlaybackBufferEmptyObservationContext];
        
        [playerItem addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                        context:AVPlayerPlaybackStatusObservationContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
    }
    
    [_player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)resetPlaybackTimes {
    self.currentPlaybackTime = 0;
    self.duration = 0;
    self.playbackTimesAreValid = NO;
}

- (void)updateNowPlayingInfoCenterData {
    NSDictionary *dictionary = @{MPMediaItemPropertyPlaybackDuration : @(CMTimeGetSeconds(_player.currentItem.duration)),
                                 MPNowPlayingInfoPropertyElapsedPlaybackTime : @(CMTimeGetSeconds(_player.currentTime))};
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    if (self.player) {
        [info setObject:@(self.player.rate) forKey:MPMediaItemPropertyRating];
    }
    
    if ([self.nowPlayingItem title]) {
        [info setObject:[self.nowPlayingItem title] forKey:MPMediaItemPropertyTitle];
    }
    
    if ([self.nowPlayingItem author]) {
        [info setObject:[self.nowPlayingItem author] forKey:MPMediaItemPropertyArtist];
    }
    
    if (self.nowPlayingCover) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.nowPlayingCover];
        if (artwork) {
            [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
        }
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}

#pragma mark - Lock screen

- (void)handleLockScreenEvent:(UIEvent *)receivedEvent {
    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;
            
        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self playPrevious];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            [self playNext];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Interruptions

- (void)handleInterruption:(NSNotification *)notification {
    if (notification.name == AVAudioSessionInterruptionNotification) {
        AVAudioSessionInterruptionType interruption = [notification.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
        
        switch (interruption) {
            case AVAudioSessionInterruptionTypeBegan:
                [self pause];
                break;
            case AVAudioSessionInterruptionTypeEnded:
                [self play];
            default:
                break;
        }
    }
}

@end

