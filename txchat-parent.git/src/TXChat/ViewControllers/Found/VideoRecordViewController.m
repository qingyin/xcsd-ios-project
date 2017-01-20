//
//  VideoRecordViewController.m
//  TXChat
//
//  Created by 陈爱彬 on 15/9/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "VideoRecordViewController.h"
#import "TXVideoRecordManager.h"
#import "VideoRecordProgressView.h"
#import "CirclePublishViewController.h"
#import "TXSystemManager.h"
#import "VideoFocusView.h"

static CGFloat const kVideoMaximunRecordTime = 10.f;
static CGFloat const kVideoMinimumRecordTime = 2.f;

@interface VideoRecordViewController ()
<TXVideoCaptureSessionDelegate,
VideoRecordProgressViewDelegate,
UIGestureRecognizerDelegate>
{
    UIButton *_videoRecordButton;
    UIView *_recordView;
    VideoRecordProgressView *_progressView;
    struct {
        unsigned int finishRecord:1;
        unsigned int recording:1;
    } __block _flags;
    UITapGestureRecognizer *_focusTapGestureRecognizer;
    VideoFocusView *_focusView;
    NSDate *_startRecordDate;
    NSDate *_endRecordDate;
}
@end

@implementation VideoRecordViewController

- (void)dealloc
{
    [[TXVideoRecordManager sharedManager] stopRunning];
    [[TXVideoRecordManager sharedManager] setDelegate:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDarkModeNavigationBar];
    [self setupVideoRecordView];
    [self setupVideoCaptureSession];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //设置导航栏效果
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //停止running
    [[TXVideoRecordManager sharedManager] stopRunning];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //设置导航栏效果
    if (IOS7_OR_LATER) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
    //开始running
    [[TXVideoRecordManager sharedManager] startRunning];
    //重置进度视图
    [_progressView resetProgressView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 视频录制+预览
- (void)setupVideoCaptureSession
{
    //设置代理
    [[TXVideoRecordManager sharedManager] setDelegate:self callbackQueue:dispatch_get_main_queue()];
    //设置用户id
    //    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    //    [[TXVideoRecordManager sharedManager] setCurrentUserName:currentUser.username];
    //设置预览layer
    AVCaptureVideoPreviewLayer *previewLayer = [[TXVideoRecordManager sharedManager] previewLayer];
    previewLayer.frame = _recordView.bounds;
    [_recordView.layer insertSublayer:previewLayer atIndex:0];
    //开始录制
    [[TXVideoRecordManager sharedManager] startRunning];
    _progressView.tipString = @"按住拍摄";
}
#pragma mark - UI视图
- (void)setupVideoRecordView
{
    CGFloat videoRadio = [TXVideoRecordManager sharedManager].aspectRatio;
    CGFloat height = CGRectGetHeight(self.view.frame) - self.customNavigationView.maxY;
    _recordView = [[UIView alloc] initWithFrame:CGRectMake(0, self.customNavigationView.maxY, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) / videoRadio)];
    _recordView.backgroundColor = [UIColor clearColor];
    _recordView.userInteractionEnabled = YES;
    [self.view addSubview:_recordView];
    //添加中间掏空边缘半透视图
    //    CAShapeLayer *bglayer = [CAShapeLayer layer];
    //    bglayer.fillColor = RGBACOLOR(0, 0, 0, 0.7).CGColor;
    //    CGMutablePathRef maskPath = CGPathCreateMutable();
    //    CGPathAddRect(maskPath, nil, CGRectInset(_recordView.bounds, 0, 0));
    //    CGPathAddRect(maskPath, nil, CGRectInset(_recordView.bounds, 50, 50));
    //    bglayer.path = maskPath;
    //    bglayer.fillRule = kCAFillRuleEvenOdd;
    //    [_recordView.layer addSublayer:bglayer];
    //focus view
    _focusView = [[VideoFocusView alloc] initWithFrame:CGRectZero];
    //添加focus手势
    _focusTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocusTapGesterRecognizer:)];
    _focusTapGestureRecognizer.numberOfTapsRequired = 1;
    //    _focusTapGestureRecognizer.enabled = YES;
    [_recordView addGestureRecognizer:_focusTapGestureRecognizer];
    //录制视图
    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, _recordView.maxY, CGRectGetWidth(self.view.frame), height - _recordView.height_)];
    menuView.backgroundColor = RGBCOLOR(10, 10, 10);
    [self.view addSubview:menuView];
    //进度视图
    _progressView = [[VideoRecordProgressView alloc] initWithFrame:CGRectMake(0, 0, menuView.height_ / 2 + 10, menuView.height_ / 2 + 10)];
    _progressView.center = menuView.center;
    _progressView.duration = kVideoMaximunRecordTime;
    _progressView.delegate = self;
    [self.view addSubview:_progressView];
    //按钮
    _videoRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _videoRecordButton.frame = CGRectMake(0, 0, menuView.height_ / 2 + 10, menuView.height_ / 2 + 10);
    _videoRecordButton.center = menuView.center;
    [_videoRecordButton addTarget:self action:@selector(onVideoRecordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [_videoRecordButton addTarget:self action:@selector(onVideoRecordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [_videoRecordButton addTarget:self action:@selector(onVideoRecordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:_videoRecordButton];
}
#pragma mark - 手势
- (void)handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:_recordView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = _focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [_focusView setFrame:focusFrame];
    
    [_recordView addSubview:_focusView];
    [_focusView startAnimation];
    
    CGPoint adjustPoint = [TXVideoRecordManager convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:_recordView.frame];
    [[TXVideoRecordManager sharedManager] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}
#pragma mark - 按钮点击
- (void)onClickBtn:(UIButton *)sender
{
    if (sender.tag == TopBarButtonLeft) {
        //        if (_showType == TXVideoRecordVCShowType_Push) {
        //            [self.navigationController popViewControllerAnimated:YES];
        //        }else if (_showType == TXVideoRecordVCShowType_Present) {
        //            [self dismissViewControllerAnimated:YES completion:nil];
        //        }
        [[TXVideoRecordManager sharedManager] stopRunningWithFinishBlock:^{
            if (_showType == TXVideoRecordVCShowType_Push) {
                [self.navigationController popViewControllerAnimated:YES];
            }else if (_showType == TXVideoRecordVCShowType_Present) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}
//按下开始拍摄按钮
- (void)onVideoRecordButtonTouchDown
{
    if (!_flags.recording) {
        [self zoomVideoRecordButtonAnimation];
        _startRecordDate = [NSDate date];
    }
}
//松手并停止拍摄
- (void)onVideoRecordButtonTouchUpInside
{
    if (_flags.recording && !_flags.finishRecord) {
        _endRecordDate = [NSDate date];
        [self scaleVideoRecordButtonToOriginal];
    }
}
#pragma mark - 动画
//按住拍按钮点击放大消失动画
- (void)zoomVideoRecordButtonAnimation
{
    _flags.recording = YES;
    _flags.finishRecord = NO;
    [_progressView startAnimating];
    _progressView.tipString = @"松开发送";
    //开始录制
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[TXVideoRecordManager sharedManager] startRecording];
}
//按住拍按钮松开手缩小还原动画
- (void)scaleVideoRecordButtonToOriginal
{
    _flags.recording = NO;
    _flags.finishRecord = YES;
    //停止录制
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[TXVideoRecordManager sharedManager] stopRecording];
    //停止动画
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progressView stopAnimating];
        _progressView.tipString = @"按住拍摄";
    });
}
#pragma mark - VideoRecordProgressViewDelegate
- (void)progressAnimationDidFinsihed:(VideoRecordProgressView *)progressView
{
    if (_flags.recording && !_flags.finishRecord) {
        _endRecordDate = [NSDate date];
        [self scaleVideoRecordButtonToOriginal];
    }
}
#pragma mark - TXVideoCaptureSessionDelegate
- (void)videoDidEndFocus
{
    if (_focusView && [_focusView superview]) {
        [_focusView stopAnimation];
    }
}
- (void)videoDidFinishRecordingToOutputFileURL:(NSURL *)outputFileURL thumbnailVideoImage:(UIImage *)image error:(NSError *)error
{
    if (error) {
        DDLogDebug(@"录制视频error:%@",error);
        [self showFailedHudWithTitle:@"录制视频出错,请退出重试!"];
        return;
    }
    if (!outputFileURL) {
        DDLogDebug(@"录制的视频url为空:%@",outputFileURL);
        [self showFailedHudWithTitle:@"录制视频出错!"];
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[outputFileURL relativePath]]) {
        DDLogDebug(@"路径为空:%@",outputFileURL);
        [self showFailedHudWithTitle:@"录制视频出错,请重试!"];
        return;
    }
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[outputFileURL relativePath]];
    unsigned long long fileSize = [handle seekToEndOfFile];
    if (fileSize == 0) {
        DDLogDebug(@"录制的视频大小为空:%@",@(fileSize));
        [self showFailedHudWithTitle:@"录制的视频为空,请稍后重试!"];
        return;
    }
    if (_showType == TXVideoRecordVCShowType_Push) {
        if (!error) {
            TXAsyncRunInMain(^{
                NSTimeInterval interval = [_endRecordDate timeIntervalSinceDate:_startRecordDate];
                if (interval < kVideoMinimumRecordTime) {
                    //时间过短
                    [self showFailedHudWithTitle:@"录制时间过短,请重新录制"];
                    //删除录制文件
                    [[TXVideoRecordManager sharedManager] removeFile:outputFileURL];
                    return;
                }
                [[TXVideoRecordManager sharedManager] stopRunningWithFinishBlock:^{
                    CirclePublishViewController *uploadVc = [[CirclePublishViewController alloc] init];
                    uploadVc.videoType = YES;
                    uploadVc.videoThumbImage = image;
                    uploadVc.videoURL = outputFileURL;
                    uploadVc.videoBackVc = _backVc;
                    [self.navigationController pushViewController:uploadVc animated:YES];
                }];
            });
        }
    }else if (_showType == TXVideoRecordVCShowType_Present) {
        NSTimeInterval interval = [_endRecordDate timeIntervalSinceDate:_startRecordDate];
        if (interval < kVideoMinimumRecordTime) {
            //时间过短
            [self showFailedHudWithTitle:@"录制时间过短,请重新录制"];
            //删除录制文件
            [[TXVideoRecordManager sharedManager] removeFile:outputFileURL];
            return;
        }
        [[TXVideoRecordManager sharedManager] stopRunningWithFinishBlock:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishedWithVideoURL:)]) {
                TXAsyncRunInMain(^{
                    [self.delegate recordFinishedWithVideoURL:outputFileURL];
                });
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}
@end
