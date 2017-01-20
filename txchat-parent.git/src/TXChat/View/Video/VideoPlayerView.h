//
//  VideoPlayerView.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/18.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VideoPlayType) {
    VideoPlayType_Normal,   //普通模式或有声模式
    VideoPlayType_Mute,     //缩略图模式或静音模式
};

typedef void(^VideoPlayStatusBlock)(BOOL isCanPlay);

@interface VideoPlayerView : UIView

@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,assign) CGFloat volume;
@property (nonatomic,assign) BOOL muted;
@property (nonatomic,copy) VideoPlayStatusBlock playStatusBlock;
/**
 *  是否观察进度，默认为NO
 */
@property (nonatomic,assign) BOOL observeProgress;
//自动删除无法播放的视频，默认为YES
@property (nonatomic,assign) BOOL autoRemoveFailedVideo;
@property (nonatomic,assign) BOOL playbackTimeAreValid;
//进度值
@property (nonatomic,readonly) double currentTime;
@property (nonatomic,readonly) double duration;
//是否自动自适应,默认是YES
@property (nonatomic,assign) BOOL isVideoAspectFill;

- (instancetype)initWithFrame:(CGRect)frame
                         type:(VideoPlayType)type;

- (void)stopPlay;

- (void)playWithURL:(NSURL *)videoURL;

#pragma mark - 视频裁剪功能的视频播放
- (void)setCropVideoPlayerWithURL:(NSURL *)videoURL;

- (void)playCropVideoWithStartTime:(double)start
                           endTime:(double)end;

- (void)resumeCropVideoPlay;

- (void)pauseCropVideoPlay;

//获取视频帧
- (void)seekVideoFrameWithTime:(double)time;

@end
