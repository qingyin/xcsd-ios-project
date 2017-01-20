//
//  VideoCropViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/6/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "VideoCropViewController.h"
#import "VideoPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "TXRangeSlider.h"
#import "CirclePublishViewController.h"
#import "TXAVAssetExportSession.h"
#import <AVFoundation/AVFoundation.h>

static CGFloat const kVideoThumbTimeOffset = 5.0;
static NSInteger const kVideoThumbPageLessCount = 6;
static NSInteger const kVideoThumbPageMaxCount = 8;
static double const kVideoMinCropDuration = 3;
static double const kVideoMaxCropDuration = 30;

static void *TXVideoCropPlaybackCurrentTimeObservationContext = &TXVideoCropPlaybackCurrentTimeObservationContext;
static void *TXVideoCropPlaybackTimeValidityObservationContext = &TXVideoCropPlaybackTimeValidityObservationContext;
static void *TXVideoTrimProgressObservationContext = &TXVideoTrimProgressObservationContext;

@interface VideoCropViewController ()
<UIGestureRecognizerDelegate,
UIScrollViewDelegate>
{
    CGFloat _aspectRatio;
    UIView *_topLineView;
    UIScrollView *_videoThumbView;
    UIView *_lastThumbView;
    //    TXRangeSlider *_rangeSlider;
    UIImageView *_leftCutHandler;
    UIImageView *_rightCutHandler;
    UILabel *_cropTimeLabel;
    UIImageView *_progressView;
    //    UIButton *_cropButton;
    UIView *_videoPlayView;
    CAShapeLayer *_maskLayer;
    UIScrollView *_videoScrollView;
    MBProgressHUD *_trimHUD;
    
    double _startTime;
    double _endTime;
    double videoDuration;
    double _fixDuration;
    BOOL _isPlaying;
    BOOL _shouldReplay;
    BOOL _isAutoCropVideo; //默认裁剪成4:3比例
    BOOL _isDragVertical;  //是否是垂直方向拖动视频
    BOOL _isDragHorizontal; //是否是水平方向拖动视频
    
    BOOL _isLeftCutHighlighted;
    BOOL _isRightCutHightlighted;
    CGPoint _leftStart;
    CGPoint _rightStart;
    CGFloat _distanceRange;
}
@property (nonatomic,strong) AVAsset *videoAsset;
@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) VideoPlayerView *playerView;
@property (nonatomic,strong) MPMoviePlayerController *thumbVc;

@property (nonatomic,strong) TXAVAssetExportSession *exportSession;
@end

@implementation VideoCropViewController

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [self.playerView stopPlay];
    [self.playerView removeObserver:self forKeyPath:@"currentTime" context:TXVideoCropPlaybackCurrentTimeObservationContext];
    [self.playerView removeObserver:self forKeyPath:@"playbackTimeAreValid" context:TXVideoCropPlaybackTimeValidityObservationContext];
    
    [self.thumbVc cancelAllThumbnailImageRequests];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithVideoURL:(NSURL *)videoURL
{
    if (self = [super init]) {
        _videoURL = videoURL;
        _videoAsset = [AVAsset assetWithURL:_videoURL];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configure];
    [self createDarkNavigationBar];
    [self setupVideoPlayView];
    [self setupVideoThumbnailsView];
    [self setupVideoDurationAndTimeView];
}
- (void)configure
{
    _aspectRatio = 480.f / 360.f;
    CMTime duration = _videoAsset.duration;
    videoDuration = CMTimeGetSeconds(duration);
    videoDuration = (NSInteger)videoDuration;
    _startTime = 0.0;
    //    _endTime = videoDuration;
    _endTime = MIN(videoDuration, kVideoMaxCropDuration);
    _isPlaying = NO;
    _shouldReplay = YES;
    _isAutoCropVideo = YES;
    self.fd_interactivePopDisabled = YES;
    if (videoDuration <= kVideoMinCropDuration) {
        _distanceRange = self.view.width_ - 32;
    }else if (videoDuration > kVideoMinCropDuration && videoDuration <= kVideoMaxCropDuration) {
        _distanceRange = kVideoMinCropDuration / videoDuration * (self.view.width_ - 32);
    }else{
        _distanceRange = kVideoMinCropDuration / (float)kVideoMaxCropDuration * (self.view.width_ - 32);
    }
}
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}
#pragma mark - 视图创建
- (void)createDarkNavigationBar
{
    self.view.backgroundColor = RGBCOLOR(0x21, 0x21, 0x21);
    _topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationHeight + kStatusBarHeight, self.view.width_, 0.5)];
    _topLineView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_topLineView];
    //取消
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(10, kStatusBarHeight, 60, kNavigationHeight);
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [backButton setTitleColor:RGBCOLOR(0xfa, 0xfa, 0xfa) forState:UIControlStateNormal];
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    //导入
    UIButton *importButton = [UIButton buttonWithType:UIButtonTypeCustom];
    importButton.frame = CGRectMake(self.view.width_ - 70, kStatusBarHeight, 60, kNavigationHeight);
    importButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    importButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [importButton setTitleColor:RGBCOLOR(0xfa, 0xfa, 0xfa) forState:UIControlStateNormal];
    [importButton setTitle:@"完成" forState:UIControlStateNormal];
    [importButton addTarget:self action:@selector(onFinishButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:importButton];
}
//创建视图播放视图
- (void)setupVideoPlayView
{
    //读取视频比例
    AVAssetTrack *videoTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize naturalSize = [videoTrack naturalSize];
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGFloat videoAngleInDegree  = atan2(transform.b, transform.a) * 180 / M_PI;
    if (videoAngleInDegree == 90 || videoAngleInDegree == -90) {
        CGFloat width = naturalSize.width;
        naturalSize.width = naturalSize.height;
        naturalSize.height = width;
    }
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width / _aspectRatio;
    CGFloat videoWidth = 0.f;
    CGFloat videoHeight = 0.f;
    CGPoint offset = CGPointZero;
    if (naturalSize.width / 480.f > naturalSize.height / 360.f) {
        //横屏
        videoWidth = naturalSize.width / naturalSize.height * height;
        videoHeight = height;
        offset = CGPointMake((videoWidth - width) / 2.0, 0.f);
        _isDragHorizontal = YES;
    }else if (naturalSize.width / 480.f < naturalSize.height / 360.f){
        //竖屏
        videoWidth = width;
        videoHeight = naturalSize.height / naturalSize.width * width;
        offset = CGPointMake(0.f, (videoHeight - height) / 2.0);
        _isDragVertical = YES;
    }else{
        videoWidth = width;
        videoHeight = height;
        offset = CGPointZero;
    }
    //创建视图
    _videoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topLineView.maxY, width, height)];
    _videoScrollView.showsVerticalScrollIndicator = YES;
    _videoScrollView.showsHorizontalScrollIndicator = YES;
    _videoScrollView.bounces = NO;
    _videoScrollView.clipsToBounds = YES;
    [self.view addSubview:_videoScrollView];
    self.playerView = [[VideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, videoWidth, videoHeight) type:VideoPlayType_Normal];
    self.playerView.observeProgress = YES;
    WEAKSELF
    self.playerView.playStatusBlock = ^(BOOL isCanPlay) {
        if (!isCanPlay) {
            STRONGSELF
            if (strongSelf) {
                [strongSelf showFailedHudWithTitle:@"视频无法播放"];
            }
        }
    };
    [self.playerView setCropVideoPlayerWithURL:_videoURL];
    self.playerView.autoRemoveFailedVideo = NO;
    [_videoScrollView addSubview:self.playerView];
    //设置contentSize和offset
    [_videoScrollView setContentSize:CGSizeMake(videoWidth, videoHeight)];
    [_videoScrollView setContentOffset:offset];
    //添加分割线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _videoScrollView.maxY, self.view.width_, 0.5)];
    bottomLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomLine];
    //添加播放视频
    _videoPlayView = [[UIView alloc] initWithFrame:CGRectMake(0, _videoScrollView.minY, _videoScrollView.width_, _videoScrollView.height_)];
    _videoPlayView.backgroundColor = RGBACOLOR(0, 0, 0, 0.4);
    _videoPlayView.userInteractionEnabled = NO;
    [self.view addSubview:_videoPlayView];
    UIImageView *playImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    playImageView.center = CGPointMake(_videoPlayView.width_ / 2, _videoPlayView.height_ / 2);
    playImageView.image = [UIImage imageNamed:@"cropVideo_play"];
    [_videoPlayView addSubview:playImageView];
    //添加进度监听
    [self.playerView addObserver:self forKeyPath:@"currentTime" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:TXVideoCropPlaybackCurrentTimeObservationContext];
    [self.playerView addObserver:self forKeyPath:@"playbackTimeAreValid" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:TXVideoCropPlaybackTimeValidityObservationContext];
    //添加点击手势
    //    UIView *videoTapView = [[UIView alloc] initWithFrame:CGRectMake(0, _topLineView.maxY, width, height)];
    //    videoTapView.backgroundColor = [UIColor clearColor];
    //    [self.view addSubview:videoTapView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoTapGestureHandled:)];
    [_videoScrollView addGestureRecognizer:tapGesture];
}
//创建时间视图
- (void)setupVideoDurationAndTimeView
{
    //    _cropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    if ([SDVersion deviceSize] == Screen3Dot5inch) {
    //        _cropButton.frame = CGRectMake(self.view.width_ - 63, _videoThumbView.maxY + 9, 60, 40);
    //    }else{
    //        _cropButton.frame = CGRectMake(self.view.width_ - 63, _videoThumbView.maxY + 17, 60, 40);
    //    }
    //    [_cropButton setImageEdgeInsets:UIEdgeInsetsMake(9, 19, 9, 19)];
    //    [_cropButton setImage:[UIImage imageNamed:@"video_notCrop"] forState:UIControlStateNormal];
    //    [_cropButton setImage:[UIImage imageNamed:@"video_didCrop"] forState:UIControlStateSelected];
    //    [_cropButton addTarget:self action:@selector(onVideoCropButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:_cropButton];
    //    //默认选中
    //    [_cropButton setSelected:_isAutoCropVideo];
    //裁剪
    //    AVAssetTrack *videoTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    //    CGSize naturalSize = [videoTrack naturalSize];
    //    CGAffineTransform transform = videoTrack.preferredTransform;
    //    CGFloat videoAngleInDegree  = atan2(transform.b, transform.a) * 180 / M_PI;
    //    if (videoAngleInDegree == 90 || videoAngleInDegree == -90) {
    //        CGFloat width = naturalSize.width;
    //        naturalSize.width = naturalSize.height;
    //        naturalSize.height = width;
    //    }
    //    BOOL isVideoFormatStandard = NO;
    //    if (naturalSize.width > 0 && naturalSize.height > 0 && naturalSize.width / 480.f == naturalSize.height / 360.f) {
    //        isVideoFormatStandard = YES;
    //    }
    //    if (isVideoFormatStandard) {
    //        //已经是是4：3的视频
    ////        _cropButton.userInteractionEnabled = NO;
    //        //设置成不需要裁剪
    //        _isAutoCropVideo = NO;
    //    }
    //时间
    _cropTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, _videoThumbView.maxY + 32, 100, 20)];
    _cropTimeLabel.backgroundColor = [UIColor clearColor];
    _cropTimeLabel.textColor = [UIColor whiteColor];
    _cropTimeLabel.font = [UIFont systemFontOfSize:12];
    _cropTimeLabel.text = @"00:00";
    [self.view addSubview:_cropTimeLabel];
    CGSize timeSize = [_cropTimeLabel sizeThatFits:CGSizeMake(100, 20)];
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        _cropTimeLabel.frame = CGRectMake(16, _videoThumbView.maxY + 23, 100, timeSize.height);
    }else{
        _cropTimeLabel.frame = CGRectMake(16, _videoThumbView.maxY + 32, 100, timeSize.height);
    }
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 30)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:11];
    tipLabel.textColor = RGBCOLOR(0xfa, 0xf9, 0xf9);
    tipLabel.text = @"左右滑动缩略图裁剪视频,最长截取30秒";
    [self.view addSubview:tipLabel];
    CGSize tipSize = [tipLabel sizeThatFits:CGSizeMake(self.view.width_, 30)];
    tipLabel.frame = CGRectMake((self.view.width_ - tipSize.width) / 2, _cropTimeLabel.minY, tipSize.width, tipSize.height);
    //    if ([SDVersion deviceSize] == Screen3Dot5inch) {
    //        tipLabel.frame = CGRectMake((self.view.width_ - tipSize.width) / 2, _cropTimeLabel.minY, tipSize.width, tipSize.height);
    //    }else{
    //        tipLabel.frame = CGRectMake((self.view.width_ - tipSize.width) / 2, _cropTimeLabel.minY, tipSize.width, tipSize.height);
    //    }
    UIImageView *tipArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 11, 11)];
    tipArrow.center = CGPointMake(tipLabel.minX - 8, tipLabel.centerY);
    tipArrow.image = [UIImage imageNamed:@"crop_video_scrollTip"];
    [self.view addSubview:tipArrow];
    //更新时长
    [self updateVideoTimeDisplay];
}
//创建视频缩略帧视图
- (void)setupVideoThumbnailsView
{
    UILabel *dragLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _videoScrollView.maxY + 19, self.view.width_, 30)];
    dragLabel.backgroundColor = [UIColor clearColor];
    dragLabel.font = [UIFont systemFontOfSize:11];
    dragLabel.textColor = RGBCOLOR(0xfa, 0xf9, 0xf9);
    dragLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dragLabel];
    if (_isDragVertical) {
        dragLabel.text = @"上下拖动视频调整裁剪区域";
    }else if (_isDragHorizontal) {
        dragLabel.text = @"左右拖动视频调整裁剪区域";
    }else{
        dragLabel.text = @" ";
    }
    CGSize dragSize = [dragLabel sizeThatFits:CGSizeMake(self.view.width_, 30)];
    dragLabel.frame = CGRectMake(0, _videoScrollView.maxY + 19, self.view.width_, dragSize.height);
    //视频帧缩略图
    CGFloat offsetY = dragLabel.maxY + 52;
    if ([SDiPhoneVersion deviceSize] == iPhone35inch) {
        offsetY = _videoScrollView.maxY + 50;
    }
    _videoThumbView = [[UIScrollView alloc] initWithFrame:CGRectMake(16, offsetY, self.view.width_ - 32, 55)];
    _videoThumbView.showsHorizontalScrollIndicator = NO;
    _videoThumbView.bounces = NO;
    _videoThumbView.delegate = self;
    [self.view addSubview:_videoThumbView];
    
    _maskLayer = [[CAShapeLayer alloc] init];
    _maskLayer.fillColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7].CGColor;
    [_maskLayer setFillRule:kCAFillRuleEvenOdd];
    [self.view.layer addSublayer:_maskLayer];
    //设置路径
    //    CGMutablePathRef maskPath = CGPathCreateMutable();
    //    CGPathAddRect(maskPath, nil, CGRectMake(16, _videoThumbView.minY, self.view.width_ - 32, _videoThumbView.height_));
    //    [_maskLayer setPath:maskPath];
    //    CGPathRelease(maskPath);
    //创建拖动视图
    //    _rangeSlider = [[TXRangeSlider alloc] initWithFrame:CGRectMake(0, _videoThumbView.minY, self.view.width_, 55)];
    //    _rangeSlider.clipsToBounds = NO;
    //    _rangeSlider.lowerHandleImage = [UIImage imageNamed:@"crop_leftHandler"];
    //    _rangeSlider.upperHandleImage = [UIImage imageNamed:@"crop_rightHandler"];
    //    if (videoDuration <= 3) {
    //        _rangeSlider.minimumRange = 1.0;
    //    }else{
    //        CGFloat range = kVideoMinCropDuration / videoDuration;
    //        _rangeSlider.minimumRange = range;
    //    }
    //    [_rangeSlider setup];
    //    [_rangeSlider addTarget:self action:@selector(onVideoFrameSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    //    [self.view addSubview:_rangeSlider];
    _leftCutHandler = [[UIImageView alloc] initWithFrame:CGRectMake(0, offsetY, 16, 55)];
    _leftCutHandler.image = [UIImage imageNamed:@"crop_leftHandler"];
    _leftCutHandler.userInteractionEnabled = YES;
    [self.view addSubview:_leftCutHandler];
    _rightCutHandler = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.width_ - 16, offsetY, 16, 55)];
    _rightCutHandler.image = [UIImage imageNamed:@"crop_rightHandler"];
    _rightCutHandler.userInteractionEnabled = YES;
    [self.view addSubview:_rightCutHandler];
    UIPanGestureRecognizer *leftGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onLeftCutHandlerPanGestureResponsed:)];
    leftGesture.maximumNumberOfTouches = 1;
    leftGesture.delegate = self;
    [_leftCutHandler addGestureRecognizer:leftGesture];
    UIPanGestureRecognizer *rightGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onRightCutHandlerPanGestureResponsed:)];
    rightGesture.maximumNumberOfTouches = 1;
    rightGesture.delegate = self;
    [_rightCutHandler addGestureRecognizer:rightGesture];
    //进度值
    _progressView = [[UIImageView alloc] initWithFrame:CGRectMake(14, _videoThumbView.minY - 4, 4, 63)];
    _progressView.image = [UIImage imageNamed:@"crop_video_playThumb"];
    [self.view addSubview:_progressView];
    //缩略图获取器
    self.thumbVc = [[MPMoviePlayerController alloc] initWithContentURL:_videoURL];
    self.thumbVc.shouldAutoplay = NO;
    self.thumbVc.controlStyle = MPMovieControlStyleNone;
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onReceiveVideoThumbnailImageRequestDidFinishNotification:)
                                                 name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                               object:self.thumbVc];
    //获取缩略图
    NSMutableArray *thumbTimes = [[NSMutableArray alloc] init];
    if (videoDuration >= kVideoMaxCropDuration) {
        CGFloat cTime = 0.f;
        while (cTime < videoDuration) {
            [thumbTimes addObject:@(cTime)];
            cTime += kVideoThumbTimeOffset;
        }
        _fixDuration = videoDuration - cTime;
    }else{
        for (NSInteger i = 0; i < kVideoThumbPageMaxCount; i++) {
            double time = videoDuration / (kVideoThumbPageMaxCount - 1) * i;
            [thumbTimes addObject:@(time)];
        }
        _fixDuration = 0;
    }
    [self.thumbVc requestThumbnailImagesAtTimes:thumbTimes timeOption:MPMovieTimeOptionExact];
}
#pragma mark - Helper
- (void)updateVideoTimeDisplay
{
    double timeDuration = _endTime - _startTime;
    timeDuration = MIN(timeDuration, kVideoMaxCropDuration);
    timeDuration = MAX(timeDuration, kVideoMinCropDuration);
    //采用四舍五入算法
    timeDuration += 0.5;
    //更新界面
    _cropTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)timeDuration / 60,(NSInteger)timeDuration % 60];
}
//点击手势
- (void)onVideoTapGestureHandled:(UITapGestureRecognizer *)gesture
{
    if (_isPlaying) {
        _videoPlayView.hidden = NO;
        [self.playerView pauseCropVideoPlay];
    }else{
        _videoPlayView.hidden = YES;
        if (_shouldReplay) {
            [self.playerView playCropVideoWithStartTime:_startTime endTime:_endTime];
            _shouldReplay = NO;
        }else{
            [self.playerView resumeCropVideoPlay];
        }
    }
    _isPlaying = !_isPlaying;
}
- (void)updateVideoProgressCusorWithTime:(double)currentTime
{
    //    NSLog(@"播放时间是:%@",@(currentTime));
    if (!_isPlaying) {
        return;
    }
    double lowerValue = (_leftCutHandler.minX + _videoThumbView.contentOffset.x) / _videoThumbView.contentSize.width * videoDuration;
    double offset = currentTime - lowerValue;
    if (offset < 0.f) {
        offset = 0.f;
    }
    CGRect frame = _progressView.frame;
    frame.origin.x = _leftCutHandler.maxX - 2 + offset / videoDuration * _videoThumbView.contentSize.width;
    _progressView.frame = frame;
}
#pragma mark - 手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (_isLeftCutHighlighted && gestureRecognizer.view == _rightCutHandler) {
        return NO;
    }
    if (_isRightCutHightlighted && gestureRecognizer.view == _leftCutHandler) {
        return NO;
    }
    return YES;
}
- (void)onLeftCutHandlerPanGestureResponsed:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _isLeftCutHighlighted = YES;
            _leftStart = [gesture locationInView:self.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint touchPoint = [gesture locationInView:self.view];
            if (fabs(touchPoint.y - _leftStart.y) >= 55) {
                return;
            }
            CGRect frame = _leftCutHandler.frame;
            frame.origin.x += (touchPoint.x - _leftStart.x);
            if (frame.origin.x <= 0) {
                frame.origin.x = 0;
            }
            if (frame.origin.x + frame.size.width >= (_rightCutHandler.minX - _distanceRange)) {
                frame.origin.x = _rightCutHandler.minX - _distanceRange - frame.size.width;
            }
            _leftCutHandler.frame = frame;
            //更新偏移量
            _leftStart = touchPoint;
            //更新时间定位
            [self onCutHandledChanged:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            _isLeftCutHighlighted = NO;
            break;
        }
        default:
            break;
    }
}
- (void)onRightCutHandlerPanGestureResponsed:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _isRightCutHightlighted = YES;
            _rightStart = [gesture locationInView:self.view];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint touchPoint = [gesture locationInView:self.view];
            if (fabs(touchPoint.y - _rightStart.y) >= 55) {
                return;
            }
            CGRect frame = _rightCutHandler.frame;
            frame.origin.x += (touchPoint.x - _rightStart.x);
            if (frame.origin.x >= self.view.width_ - frame.size.width) {
                frame.origin.x = self.view.width_ - frame.size.width;
            }
            if (frame.origin.x <= (_leftCutHandler.maxX + _distanceRange)) {
                frame.origin.x = _leftCutHandler.maxX + _distanceRange;
            }
            _rightCutHandler.frame = frame;
            //更新偏移量
            _rightStart = touchPoint;
            //更新时间定位
            [self onCutHandledChanged:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            _isRightCutHightlighted = NO;
            break;
        }
        default:
            break;
    }
}
- (void)onCutHandledChanged:(UIPanGestureRecognizer *)gesture
{
    double lowerValue = (_leftCutHandler.minX + _videoThumbView.contentOffset.x) / _videoThumbView.contentSize.width * (videoDuration - _fixDuration);
    double upperValue = (_rightCutHandler.minX - _leftCutHandler.width_ + _videoThumbView.contentOffset.x) / _videoThumbView.contentSize.width * (videoDuration - _fixDuration);
    //    NSLog(@"视频总时间是:%@",@(videoDuration));
    //    NSLog(@"左侧值:%@",@(lowerValue));
    //    NSLog(@"右侧值:%@",@(upperValue));
    //    NSLog(@"矫正值:%@",@(_fixDuration));
    //更新时间
    _startTime = lowerValue;
    _endTime = upperValue;
    [self updateVideoTimeDisplay];
    //获取帧
    CGRect frame = _progressView.frame;
    if (gesture.view == _leftCutHandler) {
        [self.playerView seekVideoFrameWithTime:_startTime];
        frame.origin.x = _leftCutHandler.maxX - 2;
        _progressView.frame = frame;
    }else if (gesture.view == _rightCutHandler) {
        [self.playerView seekVideoFrameWithTime:_endTime];
        frame.origin.x = _rightCutHandler.minX - 2;
        _progressView.frame = frame;
    }
    //设置遮罩路径
    CGMutablePathRef maskPath = CGPathCreateMutable();
    CGPathAddRect(maskPath, nil, CGRectMake(16, _videoThumbView.minY - 0.5, self.view.width_ - 32, _videoThumbView.height_ + 0.5));
    CGPathAddRect(maskPath, nil, CGRectMake(_leftCutHandler.maxX, _videoThumbView.minY - 0.5, _rightCutHandler.minX - _leftCutHandler.maxX, _videoThumbView.height_ + 0.5));
    [_maskLayer setPath:maskPath];
    CGPathRelease(maskPath);
    //更新标识
    if (_isPlaying) {
        _videoPlayView.hidden = NO;
        [self.playerView pauseCropVideoPlay];
        _isPlaying = NO;
    }
    if (!_shouldReplay) {
        _shouldReplay = YES;
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == TXVideoCropPlaybackTimeValidityObservationContext) {
        BOOL playbackTimesValidaity = [change[NSKeyValueChangeNewKey] boolValue];
        if (!playbackTimesValidaity) {
            [self updateVideoProgressCusorWithTime:0];
        }
    }else if (context == TXVideoCropPlaybackCurrentTimeObservationContext) {
        double currentPlaybackTime = [change[NSKeyValueChangeNewKey] doubleValue];
        //        NSLog(@"当前播放时间是:%@",@(currentPlaybackTime));
        [self updateVideoProgressCusorWithTime:currentPlaybackTime];
    }else if (context == TXVideoTrimProgressObservationContext) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        //        NSLog(@"进度值:%@",@(progress));
        progress *= 100;
        NSInteger pValue = (NSInteger)progress;
        pValue = MAX(pValue, 0);
        pValue = MIN(pValue, 100);
        _trimHUD.detailsLabelText = [NSString stringWithFormat:@"%@%@",@(pValue),@"%"];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - 按钮点击响应
- (void)onBackButtonTapped:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)onFinishButtonTapped:(UIButton *)btn
{
    double timeDuration = _endTime - _startTime;
    //3秒偏差，避免frame计算时间时的浮点偏差相减后大于30秒
    if ((NSInteger)timeDuration - kVideoMaxCropDuration > 3) {
        [self showFailedHudWithTitle:[NSString stringWithFormat:@"视频长度大于%@秒，请继续裁剪",@(kVideoMaxCropDuration)]];
    }else{
        if (_isPlaying) {
            [self.playerView pauseCropVideoPlay];
            _isPlaying = NO;
        }
        //导出视频
        NSURL *path = [self pathForCropVideo];
        _trimHUD =  [MBProgressHUD showHUDAddedTo:self.view title:@"视频处理中" animated:YES];
        _trimHUD.detailsLabelText = @"0%";
        _trimHUD.detailsLabelFont = [UIFont systemFontOfSize:15];
        [self trimVideoAndExportToPath:path completion:^(NSURL *url, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新HUD进度值为100%并隐藏
                _trimHUD.detailsLabelText = @"100%";
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                _trimHUD = nil;
                if (error) {
                    [self showFailedHudWithTitle:@"导出视频失败，请重新编辑"];
                }else{
                    if (self.finishBlock) {
                        self.finishBlock(url,_videoDate);
                    }
                }
            });
        }];
    }
}
- (void)onVideoCropButtonTapped:(UIButton *)btn
{
    [btn setSelected:!btn.isSelected];
    _isAutoCropVideo = btn.isSelected;
    self.playerView.isVideoAspectFill = _isAutoCropVideo;
}
#pragma mark - UISlider变更
- (void)onVideoFrameSliderValueChanged:(TXRangeSlider *)slider
{
    CGFloat value = slider.value;
    //更新时间
    CGFloat minValue = slider.lowerValue;
    CGFloat maxValue = slider.upperValue;
    _startTime = (videoDuration * minValue);
    _endTime = (videoDuration *maxValue);
    [self updateVideoTimeDisplay];
    //获取帧
    [self.playerView seekVideoFrameWithTime:videoDuration * value];
    //更新标识
    if (_isPlaying) {
        [self.playerView pauseCropVideoPlay];
        _isPlaying = NO;
    }
    if (!_shouldReplay) {
        _shouldReplay = YES;
    }
}
#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double lowerValue = (_leftCutHandler.minX + _videoThumbView.contentOffset.x) / _videoThumbView.contentSize.width * (videoDuration - _fixDuration);
    double upperValue = (_rightCutHandler.minX - _leftCutHandler.width_ + _videoThumbView.contentOffset.x) / _videoThumbView.contentSize.width * (videoDuration - _fixDuration);
    //    NSLog(@"视频总时间是:%@",@(videoDuration));
    //    NSLog(@"左侧值:%@",@(lowerValue));
    //    NSLog(@"右侧值:%@",@(upperValue));
    //    NSLog(@"矫正值:%@",@(_fixDuration));
    //更新时间
    _startTime = lowerValue;
    _endTime = upperValue;
    [self updateVideoTimeDisplay];
    //获取帧
    CGRect frame = _progressView.frame;
    [self.playerView seekVideoFrameWithTime:_startTime];
    frame.origin.x = _leftCutHandler.maxX - 2;
    _progressView.frame = frame;
    //更新标识
    if (_isPlaying) {
        _videoPlayView.hidden = NO;
        [self.playerView pauseCropVideoPlay];
        _isPlaying = NO;
    }
    if (!_shouldReplay) {
        _shouldReplay = YES;
    }
}
#pragma mark - 通知
//缩略图获取
- (void)onReceiveVideoThumbnailImageRequestDidFinishNotification:(NSNotification *)notification
{
    //    NSLog(@"notification:%@",notification);
    id object = notification.object;
    if (object == self.thumbVc) {
        //视频总缩略帧获取
        NSDictionary *userinfo = notification.userInfo;
        UIImage *image = userinfo[MPMoviePlayerThumbnailImageKey];
        if (image) {
            CGFloat width;
            if (videoDuration >= kVideoMaxCropDuration) {
                CGFloat pageCount = kVideoThumbPageLessCount;
                width = _videoThumbView.width_ / pageCount;
            }else{
                width = _videoThumbView.width_ / kVideoThumbPageMaxCount;
            }
            UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(_lastThumbView ? _lastThumbView.maxX : 0, 0, width, _videoThumbView.height_)];
            imageview.contentMode = UIViewContentModeScaleAspectFill;
            imageview.clipsToBounds = YES;
            imageview.image = image;
            [_videoThumbView addSubview:imageview];
            _lastThumbView = imageview;
            //设置contentSize
            [_videoThumbView setContentSize:CGSizeMake(_lastThumbView.maxX, _videoThumbView.height_)];
        }
    }
}
#pragma mark - 视频处理
//剪辑视频并导出
- (void)trimVideoAndExportToPath:(NSURL *)path
                      completion:(void(^)(NSURL *url,NSError *error))completion
{
    //导出视频
    CGFloat cropWidth = 480.f;
    CGFloat cropHeight = 360.f;
    double bitsPerSecond = cropWidth * cropHeight * 4;
    NSInteger insertTime = (NSInteger)_startTime;
    NSInteger timeRange = (NSInteger)(_endTime - _startTime);
    CMTime insertionPoint = CMTimeMakeWithSeconds(insertTime, 1);
    CMTime duration = CMTimeMakeWithSeconds(timeRange, 1);
    
    //    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition
    //                                                          presetName:AVAssetExportPresetHighestQuality];
    //AVAssetExportSession不能修改bitrate导致体积太大，改用AVAssetWriter和AVAssetReader的方式导出视频
    self.exportSession = [[TXAVAssetExportSession alloc] initWithAsset:_videoAsset];
    self.exportSession.outputURL = path;
    self.exportSession.outputFileType = AVFileTypeMPEG4;    //导出为MP4文件
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    //    self.exportSession.videoComposition = videoComposition;
    self.exportSession.timeRange = CMTimeRangeMake(insertionPoint, duration);
    self.exportSession.cropRatio = CGPointMake(_videoScrollView.contentOffset.x / _videoScrollView.contentSize.width, _videoScrollView.contentOffset.y / _videoScrollView.contentSize.height);
    self.exportSession.videoSettings = @{
                                         AVVideoCodecKey: AVVideoCodecH264,
                                         //                                         AVVideoScalingModeKey : _isAutoCropVideo ? AVVideoScalingModeResizeAspectFill : AVVideoScalingModeResizeAspect,
                                         AVVideoWidthKey: @(cropWidth),
                                         AVVideoHeightKey: @(cropHeight),
                                         AVVideoCompressionPropertiesKey: @
                                             {
                                             AVVideoAverageBitRateKey: @(bitsPerSecond),
                                                 AVVideoMaxKeyFrameIntervalKey : @(30),
                                             AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline30,
                                             },
                                         };
    self.exportSession.audioSettings = @{
                                         AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                         AVNumberOfChannelsKey : @(1),
                                         AVSampleRateKey :  @(44100),
                                         AVEncoderBitRateKey : @(64000),
                                         };
    //添加进度监听
    [self.exportSession addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:TXVideoTrimProgressObservationContext];
    WEAKSELF
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        //移除进度监听
        [weakSelf.exportSession removeObserver:self forKeyPath:@"progress"];
        //导出到相册方便测试
        if (weakSelf.exportSession.status == AVAssetExportSessionStatusCompleted) {
            //            NSLog(@"视频导出成功");
            //            [weakSelf saveVideoToCameraRoll:path];
            completion(path,nil);
        }else {
            DDLogDebug(@"视频导出失败:%@",weakSelf.exportSession.error);
            completion(nil,weakSelf.exportSession.error);
        }
    }];
}
//视频合成的保存路径
- (NSURL *)pathForCropVideo
{
    //判断当前是否有用户登录
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser || !currentUser.username || ![currentUser.username length]) {
        return nil;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //添加当前登录用户
    BOOL isDir;
    NSString *userFilePath = [documentsDirectory stringByAppendingPathComponent:currentUser.username];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFilePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:userFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheVideoFolder = [userFilePath stringByAppendingPathComponent:@"recordVideo"];
    if (![fileManager fileExistsAtPath:cacheVideoFolder isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:cacheVideoFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //建立拍摄的视频缓存目录
    int x = arc4random() % 1000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *path =  [cacheVideoFolder stringByAppendingPathComponent:
                       [NSString stringWithFormat:@"crop-%d%d.mp4",(int)time,x]];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}
- (void)saveVideoToCameraRoll:(NSURL *)fileURL
{
    NSString *urlStr = [fileURL path];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, nil, nil);
        }
    });
}
@end
