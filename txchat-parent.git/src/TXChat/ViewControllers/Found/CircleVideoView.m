//
//  CircleVideoView.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/8.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "CircleVideoView.h"
#import "DAProgressOverlayView.h"

@interface CircleVideoView()
{
    UIImageView *_playVideoView;
    UIView *_playBgView;
}
@property (nonatomic,strong) DAProgressOverlayView *progressView;

@end

@implementation CircleVideoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _downloading = NO;
        //视频半透视图
        _playBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _playBgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
        _playBgView.userInteractionEnabled = NO;
        [self addSubview:_playBgView];
        //视频播放视图
        _playVideoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _playVideoView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        _playVideoView.backgroundColor = [UIColor clearColor];
        _playVideoView.image = [UIImage imageNamed:@"chat_video_play"];
        [self addSubview:_playVideoView];
    }
    return self;
}
- (DAProgressOverlayView *)progressView
{
    if (!_progressView) {
        _progressView = [[DAProgressOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _progressView.overlayColor = [UIColor colorWithWhite:0 alpha:0.4];
        _progressView.innerRadiusRatio = 0.3;
        _progressView.outerRadiusRatio = 0.34;
        _progressView.center = _playVideoView.center;
        _progressView.userInteractionEnabled = NO;
        _progressView.progress = 0.f;
        _progressView.hidden = YES;
        [self addSubview:_progressView];
        [self bringSubviewToFront:_progressView];
    }
    return _progressView;
}
- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    _downloadProgress = downloadProgress;
    //设置视图的进度值
    self.progressView.progress = downloadProgress;
}
//开始下载视频
- (void)startDownloadVideo
{
    self.downloading = YES;
    self.progressView.hidden = NO;
    _playVideoView.hidden = YES;
    _playBgView.hidden = YES;
}
//下载视频已完成/失败
- (void)downloadVideoFinished
{
    self.downloading = NO;
    self.progressView.hidden = YES;
    self.progressView.progress = 0.f;
    _playVideoView.hidden = NO;
    _playBgView.hidden = NO;
}
@end
