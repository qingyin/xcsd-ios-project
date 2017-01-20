//
//  VideoPlayerView.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/18.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "VideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoPlayerView()
{
    AVPlayerLayer *_playerLayer;
    id _timeObserver;
    UIView *_videoPlayView;
}
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic) VideoPlayType playType;
@property (nonatomic,strong) UIImageView *muteImageView;

@property (nonatomic) double cropStartTime;
@property (nonatomic) double cropEndTime;

@property (nonatomic,readwrite) double currentTime;
@property (nonatomic,readwrite) double duration;

@end

@implementation VideoPlayerView

- (void)dealloc
{
    self.player = nil;
    _playStatusBlock = nil;
    //    DLog(@"%s",__func__);
}
- (instancetype)initWithFrame:(CGRect)frame
                         type:(VideoPlayType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        _playType = type;
        _autoRemoveFailedVideo = YES;
    }
    return self;
}
#pragma mark - 初始化视频控件
- (void)createAvPlayer
{
    if (!_videoURL) {
        DDLogDebug(@"视频初始化为空");
        return;
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    CGRect playerFrame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:_videoURL]];
    if (_playType == VideoPlayType_Mute) {
        [self muteVideoPlayer];
    }
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = playerFrame;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_playerLayer];
    [_player play];
    
    //注册检测视频加载状态的通知
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}
- (void)createMuteImagePlayer
{
    self.muteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.muteImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.muteImageView];
}
#pragma mark - 视频解码
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return image;
}
- (CGImageRef)imageRefFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    return quartzImage;
    // Release the Quartz image
    //    CGImageRelease(quartzImage);
}
- (void)decodeVideoAssetAndPlay
{
    AVAsset *m_asset = [AVAsset assetWithURL:_videoURL];
    NSError *error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:m_asset error:&error];
    if(error) {
        NSLog(@"处理失败");
        return;
    }
    NSArray* videoTracks = [m_asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
    // 视频播放时，m_pixelFormatType=kCVPixelFormatType_32BGRA
    // 其他用途，如视频压缩，m_pixelFormatType=kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:
                                                                (int)kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc]
                                                   initWithTrack:videoTrack outputSettings:options];
    [reader addOutput:videoReaderOutput];
    [reader startReading];
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        // 读取video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
        //            [m_delegate mMovieDecoder:self onNewVideoFrameReady:videoBuffer);
        @autoreleasepool {
            UIImage *image = [self imageFromSampleBuffer:videoBuffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.muteImageView.image = image;
            });
        }
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            CGImageRef imageRef = [self imageRefFromSampleBuffer:videoBuffer];
        //            self.muteImageView.layer.contents = (__bridge_transfer id)imageRef;
        ////            CFRelease(imageRef);
        //        });
        // 根据需要休眠一段时间；比如上层播放视频时每帧之间是有间隔的
        [NSThread sleepForTimeInterval:0.04];
    }
    if ([reader status] == AVAssetReaderStatusCompleted) {
        NSLog(@"播放完成，重新播放:%@",[NSThread currentThread]);
        [self decodeVideoAssetAndPlay];
    }
}
//播放静音视频
- (void)playMuteVideo
{
    
}
//停止播放
- (void)stopPlay
{
    if (!_player) {
        return;
    }
    [self.player pause];
    [self.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)playWithURL:(NSURL *)videoURL
{
    if (!videoURL) {
        DDLogDebug(@"传递的视频URL为空");
        return;
    }
    _videoURL = videoURL;
    if (!_player) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        CGRect playerFrame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
        
        _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:_videoURL]];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        _playerLayer.frame = playerFrame;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.layer addSublayer:_playerLayer];
        [_player play];
    }else{
        [self stopPlay];
        //重新播放
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_videoURL];
        [_player replaceCurrentItemWithPlayerItem:item];
        //播放
        [_player play];
    }
    //注册检测视频加载状态的通知
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}
#pragma mark - 视频裁剪功能的视频播放
- (void)setCropVideoPlayerWithURL:(NSURL *)videoURL
{
    if (!videoURL) {
        DDLogDebug(@"视频地址为空");
        return;
    }
    _videoURL = videoURL;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    CGRect playerFrame = CGRectMake(0, 0, self.layer.bounds.size.width, self.layer.bounds.size.height);
    
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:_videoURL]];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = playerFrame;
//    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer addSublayer:_playerLayer];
    
    //注册检测视频加载状态的通知
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cropVideoPlayReachedTheEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}
- (void)cropVideoPlayReachedTheEnd:(NSNotification *)notification
{
    if (notification.object != [_player currentItem]) {
        return;
    }
    [self playCropVideoWithStartTime:self.cropStartTime endTime:self.cropEndTime];
//    WEAKSELF
//    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
//        STRONGSELF
//        if (finished && strongSelf) {
//            [strongSelf.player play];
//        }
//    }];
}
- (void)playCropVideoWithStartTime:(double)start
                           endTime:(double)end
{
    self.cropStartTime = start;
    self.cropEndTime = end;
    CMTime startTime = CMTimeMakeWithSeconds(start, 1);
    CMTime endTime = CMTimeMakeWithSeconds(end, 1);
    self.player.currentItem.forwardPlaybackEndTime = endTime;
    WEAKSELF
    [self.player seekToTime:startTime completionHandler:^(BOOL finished) {
        STRONGSELF
        if (finished && strongSelf) {
            [strongSelf.player play];
        }
    }];
}
- (void)resumeCropVideoPlay
{
    [self.player play];
}
- (void)pauseCropVideoPlay
{
    [self.player pause];
}
- (void)seekVideoFrameWithTime:(double)time
{
    CMTime startTime = CMTimeMakeWithSeconds(time, 1);
    [self.player seekToTime:startTime];
}
- (void)setIsVideoAspectFill:(BOOL)isVideoAspectFill
{
    _isVideoAspectFill = isVideoAspectFill;
    if (_isVideoAspectFill) {
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }else{
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    }
}
#pragma mark - 播放进度
- (void)initVideoPlaybackTimeObserver {
    double interval = .1f;
    
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.playbackTimeAreValid = NO;
        return;
    }
    self.playbackTimeAreValid = YES;
    
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
- (void)resetPlaybackTimes {
    self.currentTime = 0;
    self.duration = 0;
    self.playbackTimeAreValid = NO;
}
- (void)observePlaybackTime
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        [self resetPlaybackTimes];
        return;
    }
    
    _playbackTimeAreValid = YES;
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        double time = CMTimeGetSeconds([self.player currentTime]);
        if (time != _currentTime) {
            self.currentTime = time;
        }
        if (duration != _duration) {
            self.duration = duration;
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
#pragma mark - 播放视频
- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    //开始播放视频
    if (_playType == VideoPlayType_Normal) {
        [self createAvPlayer];
    }else{
        [self createMuteImagePlayer];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self decodeVideoAssetAndPlay];
        });
    }
}
- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    _player.volume = _volume;
}
- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    if (_muted) {
        [self muteVideoPlayer];
    }
}
- (void)muteVideoPlayer
{
    if ([_player respondsToSelector:@selector(setVolume:)]) {
        _player.volume = 0.0;
    } else {
        AVAsset *asset = [[_player currentItem] asset];
        NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        
        // Mute all the audio tracks
        NSMutableArray *allAudioParams = [NSMutableArray array];
        for (AVAssetTrack *track in audioTracks) {
            AVMutableAudioMixInputParameters *audioInputParams =    [AVMutableAudioMixInputParameters audioMixInputParameters];
            [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
            [audioInputParams setTrackID:[track trackID]];
            [allAudioParams addObject:audioInputParams];
        }
        AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
        [audioZeroMix setInputParameters:allAudioParams];
        
        [[_player currentItem] setAudioMix:audioZeroMix];
    }
    
}
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if (notification.object != [_player currentItem]) {
        return;
    }
//    NSLog(@"结束通知:%@",notification);
    WEAKSELF
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        STRONGSELF
        if (finished && strongSelf) {
            [strongSelf.player play];
        }
    }];
}
#pragma mark - KVO监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            //视频加载完成
            if (_observeProgress) {
                [self initVideoPlaybackTimeObserver];
            }
        }else if (playerItem.status == AVPlayerStatusFailed){
            //移除进度监听
            [self removePlayerTimeObserver];
            [self resetPlaybackTimes];
            //视频加载失败
            DDLogDebug(@"视频加载失败:%@",playerItem.error);
            if (_playStatusBlock) {
                _playStatusBlock(NO);
            }
            //删除视频
            if (!_autoRemoveFailedVideo) {
                return;
            }
            NSString *filePath = [_videoURL relativePath];
            if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSError *deleteError = nil;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError];
                if (deleteError) {
                    DDLogDebug(@"删除问题视频成功");
                }else{
                    DDLogDebug(@"删除问题视频失败:%@",deleteError);
                }
            }
        }else if (playerItem.status == AVPlayerStatusUnknown) {
            //移除进度监听
            [self removePlayerTimeObserver];
            [self resetPlaybackTimes];
        }
    }
}
@end
