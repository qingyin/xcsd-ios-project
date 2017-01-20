//
//  MediaPlayViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/19.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "MediaPlayViewController.h"
#import "TXVideoPreviewViewController.h"
#import <TXChatCommon/AUMediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TXMediaPlayerView.h"
#import <TXChatSDK/TXTrackManager.h>
#import <TXChatSDK/TXAlbum.h>
#import <TXChatSDK/TXTrack.h>

static void *AUMediaPlaybackCurrentTimeObservationContext = &AUMediaPlaybackCurrentTimeObservationContext;
static void *AUMediaPlaybackDurationObservationContext = &AUMediaPlaybackDurationObservationContext;
static void *AUMediaPlaybackTimeValidityObservationContext = &AUMediaPlaybackTimeValidityObservationContext;

@interface MediaPlayViewController ()
<TXMediaPlayerViewDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    NSUInteger _currentTime;
    NSUInteger _currentItemDuration;
    BOOL _playbackTimesAreValid;
    UILabel *_countLabel;
}

@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) UIButton *repeatButton;
@property (nonatomic, strong) UIButton *shuffleButton;

@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) TXMediaPlayerView *playbackView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MediaPlayViewController

- (void)dealloc
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    [[AUMediaPlayer sharedInstance] stop];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self setupView];
    [self fetchMediaAlbumList];
}
#pragma mark - 视图UI创建
- (void)setupView
{
    //播放视图
    self.playbackView = [[TXMediaPlayerView alloc] initWithFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 14 / 25)];
    self.playbackView.backgroundColor = [UIColor blackColor];
    self.playbackView.delegate = self;
    [self.view addSubview:self.playbackView];
    //添加详情视图
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.playbackView.maxY, self.view.width_, self.view.height_ - self.playbackView.maxY)];
    self.contentView.backgroundColor = kColorBackground;
    [self.view addSubview:self.contentView];
    //添加列表视图
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width_, self.contentView.height_) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.contentView addSubview:_tableView];
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.font = kFontMiddle;
    _countLabel.textColor = kColorBlack;
    _tableView.tableHeaderView = _countLabel;
    //添加到最顶部
    [self.view bringSubviewToFront:self.playbackView];
}
#pragma mark - 按钮点击响应方法
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self musicPlayerStateChanged:nil];
    [self updateShuffleAndRepeatButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AUMediaPlayer *player = [self player];
    [player addObserver:self forKeyPath:@"currentPlaybackTime" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackCurrentTimeObservationContext];
    [player addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackDurationObservationContext];
    [player addObserver:self forKeyPath:@"playbackTimesAreValid" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:AUMediaPlaybackTimeValidityObservationContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(musicPlayerStateChanged:)
                                                 name:kAUMediaPlaybackStateDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    [player removeObserver:self forKeyPath:@"currentPlaybackTime" context:AUMediaPlaybackCurrentTimeObservationContext];
    [player removeObserver:self forKeyPath:@"duration" context:AUMediaPlaybackDurationObservationContext];
    [player removeObserver:self forKeyPath:@"playbackTimesAreValid" context:AUMediaPlaybackTimeValidityObservationContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAUMediaPlaybackStateDidChangeNotification
                                                  object:nil];
}

- (void)setPlayerLayer {
    AVPlayerLayer *layer = (AVPlayerLayer *)self.playbackView.mediaView.layer;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer setPlayer:[self player].player];
}

- (IBAction)repeatAction:(id)sender {
    AUMediaPlayer *player = [self player];
    if (player.repeat) {
        [[self player] toggleRepeatMode];
    } else {
        [[self player] toggleRepeatMode];
    }
    
    [self updateShuffleAndRepeatButtons];
}
- (IBAction)shuffleAction:(id)sender {
    AUMediaPlayer *player = [self player];
    if (player.shuffle) {
        [player setShuffleOn:NO];
    } else {
        [player setShuffleOn:YES];
    }
    
    [self updateShuffleAndRepeatButtons];
}

- (NSString *)stringFormattedTimeFromSeconds:(NSUInteger)seconds
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:@"mm:ss"];
    NSString *timeDate = [formatter stringFromDate:date];
    return timeDate;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == AUMediaPlaybackTimeValidityObservationContext) {
        BOOL playbackTimesValidaity = [change[NSKeyValueChangeNewKey] boolValue];
        _playbackTimesAreValid = playbackTimesValidaity;
        if (!playbackTimesValidaity) {
//            self.leftTimeLabel.text = @"invalid";
//            self.rightTimeLabel.text = @"invalid";
//            self.playbackView.timeLabel.text = @"00:00/00:00";
            self.playbackView.timeLabel.text = [NSString stringWithFormat:@"00:00/%@",[self stringFormattedTimeFromSeconds:_currentItemDuration]];
        }
    } else if (context == AUMediaPlaybackCurrentTimeObservationContext) {
        NSUInteger currentPlaybackTime = [change[NSKeyValueChangeNewKey] integerValue];
        [self updatePlaybackProgressSliderWithTimePassed:currentPlaybackTime];
        _currentTime = currentPlaybackTime;
        self.playbackView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self stringFormattedTimeFromSeconds:_currentTime],[self stringFormattedTimeFromSeconds:_currentItemDuration]];
    } else if (context == AUMediaPlaybackDurationObservationContext) {
        NSUInteger currentDuration = [change[NSKeyValueChangeNewKey] integerValue];
        _currentItemDuration = currentDuration;
        self.playbackView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self stringFormattedTimeFromSeconds:_currentTime],[self stringFormattedTimeFromSeconds:_currentItemDuration]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (AUMediaPlayer *)player {
    return [AUMediaPlayer sharedInstance];
}

- (void)updatePlaybackProgressSliderWithTimePassed:(NSUInteger)time {
    if (_playbackTimesAreValid && _currentItemDuration > 0) {
//        self.playbackView.slider.value = (float)time/(float)_currentItemDuration;
    } else {
//        self.playbackView.slider.value = 0.0;
    }
}

- (void)musicPlayerStateChanged:(NSNotification *)notification {
    [self updateNowPlayingInfo];
    [self updateButtonsForStatus:[[AUMediaPlayer sharedInstance] playbackStatus]];
}

- (void)updateButtonsForStatus:(AUMediaPlaybackStatus)status {
    self.playbackView.playStatus = status;
}

- (void)updateNowPlayingInfo {
    id<AUMediaItem>item = [[self player] nowPlayingItem];
    self.authorLabel.text = [item author];
    self.titleLabel.text = [item title];
    //刷新视图
    self.playbackView.mediaItem = item;
    [_tableView reloadData];
}

- (void)updateShuffleAndRepeatButtons {
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    if (player.shuffle) {
        [self.shuffleButton setTitle:@"Shuffle on" forState:UIControlStateNormal];
        NSLog(@"Shuffle on");
    } else {
        [self.shuffleButton setTitle:@"Shuffle off" forState:UIControlStateNormal];
        NSLog(@"Shuffle off");
    }
    switch (player.repeat) {
        case AUMediaRepeatModeOn:
            [self.repeatButton setTitle:@"Repeat on" forState:UIControlStateNormal];
            break;
        case AUMediaRepeatModeOff:
            [self.repeatButton setTitle:@"Repeat off" forState:UIControlStateNormal];
            break;
        case AUMediaRepeatModeOneSong:
            [self.repeatButton setTitle:@"Repeat one" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
#pragma mark - TXMediaPlayerViewDelegate
- (void)onMediaBackButtonTapped
{
    if (self.playbackView.playType == TXMediaPlayerViewType_Normal) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform transform = CGAffineTransformIdentity;
            [self.playbackView setTransform:transform];
            [self.playbackView setFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 14 / 25)];
            self.playbackView.playType = TXMediaPlayerViewType_Normal;
        } completion:^(BOOL finished) {
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)onPlayPauseButtonTapped
{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    if (player.playbackStatus == AUMediaPlaybackStatusPlayerInactive || (self.item && ![[player.nowPlayingItem uid] isEqualToString:self.item.uid])) {
        NSError *error;
        if (self.collection) {
            [player playItemQueue:self.collection error:&error];
        } else {
            [player playItem: self.item error:&error];
        }
        [self setPlayerLayer];
    } else if (player.playbackStatus == AUMediaPlaybackStatusPlaying) {
        [player pause];
    } else {
        [player play];
    }
    NSLog(@"Current time: %lu, Duration: %lu", (unsigned long)player.currentPlaybackTime, (unsigned long)player.duration);
}
- (void)onMediaPrevButtonTapped
{
    [[self player] playPrevious];

}
- (void)onMediaNextButtonTapped
{
    [[self player] playNext];

}
- (void)onMediaZoomButtonTapped
{
    if (self.playbackView.playType == TXMediaPlayerViewType_Normal) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
            [self.playbackView setTransform:transform];
            [self.playbackView setFrame:CGRectMake(0, 0, self.view.width_, self.view.height_)];
            self.playbackView.playType = TXMediaPlayerViewType_Normal;
        } completion:nil];
    }else if(self.playbackView.playType == TXMediaPlayerViewType_Normal) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:0.3f animations:^{
            CGAffineTransform transform = CGAffineTransformIdentity;
            [self.playbackView setTransform:transform];
            [self.playbackView setFrame:CGRectMake(0, 20, self.view.width_, self.view.width_ * 14 / 25)];
            self.playbackView.playType = TXMediaPlayerViewType_Normal;
        } completion:nil];
    }
    
}
- (void)onMediaSliderValueChanged:(UISlider *)slider
{
    [[self player] seekToMoment:slider.value];
}
#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_collection.mediaItems count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"cellIndentify";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
    }
    NSArray *array = _collection.mediaItems;
    if (indexPath.row < [array count]) {
        id<AUMediaItem> item = array[indexPath.row];
        cell.textLabel.text = [item title];
        //设置是否播放
        AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
        id<AUMediaItem> playItem = player.nowPlayingItem;
        if ([[playItem uid] isEqualToString:[item uid]]) {
            //播放同一个
            cell.textLabel.textColor = [UIColor redColor];
        }else{
            cell.textLabel.textColor = kColorBlack;
        }
    }
    return cell;
}
#pragma mark - UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //播放当前文件
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    id<AUMediaItem> item = _collection.mediaItems[indexPath.row];
    BOOL isCanPlay = [player tryPlayingItemFromCurrentQueue:item];
    if (!isCanPlay) {
        //尝试播放下一个
        [self tryPlayNextItemFrom:indexPath.row];
    }
}
#pragma mark - 网络请求
- (void)fetchMediaAlbumList
{
    NSArray *arr = [[TXChatClient sharedInstance].trackManager queryTracksByAlbumId:[_collection.uid longLongValue] maxTrackId:LLONG_MAX count:20];
    NSMutableArray *list = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(TXTrack *obj, NSUInteger idx, BOOL *stop) {
        if (obj.trackType == TXTrackTypeAudio) {
            TXMediaAudioItem *audio = [[TXMediaAudioItem alloc] init];
//            audio3.author = @"Author";
            audio.title = obj.name;
            audio.uid = [NSString stringWithFormat:@"%@",@(obj.id)];
            audio.remotePath = obj.url;
            audio.ablumId = _collection.uid;
            audio.author = _collection.author;
            [list addObject:audio];
        }else if(obj.trackType == TXTrackTypeVideo){
            TXMediaVideoItem *video = [[TXMediaVideoItem alloc] init];
//            video.author = @"Video author";
            video.title = obj.name;
            video.uid = [NSString stringWithFormat:@"%@",@(obj.id)];
            video.remotePath = obj.url;
            video.ablumId = _collection.uid;
            video.author = _collection.author;
            [list addObject:video];
        }
    }];
    _collection.mediaItems = list;
    [_tableView reloadData];
    //开始播放
    _countLabel.text = [NSString stringWithFormat:@"    共%@个节目",@([_collection.mediaItems count])];
    [self resetCurrentMediaPlayer];
    [self startPlayingMedia];
}
#pragma mark - 播放控制
//开始播放
- (void)startPlayingMedia
{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    if (player.playbackStatus == AUMediaPlaybackStatusPlayerInactive || (self.item && ![[player.nowPlayingItem uid] isEqualToString:self.item.uid])) {
        NSError *error;
        if (self.collection) {
            [player playItemQueue:self.collection error:&error];
        } else {
            [player playItem: self.item error:&error];
        }
        [self setPlayerLayer];
        [self updateButtonsForStatus:AUMediaPlaybackStatusPlaying];
    } else if (player.playbackStatus == AUMediaPlaybackStatusPlaying) {
        //当前正在播放
        id<AUMediaItem> item = player.nowPlayingItem;
        if (![[item ablumId] isEqualToString:_collection.uid]) {
            //播放新的media
            NSError *error;
            if (self.collection) {
                [player playItemQueue:self.collection error:&error];
            } else {
                [player playItem: self.item error:&error];
            }
            [self setPlayerLayer];
            [self updateButtonsForStatus:AUMediaPlaybackStatusPlaying];
        }else{
            //读取播放进度
            NSUInteger playTime = player.currentPlaybackTime;
            _currentItemDuration = player.duration;
            _playbackTimesAreValid = YES;
            [self updatePlaybackProgressSliderWithTimePassed:playTime];
            [self setPlayerLayer];
        }
    } else {
        id<AUMediaItem> item = player.nowPlayingItem;
        if (![[item ablumId] isEqualToString:_collection.uid]) {
            //播放新的media
            NSError *error;
            if (self.collection) {
                [player playItemQueue:self.collection error:&error];
            } else {
                [player playItem: self.item error:&error];
            }
            [self setPlayerLayer];
            [self updateButtonsForStatus:AUMediaPlaybackStatusPlaying];
        }else{
            [player play];
            //读取播放进度
            NSUInteger playTime = player.currentPlaybackTime;
            _currentItemDuration = player.duration;
            _playbackTimesAreValid = YES;
            [self updatePlaybackProgressSliderWithTimePassed:playTime];
            [self setPlayerLayer];
        }
    }
}
//重置当前播放的player
- (void)resetCurrentMediaPlayer
{
    AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
    id<AUMediaItem> item = player.nowPlayingItem;
    if ([[item ablumId] isEqualToString:_collection.uid]) {
        //同一个专辑
        NSLog(@"播放的是同一个专辑");
    }else{
        [player stop];
    }
}
//尝试播放下一个
- (void)tryPlayNextItemFrom:(NSInteger)index
{
    if (index + 1 < [_collection.mediaItems count]) {
        AUMediaPlayer *player = [AUMediaPlayer sharedInstance];
        id<AUMediaItem> item = _collection.mediaItems[index + 1];
        BOOL isCanPlay = [player tryPlayingItemFromCurrentQueue:item];
        if (!isCanPlay) {
            [self tryPlayNextItemFrom:index + 1];
        }
    }
}
@end
