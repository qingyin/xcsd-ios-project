//
//  TXMediaPlayerView.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/20.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXMediaPlayerView.h"
#import "UIImageView+EMWebCache.h"
#import <TXTranslucentView.h>
#import "TXMediaSlider.h"
#import "MarqueeLabel.h"

static CGFloat const kPlayerToolBarHeight = 34;

@interface TXMediaPlayerView()
{
    CGFloat _toolBarHeight;
    BOOL _isToolBarHidden;
    BOOL _isToolBarEnabled;
}
@property (nonatomic,strong,readwrite) TXMediaView *mediaView;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIView *topBgView;
@property (nonatomic,strong) UIView *bottomBgView;
@property (nonatomic,strong) UIButton *playPauseButton;
@property (nonatomic,strong) UIButton *nextButton;
@property (nonatomic,strong,readwrite) TXMediaSlider *slider;
@property (nonatomic,strong,readwrite) UILabel *currentTimeLabel;
@property (nonatomic,strong,readwrite) UILabel *timeLabel;
@property (nonatomic,strong) UIButton *zoomButton;
@property (nonatomic,strong) UIImageView *audioImageView;
@property (nonatomic,strong) UIView *audioMaskView;
@property (nonatomic,strong) UIImageView *audioBgImageView;
@property (nonatomic,strong) UIImageView *audioCoverImageView;
@property (nonatomic,strong) UIView *translucentToolBar;
@property (nonatomic,strong) UIView *fullscreenTopBar;
@property (nonatomic,strong) UITapGestureRecognizer *singleTapGesture;
@property (nonatomic,strong) UITapGestureRecognizer *doubleTapGesture;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UIView *audioBlurView;

@end

@implementation TXMediaPlayerView

#pragma mark - LifeCycle
- (void)dealloc
{
    [self removeGestureRecognizer:_singleTapGesture];
    [self removeGestureRecognizer:_doubleTapGesture];
    _singleTapGesture = nil;
    _doubleTapGesture = nil;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _toolBarHeight = kScreenWidth * kPlayerToolBarHeight / 320;
        _playType = TXMediaPlayerViewType_Normal;
        
    }
    return self;
}
#pragma mark - UI视图
//创建视图

- (void)initView
{
    [self setupView];
    [self setupMediaTapGesture];
    _isToolBarEnabled = YES;
    //    self.playable = YES;
}
- (void)setupView
{
    self.userInteractionEnabled = YES;
    //添加播放视图
    self.mediaView = [[TXMediaView alloc] initWithFrame:CGRectMake(0, 0, self.width_, self.height_)];
    self.mediaView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.mediaView];
    
    
    self.guidV = [[UIView alloc]init];
    self.guidV.frame = CGRectMake(0, 0, self.width_, self.height_);
    [self.mediaView addSubview:self.guidV];
    self.guidV.backgroundColor = kColorBlack;
    self.guidV.alpha = 0.5;
    self.guidV.hidden = YES;
    
    self.lable = [[UILabel alloc]init];
    self.lable.text = @"完成课程啦，评价一下吧";
    self.lable.frame = CGRectMake(self.center.x-100, self.center.y-10, 200, 20);
    [self addSubview:self.lable];
    self.lable.textColor = kColorWhite;
    self.lable.font = kFontSmall;
    self.lable.textAlignment = NSTextAlignmentCenter;
    self.lable.hidden = YES;
    //添加视图
    self.audioImageView.hidden = YES;
    self.translucentToolBar.frame = CGRectMake(0, self.height_ - _toolBarHeight, self.width_, _toolBarHeight);
    self.fullscreenTopBar.frame = CGRectMake(0, 0, self.width_, _toolBarHeight);
    self.topBgView.frame = CGRectMake(0, 0, self.width_, _toolBarHeight);
    self.bottomBgView.frame = CGRectMake(0, 0, self.width_, _toolBarHeight);
    if (self.GifLable == NO) {
        self.currentTimeLabel.frame = CGRectMake(55, 0, 55, _toolBarHeight);
    }else{
        self.currentTimeLabel.frame = CGRectMake(55-25, 0, 55, _toolBarHeight);
    }
    
    //    self.titleLabel.frame = CGRectMake(40, 0, self.width_ - 80, _toolBarHeight);
    self.backButton.frame = CGRectMake(0, 0, 40, 40);
    self.playPauseButton.frame = CGRectMake(7, -5, 25+10, _toolBarHeight+10);
    
    self.zoomButton.frame = CGRectMake(self.width_ - 35, 0, 35, _toolBarHeight);
    self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
    self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
//    self.audioBgImageView.center = CGPointMake(self.width_ / 2, self.height_ / 2);
    self.loadingView.center = CGPointMake(self.width_ / 2, self.height_ / 2);
//    self.audioBgImageView.hidden = YES;
    //    self.fullscreenTopBar.hidden = NO;
    //    self.topBgView.hidden = NO;
    //    self.titleLabel.hidden = NO;
    self.loadingView.hidden = YES;
    self.playPauseButton.hidden = YES;
    self.nextButton.hidden = YES;
    self.slider.hidden = YES;
    self.zoomButton.hidden = YES;
    self.currentTimeLabel.hidden = YES;
    self.timeLabel.hidden = YES;
}
//返回按钮
- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"btn_back_white"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
    }
    return _backButton;
}
//标题
- (void)setTitleLabel
{
    if (!_titleLabel) {
        
        if (self.GifLable) {
            _titleLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(50, 0, self.width_ - 100, _toolBarHeight) duration:8.0 andFadeLength:10.0f];
        }else{
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.frame = CGRectMake(40, 0, self.width_ - 80, _toolBarHeight);
        }
        
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = kColorWhite;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.fullscreenTopBar addSubview:_titleLabel];
        
        self.nextButton.frame = CGRectMake(self.playPauseButton.maxX + 2, 0, 25, _toolBarHeight);
    }
}
//顶部半黑条
- (UIView *)topBgView
{
    //    if (!IOS8AFTER) {
    //        return nil;
    //    }
    if (!_topBgView) {
        _topBgView = [[UIView alloc] init];
        _topBgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        [self.fullscreenTopBar addSubview:_topBgView];
    }
    return _topBgView;
}
//底部半黑条
- (UIView *)bottomBgView
{
    //    if (!IOS8AFTER) {
    //        return nil;
    //    }
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc] init];
        _bottomBgView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        [self.translucentToolBar addSubview:_bottomBgView];
    }
    return _bottomBgView;
}
//模糊工具栏
- (UIView *)translucentToolBar
{
    if (!_translucentToolBar) {
        //        if (IOS8AFTER) {
        //            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        //            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //            visualEffectView.frame = CGRectMake(0, self.mediaView.bounds.size.height - _toolBarHeight, self.mediaView.bounds.size.width, _toolBarHeight);
        //            [self.mediaView addSubview:visualEffectView];
        //            _translucentToolBar = visualEffectView;
        //        }else{
        //            TXTranslucentView *translucentView = [[TXTranslucentView alloc] initWithFrame:CGRectMake(0, self.mediaView.bounds.size.height - _toolBarHeight, self.mediaView.bounds.size.width, _toolBarHeight)];
        //            translucentView.translucentAlpha = 1;
        //            translucentView.translucentStyle = UIBarStyleBlack;
        //            translucentView.translucentTintColor = [UIColor clearColor];
        //            translucentView.backgroundColor = [UIColor clearColor];
        //            [self.mediaView addSubview:translucentView];
        //            _translucentToolBar = translucentView;
        //        }
        _translucentToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.mediaView.bounds.size.height - _toolBarHeight, self.mediaView.bounds.size.width, _toolBarHeight)];
        _translucentToolBar.backgroundColor = [UIColor clearColor];
        [self.mediaView addSubview:_translucentToolBar];
        _translucentToolBar.userInteractionEnabled = YES;
    }
    return _translucentToolBar;
}
//模糊工具栏
- (UIView *)fullscreenTopBar
{
    if (!_fullscreenTopBar) {
        //        if (IOS8AFTER) {
        //            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        //            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //            visualEffectView.frame = CGRectMake(0, self.mediaView.bounds.size.height - _toolBarHeight, self.mediaView.bounds.size.width, _toolBarHeight);
        //            [self.mediaView addSubview:visualEffectView];
        //            _fullscreenTopBar = visualEffectView;
        //        }else{
        //            TXTranslucentView *translucentView = [[TXTranslucentView alloc] initWithFrame:CGRectMake(0, self.mediaView.bounds.size.height - _toolBarHeight, self.mediaView.bounds.size.width, _toolBarHeight)];
        //            translucentView.translucentAlpha = 1;
        //            translucentView.translucentStyle = UIBarStyleBlack;
        //            translucentView.translucentTintColor = [UIColor clearColor];
        //            translucentView.backgroundColor = [UIColor clearColor];
        //            [self.mediaView addSubview:translucentView];
        //            _fullscreenTopBar = translucentView;
        //        }
        _fullscreenTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.mediaView.bounds.size.height - _toolBarHeight, self.mediaView.bounds.size.width, _toolBarHeight)];
        _fullscreenTopBar.backgroundColor = [UIColor clearColor];
        [self.mediaView addSubview:_fullscreenTopBar];
    }
    return _fullscreenTopBar;
}
//播放暂停按钮
- (UIButton *)playPauseButton
{
    if (!_playPauseButton) {
        _playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPauseButton setImage:[UIImage imageNamed:@"media_play"] forState:UIControlStateNormal];
        [_playPauseButton setImage:[UIImage imageNamed:@"media_pause"] forState:UIControlStateSelected];
        [_playPauseButton addTarget:self action:@selector(onPlayPauseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.translucentToolBar addSubview:_playPauseButton];
    }
    return _playPauseButton;
}
//下一个按钮
- (UIButton *)nextButton
{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextButton setImage:[UIImage imageNamed:@"media_next"] forState:UIControlStateNormal];
        [_nextButton setImage:[UIImage imageNamed:@"media_next_disable"] forState:UIControlStateDisabled];
        [_nextButton addTarget:self action:@selector(onNextMediaButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.GifLable == NO) {
            [self.translucentToolBar addSubview:_nextButton];
        }else{
            return nil;
        }
        
    }
    return _nextButton;
}
//进度条
- (TXMediaSlider *)slider
{
    if (!_slider) {
        _slider = [[TXMediaSlider alloc] init];
        _slider.minimumTrackTintColor = RGBCOLOR(0x41, 0xc3, 0xff);
        _slider.maximumTrackTintColor = RGBACOLOR(0xc4, 0xc4, 0xc4, 0.5);
        [_slider setThumbImage:[UIImage imageNamed:@"media_slider"] forState:UIControlStateNormal];
        [_slider addTarget:self action:@selector(onMediaProgressSliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [self.translucentToolBar addSubview:_slider];
    }
    return _slider;
}
//当前时间
- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.backgroundColor = [UIColor clearColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textColor = kColorWhite;
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.text = @"";
        [self.translucentToolBar addSubview:_currentTimeLabel];
    }
    return _currentTimeLabel;
}
//总时间
- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = kColorWhite;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"";
        [self.translucentToolBar addSubview:_timeLabel];
    }
    return _timeLabel;
}
//放大
- (UIButton *)zoomButton
{
    if (!_zoomButton) {
        _zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_zoomButton setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
        [_zoomButton addTarget:self action:@selector(onZoomButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.translucentToolBar addSubview:_zoomButton];
    }
    return _zoomButton;
}
- (UIImageView *)audioImageView
{
    if (!_audioImageView) {
        _audioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width_, self.height_)];
        _audioImageView.contentMode = UIViewContentModeScaleAspectFill;
        _audioImageView.clipsToBounds = YES;
        [self.mediaView addSubview:_audioImageView];
        //添加模糊效果
        if (IOS8AFTER) {
//            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//            visualEffectView.frame = CGRectMake(0, 0, _audioImageView.width_, _audioImageView.height_);
//            [_audioImageView addSubview:visualEffectView];
//            _audioBlurView = visualEffectView;
//            //添加mask视图
//            _audioMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _audioImageView.bounds.size.width, _audioImageView.bounds.size.height)];
//            //            _audioMaskView.backgroundColor = RGBACOLOR(47, 46, 46, 0.77);
//            _audioMaskView.backgroundColor = RGBACOLOR(0x47, 0x46, 0x46, 0.4);
//            [_audioImageView addSubview:_audioMaskView];
        }else{
            TXTranslucentView *translucentView = [[TXTranslucentView alloc] initWithFrame:CGRectMake(0, 0, _audioImageView.width_, _audioImageView.height_)];
            translucentView.translucentAlpha = 1;
            translucentView.translucentStyle = UIBarStyleBlack;
            translucentView.translucentTintColor = [UIColor clearColor];
            translucentView.backgroundColor = [UIColor clearColor];
            [_audioImageView addSubview:translucentView];
            _audioBlurView = translucentView;
        }
    }
    return _audioImageView;
}
//音频背景图片
//- (UIImageView *)audioBgImageView
//{
//    if (!_audioBgImageView) {
//        _audioBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 100)];
//        _audioBgImageView.image = [UIImage imageNamed:@"media_audioBg"];
//        [self addSubview:_audioBgImageView];
//        //添加cover视图
//        _audioCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 3, 84, 92)];
//        _audioCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
//        _audioCoverImageView.clipsToBounds = YES;
//        [_audioBgImageView addSubview:_audioCoverImageView];
//    }
//    return _audioBgImageView;
//}
//语音图片
- (UIImageView *)audioCoverImageView
{
    if (!_audioCoverImageView) {
        _audioCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 4, 83, 91)];
        _audioCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _audioCoverImageView.clipsToBounds = YES;
        [self.audioBgImageView addSubview:_audioCoverImageView];
    }
    return _audioCoverImageView;
}
//加载转圈视图
- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:_loadingView];
    }
    return _loadingView;
}
#pragma mark - Public
- (void)setPlayable:(BOOL)playable
{
    if (_playable == playable) {
        return;
    }
    _playable = playable;
    if (_playable) {
        //当前界面可以播放
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
        [self showMediaToolBar];
        self.playPauseButton.hidden = NO;
        self.nextButton.hidden = NO;
        self.slider.hidden = NO;
        self.zoomButton.hidden = NO;
        self.currentTimeLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        [self startMediaToolBarTimer];
        _isToolBarHidden = NO;
    }else{
        //暂时不可播放
        [self.loadingView startAnimating];
        self.loadingView.hidden = NO;
        self.translucentToolBar.hidden = YES;
        self.backButton.hidden = NO;
        self.fullscreenTopBar.hidden = YES;
        [self stopMediaToolBarTimer];
        _isToolBarHidden = YES;
    }
}
//更改下一曲按钮的状态
- (void)updateNextMediaButtonState:(BOOL)enabled
{
    self.nextButton.enabled = enabled;
}
//启用播放器工具栏
- (void)enablePlayToolBar:(BOOL)enabled
{
    _isToolBarEnabled = enabled;
    if (enabled) {
        [self.loadingView stopAnimating];
        self.loadingView.hidden = YES;
        [self.playPauseButton setSelected:NO];
        [self showMediaToolBar];
        [self startMediaToolBarTimer];
        _isToolBarHidden = NO;
    }else{
        self.translucentToolBar.hidden = NO;
        self.backButton.hidden = NO;
        self.fullscreenTopBar.hidden = NO;
        [self.playPauseButton setSelected:YES];
        [self stopMediaToolBarTimer];
        _isToolBarHidden = NO;
    }
}
#pragma mark - timer
//开启timer
- (void)startMediaToolBarTimer
{
    if (_timer) {
        [self stopMediaToolBarTimer];
    }
    if ([_mediaItem itemType] == AUMediaTypeAudio) {
        //屏蔽音频的timer
        return;
    }
    _timer = [NSTimer timerWithTimeInterval:3.f target:self selector:@selector(onMediaTimerHandled) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
//关闭timer
- (void)stopMediaToolBarTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
//timer响应了
- (void)onMediaTimerHandled
{
    [self hideMediaToolBar];
    _isToolBarHidden = YES;
}
#pragma mark - 手势
//设置点击手势
- (void)setupMediaTapGesture
{
    //添加双击手势
    _doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTapGestureHandled:)];
    _doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_doubleTapGesture];
    //添加单击手势
    _singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTapGestureHandled:)];
    _singleTapGesture.numberOfTapsRequired = 1;
    [_singleTapGesture requireGestureRecognizerToFail:_doubleTapGesture];
    [self addGestureRecognizer:_singleTapGesture];
}
- (void)onSingleTapGestureHandled:(UITapGestureRecognizer *)gesture
{
    if (!_playable) {
        //        DDLogDebug(@"当前还不能播放，不响应单击事件");
        return;
    }
    if (!_isToolBarEnabled) {
        return;
    }
    if ([_mediaItem itemType] == AUMediaTypeAudio) {
        //屏蔽音频的timer
        return;
    }
    if (_isToolBarHidden) {
        [self showMediaToolBar];
        [self startMediaToolBarTimer];
    }else{
        [self hideMediaToolBar];
    }
    _isToolBarHidden = !_isToolBarHidden;
}
- (void)onDoubleTapGestureHandled:(UITapGestureRecognizer *)gesture
{
    if (!_playable) {
        //        DDLogDebug(@"当前还不能播放，不响应双击事件");
        return;
    }
    if (!_isToolBarEnabled) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(onGestureDoubleTapHandled)]) {
        [_delegate onGestureDoubleTapHandled];
    }
}
//隐藏工具栏
- (void)hideMediaToolBar
{
    self.translucentToolBar.hidden = YES;
    self.backButton.hidden = YES;
    self.fullscreenTopBar.hidden = YES;
    [self stopMediaToolBarTimer];
}
//显示工具栏
- (void)showMediaToolBar
{
    self.translucentToolBar.hidden = NO;
    self.backButton.hidden = NO;
    self.fullscreenTopBar.hidden = NO;
    //    if (_playType == TXMediaPlayerViewType_Normal) {
    //        self.fullscreenTopBar.hidden = YES;
    //    }else if (_playType == TXMediaPlayerViewType_Fullscreen) {
    //        self.fullscreenTopBar.hidden = NO;
    //    }
}
#pragma mark - 按钮点击
//点击返回按钮
- (void)onBackButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onMediaBackButtonTapped)]) {
        [_delegate onMediaBackButtonTapped];
    }
}
//点击播放暂停按钮
- (void)onPlayPauseButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onPlayPauseButtonTapped)]) {
        [_delegate onPlayPauseButtonTapped];
    }
}
//点击了上一个按钮
- (void)onPrevMediaButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onMediaPrevButtonTapped)]) {
        [_delegate onMediaPrevButtonTapped];
    }
}
//点击了下一个按钮
- (void)onNextMediaButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onMediaNextButtonTapped)]) {
        [_delegate onMediaNextButtonTapped];
    }
}
//进度条改变了
- (void)onMediaProgressSliderValueChanged
{
    if (_delegate && [_delegate respondsToSelector:@selector(onMediaSliderValueChanged:)]) {
        [_delegate onMediaSliderValueChanged:_slider];
    }
}
//点击了放大按钮
- (void)onZoomButtonTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(onMediaZoomButtonTapped)]) {
        [_delegate onMediaZoomButtonTapped];
    }
}
#pragma mark - 数据处理
- (void)setPlayStatus:(AUMediaPlaybackStatus)playStatus
{
    _playStatus = playStatus;
    if (_playStatus == AUMediaPlaybackStatusPlaying) {
        [self.playPauseButton setSelected:NO];
    } else {
        [self.playPauseButton setSelected:YES];
    }
}
- (void)setPlayType:(TXMediaPlayerViewType)playType
{
    _playType = playType;
    if (_playType == TXMediaPlayerViewType_Normal) {
        //        self.fullscreenTopBar.hidden = NO;
        //        self.topBgView.hidden = NO;
        //        self.titleLabel.hidden = NO;
        //设置frame
        self.mediaView.frame = CGRectMake(0, 0, self.width_, self.height_);
        [self.zoomButton setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
        self.guidV.frame = CGRectMake(0, 0, self.width_, self.height_);
        self.lable.frame = CGRectMake(self.center.x-100, self.center.y-10, 200, 20);
        self.audioImageView.frame = CGRectMake(0, 0, self.width_, self.height_);
        self.audioBlurView.frame = CGRectMake(0, 0, self.audioImageView.width_, self.audioImageView.height_);
        self.audioMaskView.frame = CGRectMake(0, 0, self.width_, self.height_);
        self.translucentToolBar.frame = CGRectMake(0, self.height_ - _toolBarHeight, self.width_, _toolBarHeight);
        self.bottomBgView.frame = CGRectMake(0, 0, self.width_, _toolBarHeight);
        self.fullscreenTopBar.frame = CGRectMake(0, 0, self.width_, _toolBarHeight);
        self.topBgView.frame = CGRectMake(0, 0, self.width_, _toolBarHeight);
        self.titleLabel.frame = CGRectMake(40, 0, self.width_ - 80, _toolBarHeight);
        self.backButton.frame = CGRectMake(0, 0, 40, 40);
        if (self.GifLable == NO) {
            self.currentTimeLabel.frame = CGRectMake(55, 0, 55, _toolBarHeight);
        }else{
            self.currentTimeLabel.frame = CGRectMake(55-25, 0, 55, _toolBarHeight);
        }
        self.playPauseButton.frame = CGRectMake(7, -5, 25+10, _toolBarHeight+10);
        self.nextButton.frame = CGRectMake(self.playPauseButton.maxX + 2, 0, 25, _toolBarHeight);
        if (_mediaItem && [_mediaItem itemType] == AUMediaTypeAudio) {
            //音频
            self.zoomButton.frame = CGRectMake(self.width_, 0, 0, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }else{
            //其他
            self.zoomButton.frame = CGRectMake(self.width_ - 35, 0, 35, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }
        self.loadingView.center = CGPointMake(self.width_ / 2, self.height_ / 2);
        if ([_mediaItem itemType] == AUMediaTypeAudio) {
            self.audioImageView.hidden = NO;
            self.audioBgImageView.hidden = NO;
            //正常音频效果视图
            CGAffineTransform transform = CGAffineTransformIdentity;
            [self.audioBgImageView setTransform:transform];
            self.audioBgImageView.center = CGPointMake(self.width_ / 2, self.height_ / 2);
        }else{
            self.audioImageView.hidden = YES;
            self.audioBgImageView.hidden = YES;
        }
    }else if (_playType == TXMediaPlayerViewType_FullscreenLeft || _playable == TXMediaPlayerViewType_FullscreenRight) {
        //        self.fullscreenTopBar.hidden = NO;
        //        self.topBgView.hidden = NO;
        //        self.titleLabel.hidden = NO;
        //设置frame
        self.mediaView.frame = CGRectMake(0, 0, self.height_, self.width_);
        [self.zoomButton setImage:[UIImage imageNamed:@"small"] forState:UIControlStateNormal];
        self.guidV.frame = CGRectMake(0, 0, self.height_, self.width_);
        self.lable.center = self.guidV.center;
        self.audioImageView.frame = CGRectMake(0, 0, self.height_, self.width_);
        self.audioBlurView.frame = CGRectMake(0, 0, self.audioImageView.width_, self.audioImageView.height_);
        self.audioMaskView.frame = CGRectMake(0, 0, self.height_, self.width_);
        self.translucentToolBar.frame = CGRectMake(0, self.width_ - _toolBarHeight, self.height_, _toolBarHeight);
        self.bottomBgView.frame = CGRectMake(0, 0, self.height_, _toolBarHeight);
        self.fullscreenTopBar.frame = CGRectMake(0, 0, self.height_, _toolBarHeight);
        self.topBgView.frame = CGRectMake(0, 0, self.height_, _toolBarHeight);
        self.titleLabel.frame = CGRectMake(40, 0, self.height_ - 80, _toolBarHeight);
        self.backButton.frame = CGRectMake(0, 0, 40, 40);
        if (self.GifLable == NO) {
            self.currentTimeLabel.frame = CGRectMake(55, 0, 55, _toolBarHeight);
        }else{
            self.currentTimeLabel.frame = CGRectMake(55-25, 0, 55, _toolBarHeight);
        }
        
        self.playPauseButton.frame = CGRectMake(10, -5, 25+10, _toolBarHeight+10);
        self.nextButton.frame = CGRectMake(self.playPauseButton.maxX + 2, 0, 25, _toolBarHeight);
        if (_mediaItem && [_mediaItem itemType] == AUMediaTypeAudio) {
            //音频
            self.zoomButton.frame = CGRectMake(self.height_, 0, 0, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }else{
            //其他
            self.zoomButton.frame = CGRectMake(self.height_ - 35, 0, 35, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }
        self.loadingView.center = CGPointMake(self.height_ / 2, self.width_ / 2);
        if ([_mediaItem itemType] == AUMediaTypeAudio) {
            self.audioImageView.hidden = NO;
            self.audioBgImageView.hidden = NO;
            //放大音频效果视图
            CGAffineTransform transform = CGAffineTransformMakeScale(1.5, 1.5);
            [self.audioBgImageView setTransform:transform];
            self.audioBgImageView.center = CGPointMake(self.height_ / 2, self.width_ / 2);
        }else{
            self.audioImageView.hidden = YES;
            self.audioBgImageView.hidden = YES;
        }
    }
}
- (void)setMediaItem:(id<AUMediaItem>)mediaItem
{
    _mediaItem = mediaItem;
    if ([_mediaItem itemType] == AUMediaTypeAudio) {
        //语音
        self.audioImageView.hidden = NO;
        self.audioImageView.image = nil;
        WEAKSELF
        [self.audioImageView TX_setImageWithURL:[NSURL URLWithString:[mediaItem coverUrl]] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
            STRONGSELF
            if (strongSelf && image) {
                strongSelf.audioImageView.image = image;
                if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(fetchAudioImageSuccessed:)]) {
                    [strongSelf.delegate fetchAudioImageSuccessed:image];
                }
            }
        }];
        self.audioBgImageView.hidden = YES;
        _audioCoverImageView.image = nil;
//        [_audioCoverImageView TX_setImageWithURL:[NSURL URLWithString:[mediaItem coverUrl]] placeholderImage:nil];
        //界面排版
        if (_playType == TXMediaPlayerViewType_Normal) {
            self.zoomButton.frame = CGRectMake(self.width_, 0, 0, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }else if (_playType == TXMediaPlayerViewType_FullscreenLeft || _playType == TXMediaPlayerViewType_FullscreenRight) {
            self.zoomButton.frame = CGRectMake(self.height_, 0, 0, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }
    }else if ([_mediaItem itemType] == AUMediaTypeVideo) {
        //视频
        self.audioBgImageView.hidden = YES;
        self.audioImageView.hidden = YES;
        //界面排版
        if (_playType == TXMediaPlayerViewType_Normal) {
            self.zoomButton.frame = CGRectMake(self.width_ - 35, 0, 35, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }else if (_playType == TXMediaPlayerViewType_FullscreenLeft || _playType == TXMediaPlayerViewType_FullscreenRight) {
            self.zoomButton.frame = CGRectMake(self.height_ - 35, 0, 35, _toolBarHeight);
            self.timeLabel.frame = CGRectMake(self.zoomButton.minX - 55, 0, 55, _toolBarHeight);
            self.slider.frame = CGRectMake(self.currentTimeLabel.maxX, 0, self.timeLabel.minX - self.currentTimeLabel.maxX, _toolBarHeight);
        }
    }
    _titleLabel.text = [_mediaItem title];
}
@end
