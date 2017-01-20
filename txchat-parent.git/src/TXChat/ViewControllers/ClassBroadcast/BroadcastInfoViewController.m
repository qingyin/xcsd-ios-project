//
//  BroadcastInfoViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/3/10.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BroadcastInfoViewController.h"
#import <TXChatCommon/AUMediaPlayer.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "TXSystemManager.h"
#import "BroadcastVideoItem.h"
#import "TXMediaSlider.h"
#import "TXClassView.h"
#import <MJRefresh.h>

static void *AUMediaPlaybackCurrentTimeObservationContext = &AUMediaPlaybackCurrentTimeObservationContext;
static void *AUMediaPlaybackDurationObservationContext = &AUMediaPlaybackDurationObservationContext;
static void *AUMediaPlaybackTimeValidityObservationContext = &AUMediaPlaybackTimeValidityObservationContext;

@interface BroadcastInfoViewController ()
<TXMediaPlayerViewDelegate>
{
    NSInteger _currentIndex;
    NSUInteger _currentTime;
    NSUInteger _currentItemDuration;
    BOOL _playbackTimesAreValid;
    BOOL _isVideoAspectMode;

}
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) BroadcastVideoAlbum *videoAlbum;
@property (nonatomic, assign) BOOL playAuthorization;

@property (nonatomic,strong) TXClassView *classView;
@property (nonatomic) NSInteger indexNum;

@end

@implementation BroadcastInfoViewController

- (void)dealloc
{
    [self removePlayerObserver];
    [[AUMediaPlayer sharedInstance] stop];
    
    [self reportEvent:XCSDPBEventTypeLessonOut bid:[NSString stringWithFormat:@"%ld", self.courseID]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.assessList = [NSMutableArray array];
    [self commonInit];
    [self setupView];
    //获取数据
    [self getDateDescrip];
    [self fetchClassBroadcastResourceList];
    [self getDateAssessWithMaxid:LONG_MAX andIsUpRefresh:NO];
    [self getDateUsersComment];
    
    [self setupRefresh];
    
    [self reportEvent:XCSDPBEventTypeLessonIn bid:[NSString stringWithFormat:@"%ld", self.courseID]];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    __weak typeof(self)tmpObject = self;
    MJTXRefreshGifHeader *gifHeader =[MJTXRefreshGifHeader createGifRefreshHeader:^{
        [tmpObject headerRereshing];
    }];
    [gifHeader updateFillerColor:kColorWhite];
    self.classView.assessmentTB.header = gifHeader;
    self.classView.assessmentTB.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [tmpObject footerRereshing];
    }];
    MJRefreshAutoStateFooter *autoStateFooter = (MJRefreshAutoStateFooter *) self.classView.assessmentTB.footer;
    [autoStateFooter setTitle:@"" forState:MJRefreshStateIdle];
}

/**
 *  下拉刷新
 */
- (void)headerRereshing{
    [self getDateAssessWithMaxid:LONG_MAX andIsUpRefresh:NO];
    [self getDateDescrip];
}

/**
 *  上拉刷新
 */
- (void)footerRereshing{
    if (self.assessList.count != 0) {
        TXPBCourseComment *comment = [self.assessList lastObject];
        [self getDateAssessWithMaxid:(NSInteger)(comment.id) andIsUpRefresh:YES];
    }
}
//初始化信息
- (void)commonInit
{
    self.view.backgroundColor = [UIColor blackColor];
    self.resourceList = [NSMutableArray array];
    //禁用滑动返回
    self.fd_interactivePopDisabled = YES;
    //禁用语音Bubble
//    self.canShowAudioBubble = NO;
    //停止宝贝乐园的后台音乐播放
    [[NSNotificationCenter defaultCenter] postNotificationName:AudioPlayShouldPauseNotification object:nil];
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    //监听观察者变化
    [self setupPlayerObserver];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
#pragma mark - UI视图创建
- (void)setupView
{
    _videoView = [[TXMediaPlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 9 / 16)];
    //设置滚动标题
    _videoView.GifLable = YES;
    [_videoView initView];
    [_videoView setTitleLabel];
    _videoView.backgroundColor = [UIColor blackColor];
    _videoView.delegate = self;
    [self.view addSubview:_videoView];
    self.classView = [[TXClassView alloc]initWithFrame:CGRectMake(0, self.videoView.maxY, kScreenWidth, kScreenHeight-self.videoView.maxY)];
    self.classView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.classView];
    [self.classView initHeaderView];
    
    //将视频播放窗口置于最前
    [self.view bringSubviewToFront:_videoView];
}
#pragma mark - 播放器相关逻辑
//创建播放器监听
- (void)setupPlayerObserver
{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    [player addObserver:self forKeyPath:@"currentPlaybackTime" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackCurrentTimeObservationContext];
    [player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackDurationObservationContext];
    [player addObserver:self forKeyPath:@"playbackTimesAreValid" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackTimeValidityObservationContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicPlayerStateChanged:)
                                                 name:kAUMediaPlaybackStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicLoadingStateChanged:) name:kAUMediaPlayerPlayItemIsLoadingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayPauseButtonTapped) name:@"onPlayer" object:nil];
}
//移除播放器监听
- (void)removePlayerObserver
{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    [player removeObserver:self forKeyPath:@"currentPlaybackTime" context:AUMediaPlaybackCurrentTimeObservationContext];
    [player removeObserver:self forKeyPath:@"duration" context:AUMediaPlaybackDurationObservationContext];
    [player removeObserver:self forKeyPath:@"playbackTimesAreValid" context:AUMediaPlaybackTimeValidityObservationContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAUMediaPlaybackStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAUMediaPlayerPlayItemIsLoadingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onPlayer" object:nil];
}
//设置播放器layer
- (void)setPlayerLayer {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.videoView.mediaView.layer;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [layer setPlayer:[AUMediaPlayer sharedInstance].player];
    _isVideoAspectMode = YES;
}
- (void)musicPlayerStateChanged:(NSNotification *)notification {
    //    NSLog(@"notification:%@",notification);
    AUMediaPlaybackStatus status = [[AUMediaPlayer sharedInstance] playbackStatus];
    [self updateNowPlayingInfo];
    [self updateButtonsForStatus:status];
}
//加载状态变化
- (void)musicLoadingStateChanged:(NSNotification *)notification
{
    BOOL isLoading = [notification.userInfo[kAUMediaPlayerPlayItemIsLoadingNotificationUserInfoKey] boolValue];
    self.videoView.playable = !isLoading;
}
- (void)updateButtonsForStatus:(AUMediaPlaybackStatus)status {
    self.videoView.playStatus = status;
}
- (void)updateNowPlayingInfo {
    //    id<AUMediaItem>item = [[self player] nowPlayingItem];
    id<AUMediaItem>item = [[AUMediaPlayer sharedInstance] currentItem];
    //刷新视图
    self.videoView.mediaItem = item;
//    [_tableView reloadData];
}
- (NSString *)stringFormattedTimeFromSeconds:(NSUInteger)seconds
{
    NSString *timeDate = [NSString stringWithFormat:@"%lu:%02d",(seconds / 60),(int)(seconds % 60)];
    return timeDate;
}
- (void)updatePlaybackProgressSliderWithTimePassed:(NSUInteger)time {
    if (self.videoView.guidV.hidden == NO) {
        self.videoView.guidV.hidden = YES;
        self.videoView.lable.hidden = YES;
    }
    if (_playbackTimesAreValid && _currentItemDuration > 0) {
        self.videoView.slider.value = (float)time/(float)_currentItemDuration;
    } else {
        self.videoView.slider.value = 0.0;
    }
}
//开始播放video
- (void)startPlayingVideo
{
    if (!self.videoView.lable.hidden) {
        self.videoView.lable.hidden = YES;
        self.videoView.guidV.hidden = YES;
    }
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    if (player.playbackStatus == AUMediaPlaybackStatusPlayerInactive) {
        NSError *error;
        if (self.videoAlbum) {
            [player playItemQueue:self.videoAlbum atIndex:self.indexNum error:&error];
        }
        [self setPlayerLayer];
        //        [self updateNowPlayingInfo];
        [self updateButtonsForStatus:AUMediaPlaybackStatusPlaying];
        self.videoView.playable = NO;
    } else if (player.playbackStatus == AUMediaPlaybackStatusPlaying) {
        //当前正在播放
        id<AUMediaItem> item = player.nowPlayingItem;
        BroadcastVideoItem *video = nil;
        if (_currentIndex < [self.resourceList count]) {
            video = self.resourceList[_currentIndex];
        }
        if (video && ![[item uid] isEqualToString:[NSString stringWithFormat:@"%@",@(video.resource.id)]]) {
            //播放新的media
            NSError *error;
            if (self.videoAlbum) {
                [player playItemQueue:self.videoAlbum atIndex:0 error:&error];
//                [player playItemQueue:self.collection error:&error];
            }
            [self setPlayerLayer];
            //            [self updateNowPlayingInfo];
            [self updateButtonsForStatus:AUMediaPlaybackStatusPlaying];
            self.videoView.playable = NO;
        }else{
            //读取播放进度
            NSUInteger playTime = player.currentPlaybackTime;
            _currentItemDuration = player.duration;
            _playbackTimesAreValid = YES;
            [self updatePlaybackProgressSliderWithTimePassed:playTime];
            [self updateNowPlayingInfo];
            [self setPlayerLayer];
            self.videoView.playable = NO;
//            [self.videoView updateNextMediaButtonState:[[TXMediaManager sharedManager] isNextResourceAvaliable]];
        }
    } else {
        BroadcastVideoItem *video = nil;
        if (_currentIndex < [self.resourceList count]) {
            video = self.resourceList[_currentIndex];
        }
        id<AUMediaItem> item = player.nowPlayingItem;
        if (video && ![[item uid] isEqualToString:[NSString stringWithFormat:@"%@",@(video.resource.id)]]) {
            //播放新的media
            NSError *error;
            if (self.videoAlbum) {
                [player playItemQueue:self.videoAlbum atIndex:self.indexNum error:&error];
//                [player playItemQueue:self.collection error:&error];
            }
            [self setPlayerLayer];
            //            [self updateNowPlayingInfo];
            [self updateButtonsForStatus:AUMediaPlaybackStatusPlaying];
            self.videoView.playable = NO;
        }else{
            [player play];
            //读取播放进度
            NSUInteger playTime = player.currentPlaybackTime;
            _currentItemDuration = player.duration;
            _playbackTimesAreValid = YES;
            [self updatePlaybackProgressSliderWithTimePassed:playTime];
            [self updateNowPlayingInfo];
            [self setPlayerLayer];
            self.videoView.playable = NO;
//            [self.videoView updateNextMediaButtonState:[[TXMediaManager sharedManager] isNextResourceAvaliable]];
        }
    }
}
#pragma mark - TXMediaPlayerViewDelegate
- (void)onMediaBackButtonTapped
{
    if (self.videoView.playType == TXMediaPlayerViewType_FullscreenLeft || self.videoView.playType == TXMediaPlayerViewType_FullscreenRight) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform transform = CGAffineTransformIdentity;
            [self.videoView setTransform:transform];
            [self.videoView setFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 9 / 16)];
            self.videoView.playType = TXMediaPlayerViewType_Normal;
        } completion:^(BOOL finished) {
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)onPlayPauseButtonTapped
{
    if (!self.videoView.lable.hidden || self.hasPase) {
        if (self.hasEdit) {
            self.hasEdit = NO;
            return;
        }
        self.videoView.lable.hidden = YES;
        self.videoView.guidV.hidden = YES;
    }
    
    if (!_playAuthorization && _videoView.playStatus != AUMediaPlaybackStatusPlaying) {
        [[TXSystemManager sharedManager] checkMediaPlayAuthorization:^(BOOL authorization) {
            if (authorization) {
                //启用播放器工具栏
                _playAuthorization = YES;
                [self.videoView enablePlayToolBar:YES];
                //允许播放
                [self startPlayingVideo];
            }else{
                //禁用播放器工具栏
                _playAuthorization = NO;
                [self.videoView enablePlayToolBar:NO];
            }
        }];
        return;
    }
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    if (player.playbackStatus == AUMediaPlaybackStatusPlayerInactive) {
        NSError *error;
        if (self.videoAlbum) {
            [player playItemQueue:self.videoAlbum error:&error];
        }
        [self setPlayerLayer];
    } else if (player.playbackStatus == AUMediaPlaybackStatusPlaying) {
        [player pause];
    } else {
        if (player.currentPlaybackTime == player.duration) {
            //从头开始播放
            [player playFromBegining];
        }else{
            //接着进度播放
            [player play];
        }
    }
}
- (void)onMediaPrevButtonTapped
{
    //    [[self player] playPrevious];
    //先停止播放
    [[AUMediaPlayer sharedInstance] stopCurrentItem];
    self.videoView.playable = NO;
}
- (void)onMediaNextButtonTapped
{
    if (_playAuthorization) {
        //先停止播放
        [[AUMediaPlayer sharedInstance] playNext];
    }else{
        [[TXSystemManager sharedManager] checkMediaPlayAuthorization:^(BOOL authorization) {
            if (authorization) {
                _playAuthorization = YES;
                [self.videoView enablePlayToolBar:YES];
                //允许播放
                [self startPlayingVideo];
            }else{
                //禁用播放器工具栏
                _playAuthorization = NO;
                [self.videoView enablePlayToolBar:NO];
            }
        }];
    }
}

- (void)onMediaZoomButtonTapped
{
    if (self.videoView.playType == TXMediaPlayerViewType_Normal) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
            [self.videoView setTransform:transform];
            [self.videoView setFrame:CGRectMake(0, 0, self.view.width_, self.view.height_)];
            
            self.videoView.playType = TXMediaPlayerViewType_FullscreenRight;
        } completion:nil];
    }else if(self.videoView.playType == TXMediaPlayerViewType_FullscreenLeft || self.videoView.playType == TXMediaPlayerViewType_FullscreenRight) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform transform = CGAffineTransformIdentity;
            [self.videoView setTransform:transform];
            [self.videoView setFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 9 / 16)];
            self.videoView.playType = TXMediaPlayerViewType_Normal;
        } completion:nil];
    }
    
}
//双击了播放器
- (void)onGestureDoubleTapHandled
{
    AVPlayerLayer *layer = (AVPlayerLayer *)self.videoView.mediaView.layer;
    if (_isVideoAspectMode) {
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }else{
        layer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    _isVideoAspectMode = !_isVideoAspectMode;
}
- (void)onMediaSliderValueChanged:(UISlider *)slider
{
    [[AUMediaPlayer sharedInstance] seekToMoment:slider.value];
}
//音频图片获取成功
- (void)fetchAudioImageSuccessed:(UIImage *)image
{
    [[AUMediaPlayer sharedInstance] setNowPlayingCover:image];
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == AUMediaPlaybackTimeValidityObservationContext) {
        BOOL playbackTimesValidaity = [change[NSKeyValueChangeNewKey] boolValue];
        _playbackTimesAreValid = playbackTimesValidaity;
        if (!playbackTimesValidaity) {
            self.videoView.currentTimeLabel.text = @"00:00";
            self.videoView.timeLabel.text = [self stringFormattedTimeFromSeconds:_currentItemDuration];
        }
    } else if (context == AUMediaPlaybackCurrentTimeObservationContext) {
        NSUInteger currentPlaybackTime = [change[NSKeyValueChangeNewKey] integerValue];
        [self updatePlaybackProgressSliderWithTimePassed:currentPlaybackTime];
        _currentTime = currentPlaybackTime;
        self.videoView.currentTimeLabel.text = [self stringFormattedTimeFromSeconds:_currentTime];
        self.videoView.timeLabel.text = [self stringFormattedTimeFromSeconds:_currentItemDuration];
        //设置当前播放课程颜色
//        NSIndexPath *path = [NSIndexPath indexPathForRow:_currentIndex inSection:0];
//        [self.classView changeTextColorFor:self.classView.contentsTB andIndexpth:path];
        
        if (_currentTime > 0) {
            self.videoView.playable = YES;
            if (_currentTime == _currentItemDuration) {
                if ([AUMediaPlayer sharedInstance].currentIndex == [self.resourceList count]-1) {
                    
                    self.videoView.lable.hidden = NO;
                    self.videoView.guidV.hidden = NO;
                }else{
                    [self.classView tableView:self.classView.contentsTB didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:[AUMediaPlayer sharedInstance].currentIndex+1 inSection:0]];
                }
            }
        }
    } else if (context == AUMediaPlaybackDurationObservationContext) {
        NSUInteger currentDuration = [change[NSKeyValueChangeNewKey] integerValue];
        _currentItemDuration = currentDuration;
        self.videoView.currentTimeLabel.text = [self stringFormattedTimeFromSeconds:_currentTime];
        self.videoView.timeLabel.text = [self stringFormattedTimeFromSeconds:_currentItemDuration];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - 视图更新
//根据资源更新video视图
- (void)updateVideoViewWithResource:(BroadcastVideoItem *)item
{
    if (item == nil) {
        NSLog(@"资源为nil");
        return;
    }
    [[TXSystemManager sharedManager] checkMediaPlayAuthorization:^(BOOL authorization) {
        if (authorization) {
            //启用播放器工具栏
            _playAuthorization = YES;
            [self.videoView enablePlayToolBar:YES];
            //允许播放
            //[self startPlayingVideo];
        }else{
            //禁用播放器工具栏
            _playAuthorization = NO;
            [self.videoView enablePlayToolBar:NO];
        }
    }];
    [self startPlayingVideo];
}
#pragma mark - 网络数据请求+数据封装
//获取课堂的直播目录列表
- (void)fetchClassBroadcastResourceList
{
    DDLogDebug(@"/fetch_course_lesson");
    [TXProgressHUD showHUDAddedTo:self.classView animated:YES];
    WEAKSELF
    [[TXChatClient sharedInstance].courseManager fetchCourseLessonId:(NSInteger)(self.course.id) onCompleted:^(NSError *error, NSArray *lessons) {
        DDLogDebug(@"%@直播目录列表",lessons);
        [TXProgressHUD hideHUDForView:weakSelf.classView animated:NO];
        if (error) {
            [weakSelf showFailedHudWithError:error];
        }else{
            STRONGSELF
            if (strongSelf) {
                //处理数据
                NSArray *formatData = [strongSelf videoDataForList:lessons];
                [strongSelf.resourceList addObjectsFromArray:formatData];
                [strongSelf updateVideoAlbumData];
                //刷新视图
                strongSelf.classView.contentsArr = strongSelf.resourceList;
                [strongSelf.classView.contentsTB reloadData];
                //判断是否播放从第一个开始播放
                for (int i = 0; i<strongSelf.resourceList.count; i++) {
                    BroadcastVideoItem *item = strongSelf.resourceList[i];
                    NSString *str = [NSString stringWithFormat:@"%ld",(long)strongSelf.courseID];
                    if ([str isEqualToString:item.uid]) {
                        strongSelf.indexNum = i;
                    }
                }
                if ([strongSelf.resourceList count] > 0) {
                    if (strongSelf.indexNum == 0) {
                        //                    [tmpObj updateVideoViewWithResource:[_resourceList firstObject]];
                        [strongSelf.classView tableView:strongSelf.classView.contentsTB didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    }else{
                        //                    [tmpObj updateVideoViewWithResource:[_resourceList objectAtIndex:tmpObj.indexNum]];
                        [strongSelf.classView tableView:strongSelf.classView.contentsTB didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:strongSelf.indexNum inSection:0]];
                        //滚动到指定位置
                        [strongSelf.classView.contentsTB scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:strongSelf.indexNum inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                    }
                }else{
                    [strongSelf updateVideoViewWithResource:nil];
                }
            }
        }
    }];
}
//获取简介列表数据
- (void)getDateDescrip
{
    DDLogDebug(@"/fetch_course");
    __weak typeof(self) tmpObj = self;
    [[TXChatClient sharedInstance].courseManager fetchCourseRequestCourseId:(NSInteger)(self.course.id) onCompleted:^(NSError *error, TXPBCourse *course) {
        DDLogDebug(@"%@简介列表数据",course);
        if (error) {
            [tmpObj showFailedHudWithError:error];
        }else{
            if (course != nil) {
                tmpObj.classView.course = course;
                [tmpObj.classView.descripTB reloadData];
                [tmpObj.classView.assessmentTB reloadData];
            }
        }
    }];
}
//获取评价列表数据
- (void)getDateAssessWithMaxid:(NSInteger)maxID andIsUpRefresh:(BOOL)isUpRefresh
{
    DDLogDebug(@"/fetch_course_comment");
    __weak typeof(self) tmpObj = self;
    [[TXChatClient sharedInstance].courseManager fetchCourseLessonId:(NSInteger)(self.course.id) andMaxId:maxID onCompleted:^(NSError *error, NSArray *comments, BOOL hasMore) {
        DDLogDebug(@"%@评价列表数据",comments);
        if (error) {
            [tmpObj showFailedHudWithError:error];
        }else{
            if (comments != nil) {
                if (isUpRefresh) {
                    [tmpObj.assessList addObjectsFromArray:comments];
                }else{
                    tmpObj.assessList = [NSMutableArray arrayWithArray:comments];
                }
                tmpObj.classView.assessmentArr = tmpObj.assessList;
            }
            [tmpObj.classView.assessmentTB reloadData];
            [tmpObj.classView.assessmentTB.footer setHidden:!hasMore];
        }
        [tmpObj.classView.assessmentTB.header endRefreshing];
        [tmpObj.classView.assessmentTB.footer endRefreshing];
    }];
}
//获取评论数据
- (void)getDateUsersComment
{
    DDLogDebug(@"/fetch_user_course_comment");
    __weak typeof(self) tmpObj = self;
    [[TXChatClient sharedInstance].courseManager fetchCourseComment:(NSInteger)(self.course.id) onCompleted:^(NSError *error, TXPBCourseComment *content) {
        DDLogDebug(@"%@获取评论数据",content);
        if (error) {
            [self showFailedHudWithError:error];
        }else{
            tmpObj.classView.starNum = content.score;
            [tmpObj.classView.assessmentTB reloadData];
        }
    }];
}
- (BroadcastVideoAlbum *)videoAlbum
{
    if (!_videoAlbum) {
        _videoAlbum = [[BroadcastVideoAlbum alloc] init];
        _videoAlbum.uid = [NSString stringWithFormat:@"%@",@(_course.id)];
        _videoAlbum.title = @"云课堂";
    }
    return _videoAlbum;
}
//更新播放数组的collection对象
- (void)updateVideoAlbumData
{
    self.videoAlbum.mediaItems = [self.resourceList copy];
}
//根据网络数据封装为播放器需要的格式
- (NSArray *)videoDataForList:(NSArray *)list
{
    if (!list || ![list count]) {
        return nil;
    }
    NSMutableArray *data = [NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(TXPBCourseLesson *res, NSUInteger idx, BOOL * _Nonnull stop) {
        BroadcastVideoItem *item = [[BroadcastVideoItem alloc] init];
        item.uid = [NSString stringWithFormat:@"%@",@(res.id)];
        item.title = res.title;
        item.remotePath = res.videoUrl;
        item.duration = res.duration;
        item.itemType = res.resourceType == 1 ? AUMediaTypeAudio : AUMediaTypeVideo;
        item.coverUrl = self.coverImgUrl;
        [data addObject:item];
    }];
    return data;
}
#pragma mark - 通知监听
- (void)onDeviceOrientationChanged:(NSNotification *)notification
{
    [self updateVideoPlayerWithCurrentDeviceOrientation];
}
#pragma mark - 屏幕旋转
- (void)updateVideoPlayerWithCurrentDeviceOrientation
{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation) {
        case UIDeviceOrientationUnknown: {
            break;
        }
        case UIDeviceOrientationPortrait: {
            if(self.videoView.playType == TXMediaPlayerViewType_FullscreenLeft || self.videoView.playType == TXMediaPlayerViewType_FullscreenRight) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                [UIView animateWithDuration:0.3f animations:^{
                    CGAffineTransform transform = CGAffineTransformIdentity;
                    [self.videoView setTransform:transform];
                    [self.videoView setFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 9 / 16)];
                    self.videoView.playType = TXMediaPlayerViewType_Normal;
                } completion:nil];
            }
            
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            if (self.videoView.playType != TXMediaPlayerViewType_FullscreenLeft) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                [UIView animateWithDuration:0.3f animations:^{
                    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
                    [self.videoView setTransform:transform];
                    [self.videoView setFrame:CGRectMake(0, 0, self.view.width_, self.view.height_)];
                    self.videoView.playType = TXMediaPlayerViewType_FullscreenLeft;
                } completion:nil];
            }
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            if (self.videoView.playType != TXMediaPlayerViewType_FullscreenRight) {
                [[UIApplication sharedApplication] setStatusBarHidden:YES];
                [UIView animateWithDuration:0.3f animations:^{
                    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2);
                    [self.videoView setTransform:transform];
                    [self.videoView setFrame:CGRectMake(0, 0, self.view.width_, self.view.height_)];
                    self.videoView.playType = TXMediaPlayerViewType_FullscreenRight;
                } completion:nil];
            }
            break;
        }
        case UIDeviceOrientationFaceUp: {
            break;
        }
        case UIDeviceOrientationFaceDown: {
            break;
        }
    }
    
}
//点击目录列表
- (void)onMediaChangeWithIndex:(NSInteger)index
{
    if (!self.videoView.lable.hidden) {
        self.videoView.lable.hidden = YES;
        self.videoView.guidV.hidden = YES;
    }
    if (_playAuthorization) {
        //先停止播放
        NSError *error;
        [[AUMediaPlayer sharedInstance] playItemQueue:self.videoAlbum atIndex:index error:&error];
    }else{
        [[TXSystemManager sharedManager] checkMediaPlayAuthorization:^(BOOL authorization) {
            if (authorization) {
                _playAuthorization = YES;
                [self.videoView enablePlayToolBar:YES];
                //允许播放
                [self startPlayingVideo];
            }else{
                //禁用播放器工具栏
                _playAuthorization = NO;
                [self.videoView enablePlayToolBar:NO];
            }
        }];
    }
}

@end
