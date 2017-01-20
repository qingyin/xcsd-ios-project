//
//  TXVideoPreviewViewController.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/22.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXVideoPreviewViewController.h"
#import "VideoPlayerView.h"
#import "TXVideoCacheManager.h"
#import "DAProgressOverlayView.h"
#import "UIImageView+EMWebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface TXVideoPreviewViewController ()
<UIActionSheetDelegate>
{
    UIImageView *_thumbImageView;
    DAProgressOverlayView *_progressView;
    UIButton *_backBtn;
    UILongPressGestureRecognizer *_longPressGesture;
}
@property (nonatomic,strong) VideoPlayerView *playerView;
@property (nonatomic,strong) NSString *videoURLString;
//视频宽高比，默认是640/480
@property (nonatomic,assign) CGFloat aspectRatio;
@property (nonatomic,strong) AFDownloadRequestOperation *downloadOperation;
@property (nonatomic,strong) NSURL *localFileURL;
@end

@implementation TXVideoPreviewViewController

- (void)dealloc
{
    [[TXVideoCacheManager sharedManager] cancelDownloadVideoWithOperation:_downloadOperation];
    [_playerView stopPlay];
    DLog(@"%s",__func__);
}

- (instancetype)initWithVideoURLString:(NSString *)urlString
{
    self = [super init];
    if (self) {
        _videoURLString = urlString;
        _aspectRatio = 640.f / 480.f;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self setupVideoPlayerView];
    [self setupBackControlView];
    [self setupLongPressGesture];
    if (_mustCachedFirst) {
        [self cacheVideoAndPlay];
    }else{
        if (_isRemoteVideo) {
            NSURL *url = [NSURL URLWithString:_videoURLString];
            [self playVideoWithURLString:url];
        }else{
            NSURL *url = [NSURL fileURLWithPath:_videoURLString];
            [self playVideoWithURLString:url];
        }
    }
}
//开始缓存视频并准备播放
- (void)cacheVideoAndPlay
{
    NSString *videoCachePath = [[TXVideoCacheManager sharedManager] videoCachePathForURL:_videoURLString];
    if (videoCachePath) {
        //        [self setupVideoPlayerView];
        NSURL *url = [NSURL fileURLWithPath:videoCachePath];
        DDLogDebug(@"视频url是:%@ 网络url是:%@",url,_videoURLString);
        [self playVideoWithURLString:url];
    }else{
        //添加缩略图和进度视图
        [self setupVideoThumbAndProgressView];
        WEAKSELF
        self.downloadOperation = [[TXVideoCacheManager sharedManager] downloadVideoWithURL:_videoURLString progress:^(CGFloat progress) {
            //            NSLog(@"下载进度:%@",@(progress));
            STRONGSELF
            if (strongSelf) {
                strongSelf->_progressView.progress = progress;
            }
        } onCompleted:^(NSString *localFileURLString, NSError *error) {
            STRONGSELF
            if (error) {
                DDLogDebug(@"下载视频出错:%@",error);
                if (strongSelf) {
                    [strongSelf showFailedHudWithTitle:@"下载视频失败，请稍后再试!"];
                }
            }else{
                if (strongSelf) {
                    if (localFileURLString && [localFileURLString length]) {
                        strongSelf->_thumbImageView.hidden = YES;
                        strongSelf->_progressView.hidden = YES;
                        //                        [strongSelf setupVideoPlayerView];
                        NSURL *url = [NSURL fileURLWithPath:localFileURLString];
                        DDLogDebug(@"下载完的视频url是:%@ 网络url是:%@",url,strongSelf.videoURLString);
                        [strongSelf playVideoWithURLString:url];
                    }else{
                        DDLogDebug(@"下载完的视频路径为空:%@",localFileURLString);
                        [strongSelf showFailedHudWithTitle:@"下载视频失败，请稍后再试!"];
                    }
                }
            }
            
        }];
    }
}
//创建下载时的进度视图
- (void)setupVideoThumbAndProgressView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width / _aspectRatio;
    _thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _thumbImageView.center = self.view.center;
//    __weak typeof(_thumbImageView) weakThumb = _thumbImageView;
    // by mey
    __weak __typeof(&*_thumbImageView) weakThumb=_thumbImageView;
    [_thumbImageView TX_setImageWithURL:[NSURL URLWithString:_thumbImageURLString] placeholderImage:nil completed:^(UIImage *image, NSError *error, EMSDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            [weakThumb setImage:[UIImage imageNamed:@"tp_320x240"]];
        }
    }];
    [self.view addSubview:_thumbImageView];
    _progressView = [[DAProgressOverlayView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _progressView.overlayColor = [UIColor colorWithWhite:0 alpha:0.6];
    _progressView.innerRadiusRatio = 0.3;
    _progressView.outerRadiusRatio = 0.34;
    _progressView.center = self.view.center;
    _progressView.userInteractionEnabled = NO;
    _progressView.progress = 0.f;
    [self.view addSubview:_progressView];
    [self.view bringSubviewToFront:_progressView];
    //将取消按钮放置最前
    [self.view bringSubviewToFront:_backBtn];
}
//创建视频播放组件
- (void)setupVideoPlayerView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width / _aspectRatio;
    self.playerView = [[VideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, width, height) type:VideoPlayType_Normal];
    self.playerView.center = self.view.center;
    WEAKSELF
    self.playerView.playStatusBlock = ^(BOOL isCanPlay) {
        if (!isCanPlay) {
            STRONGSELF
            if (strongSelf) {
                [strongSelf showFailedHudWithTitle:@"视频无法播放"];
            }
        }
    };
    [self.view addSubview:self.playerView];
    
}
- (void)setupBackControlView
{
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = self.view.bounds;
    _backBtn.backgroundColor = [UIColor clearColor];
    [_backBtn addTarget:self action:@selector(stopVideoPreview) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    [self.view bringSubviewToFront:_backBtn];
}
- (void)setupLongPressGesture
{
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoLongPressGestureHandled:)];
    //    gesture.minimumPressDuration = 1.f;
    _longPressGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:_longPressGesture];
}
//播放视频
- (void)playVideoWithURLString:(NSURL *)url
{
    if (url) {
        self.localFileURL = url;
        self.playerView.videoURL = url;
    }
}
- (void)stopVideoPreview
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 长按手势
- (void)onVideoLongPressGestureHandled:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        BOOL isCanOpenInSafari = NO;
        if (_mustCachedFirst || _isRemoteVideo) {
            isCanOpenInSafari = YES;
        }
        NSMutableArray *items = [NSMutableArray arrayWithObject:@"保存到手机"];
        if (isCanOpenInSafari) {
            [items addObject:@"用浏览器打开"];
        }
        [self showNormalSheetWithTitle:nil items:items clickHandler:^(NSInteger index) {
            if (index == 0) {
                //保存到手机
                [self saveVideoFileToCameraRoll];
            }else if(index == 1) {
                //用浏览器打开
                [self openVideoFileViaSafari];
            }
        } completion:nil];
//        UIActionSheet *addPictureAS = [[UIActionSheet alloc] initWithTitle:nil
//                                                                  delegate:self
//                                                         cancelButtonTitle:@"取消"
//                                                    destructiveButtonTitle:nil
//                                                         otherButtonTitles:@"保存到手机",isCanOpenInSafari ? @"用浏览器打开" : nil,nil];
//        addPictureAS.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        [addPictureAS showInView:self.view withCompletionHandler:^(NSInteger buttonIndex) {
//            if (buttonIndex == 0) {
//                //保存到手机
//                [self saveVideoFileToCameraRoll];
//            }else if(buttonIndex == 1) {
//                //用浏览器打开
//                [self openVideoFileViaSafari];
//            }
//        }];
    }
}
//保存视频到本地相册
- (void)saveVideoFileToCameraRoll
{
    if (!_localFileURL) {
        return;
    }
    if (_isRemoteVideo) {
        return;
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:_localFileURL]){
        DDLogDebug(@"保存video incompatible with camera roll");
        //        [self showFailedHudWithTitle:@"保存视频失败"];
    }
    [library writeVideoAtPathToSavedPhotosAlbum:_localFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if(error){
            DDLogDebug(@"保存video Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
            [self showFailedHudWithTitle:@"保存视频失败"];
        } else if(assetURL == nil){
            
            //It's possible for writing to camera roll to fail, without receiving an error message, but assetURL will be nil
            //Happens when disk is (almost) full
            DDLogDebug(@"保存Video Error saving to camera roll: no error message, but no url returned");
            [self showFailedHudWithTitle:@"保存视频失败"];
        } else {
            //remove temp file
            DDLogDebug(@"保存视频到本地成功");
            [self showSuccessHudWithTitle:@"保存视频成功"];
        }
    }];
    
}
//用浏览器打开
- (void)openVideoFileViaSafari
{
    if (!_videoURLString) {
        return;
    }
    DDLogDebug(@"浏览器打开的视频url是:%@",_videoURLString);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_videoURLString]];
}
@end
