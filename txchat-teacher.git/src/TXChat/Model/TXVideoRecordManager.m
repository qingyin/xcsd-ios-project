//
//  TXVideoRecordManager.m
//  TXChat
//
//  Created by 陈爱彬 on 15/9/4.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXVideoRecordManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TXVideoAssetWriter.h"

static NSString * const TXVideoFocusObserverContext = @"TXVideoFocusObserverContext";

@interface TXVideoRecordManager()
//<AVCaptureFileOutputRecordingDelegate>
<AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t _sessionQueue;
    dispatch_queue_t _samplebufferQueue;
    struct {
        unsigned int previewRunning:1;
        unsigned int changingModes:1;
        unsigned int recording:1;
        unsigned int paused:1;
        unsigned int interrupted:1;
        unsigned int videoWritten:1;
        unsigned int videoRenderingEnabled:1;
        unsigned int audioCaptureEnabled:1;
        unsigned int thumbnailEnabled:1;
        unsigned int defaultVideoThumbnails:1;
        unsigned int videoCaptureFrame:1;
    } __block _flags;
    CGFloat _videoBitRate;
    NSInteger _audioBitRate;
    NSInteger _videoFrameRate;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *cameraDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *micDeviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, assign) id deviceDisconnectedObserver;
@property (nonatomic, strong) AVCaptureAudioDataOutput *captureOutputAudio;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutputVideo;
@property (nonatomic, strong) TXVideoAssetWriter *videoWriter;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;
@property (nonatomic, strong) UIImage *thumbnailVideoImage;
@end

@implementation TXVideoRecordManager

#pragma mark - 初始化
//创建单例
+ (instancetype)sharedManager
{
    static TXVideoRecordManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    return _manager;
}
- (void)dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
//    [self removeObserver:self forKeyPath:@"cameraDevice.adjustingFocus"];
}
- (instancetype)init
{
    self = [super init];
    if(self){
        _sessionQueue = dispatch_queue_create("com.txchat.videoRecord.session", DISPATCH_QUEUE_SERIAL );
        _samplebufferQueue = dispatch_queue_create("com.txchat.videoRecord.sampleBuffer", DISPATCH_QUEUE_SERIAL);
        _captureSession = [self setupCaptureSession];
        self.assets = [[NSMutableArray alloc] init];
        _aspectRatio = 640.f / 480.f;
        _videoFormat = TXVideoOutputFormatStandard;
        _videoBitRate = 437500 * 8;
        _audioBitRate = 64000;
        _videoFrameRate = 30;
        _flags.audioCaptureEnabled = YES;
    }
    return self;
}
- (void)setDelegate:(id<TXVideoCaptureSessionDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue
{
    if(delegate && ( delegateCallbackQueue == NULL)){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"请设置delegateCallbackQueue" userInfo:nil];
    }
    @synchronized(self)
    {
        _delegate = delegate;
        if (delegateCallbackQueue != _delegateCallbackQueue){
            _delegateCallbackQueue = delegateCallbackQueue;
        }
    }
}
- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if(!_previewLayer && _captureSession){
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        if ([_previewLayer.connection isVideoOrientationSupported]) {
            [_previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    }
    return _previewLayer;
}
#pragma mark - CaptureSession配置
- (AVCaptureSession *)setupCaptureSession
{
    AVCaptureSession *captureSession = [AVCaptureSession new];
    //配置拍摄的分辨率和尺寸
    if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]){
        captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }else {
        //设置失败
        captureSession.sessionPreset = AVCaptureSessionPresetLow;
        DDLogDebug(@"设置相机拍摄分辨率失败");
    }
    //添加input
    if(![self addDefaultCameraInputToCaptureSession:captureSession]){
        DDLogDebug(@"创建相机input到session失败");
    }
    if(![self addDefaultMicInputToCaptureSession:captureSession]){
        DDLogDebug(@"创建麦克风input到session失败");
    }
    //添加output
    if (![self addMovieFileOutputToCaptureSession:captureSession]) {
        DDLogDebug(@"创建movieoutput失败");
    }
    return captureSession;
}
////添加input
//- (void)setupVideoRecordDeviceInput
//{
//    if(![self addDefaultCameraInputToCaptureSession:self.captureSession]){
//        NSLog(@"创建相机input到session失败");
//    }
//    if(![self addDefaultMicInputToCaptureSession:self.captureSession]){
//        NSLog(@"创建麦克风input到session失败");
//    }
//}
//添加相机deviceInput
- (BOOL)addDefaultCameraInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    self.cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    if(error){
        DDLogDebug(@"配置相机deviceInput失败: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:self.cameraDeviceInput toCaptureSession:captureSession];
        _cameraDevice = self.cameraDeviceInput.device;
        // setup video device configuration
        NSError *error = nil;
        if ([_cameraDevice lockForConfiguration:&error]) {
            
            // smooth autofocus for videos
            if ([_cameraDevice respondsToSelector:@selector(setSmoothAutoFocusEnabled:)]) {
                if ([_cameraDevice isSmoothAutoFocusSupported]) {
                    [_cameraDevice setSmoothAutoFocusEnabled:YES];
                }
            }
            [_cameraDevice unlockForConfiguration];
        } else if (error) {
            DLog(@"error locking device for video device configuration (%@)", error);
        }
        //添加KVO检测
        [self addObserver:self forKeyPath:@"cameraDevice.adjustingFocus" options:NSKeyValueObservingOptionNew context:(__bridge void *)TXVideoFocusObserverContext];
        return success;
    }
}
//添加麦克风deviceInput
- (BOOL)addDefaultMicInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    self.micDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if(error){
        DDLogDebug(@"配置麦克风deviceInput失败: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:self.micDeviceInput toCaptureSession:captureSession];
        return success;
    }
}
//添加movieoutout
- (BOOL)addMovieFileOutputToCaptureSession:(AVCaptureSession *)captureSession
{
    self.captureOutputAudio = [[AVCaptureAudioDataOutput alloc] init];
    self.captureOutputVideo = [[AVCaptureVideoDataOutput alloc] init];
    [_captureOutputAudio setSampleBufferDelegate:self queue:_samplebufferQueue];
    [_captureOutputVideo setSampleBufferDelegate:self queue:_samplebufferQueue];
    [_captureOutputVideo setAlwaysDiscardsLateVideoFrames:YES];
    
    if ([captureSession canAddOutput:_captureOutputAudio]) {
        [captureSession addOutput:_captureOutputAudio];
    }
    // vidja output
    if ([captureSession canAddOutput:_captureOutputVideo]) {
        [captureSession addOutput:_captureOutputVideo];
    }
    //设置视频为portrait方式
    AVCaptureConnection *conn = [_captureOutputVideo connectionWithMediaType:AVMediaTypeVideo];
    if ([conn isVideoOrientationSupported]) {
        [conn setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    return YES;
//    self.movieFileOutput = [AVCaptureMovieFileOutput new];
//    return  [self addOutput:_movieFileOutput toCaptureSession:captureSession];
}
//添加deviceInput到session
- (BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession
{
    if([captureSession canAddInput:input]){
        [captureSession addInput:input];
        return YES;
    } else {
        DDLogDebug(@"添加deviceInput失败: %@", [input description]);
    }
    return NO;
}
//添加output到session
- (BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession
{
    if([captureSession canAddOutput:output]){
        [captureSession addOutput:output];
        return YES;
    } else {
        DDLogDebug(@"添加output失败: %@", [output description]);
    }
    return NO;
}
//当view将dismiss时移除audio的输入，避免出现红色（类似打电话的顶部红条）的过渡效果
- (void)removeVideoInputWhenViewDismiss
{
    [self.captureSession removeInput:self.micDeviceInput];
    [self.captureSession removeInput:self.cameraDeviceInput];
    [self removeObserver:self forKeyPath:@"cameraDevice.adjustingFocus"];
    [self setMicDeviceInput:nil];
    [self setCameraDevice:nil];
}
#pragma mark - Public methods
//开始
- (void)startRunning
{
    if (_captureSession.isRunning) {
        return;
    }
    dispatch_sync( _sessionQueue, ^{
        [_captureSession startRunning];
    });
}
//停止
- (void)stopRunning
{
    if (!_captureSession.isRunning) {
        return;
    }
    dispatch_sync( _sessionQueue, ^{
        // the captureSessionDidStopRunning method will stop recording if necessary as well, but we do it here so that the last video and audio samples are better aligned
//        [self stopRecording]; // does nothing if we aren't currently recording
        [_captureSession stopRunning];
    });
}
- (void)stopRunningWithFinishBlock:(void(^)())block
{
    if (!_captureSession.isRunning) {
        return;
    }
    dispatch_sync( _sessionQueue, ^{
        // the captureSessionDidStopRunning method will stop recording if necessary as well, but we do it here so that the last video and audio samples are better aligned
        //        [self stopRecording]; // does nothing if we aren't currently recording
        [_captureSession stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}
//开始录制
- (void)startRecording
{
    dispatch_async(_samplebufferQueue, ^{
//        NSURL *tempURL = [self tempFileURL];
        NSURL *tempURL = [self processedVideoFilePath];
        if (tempURL == nil) {
            return;
        }
        //    [_movieFileOutput startRecordingToOutputFileURL:tempURL recordingDelegate:self];
        if (_videoWriter) {
            _videoWriter = nil;
        }
        self.videoWriter = [[TXVideoAssetWriter alloc] initWithOutputURL:tempURL];
        if (!_videoWriter.isAudioReady) {
            [self _setupMediaWriterAudioInputWithFormatDescription:self.outputAudioFormatDescription];
//            DLog(@"ready for audio (%d)", _videoWriter.isAudioReady);
        }
        if (!_videoWriter.isVideoReady) {
            [self _setupMediaWriterVideoInputWithFormatDescription:self.outputVideoFormatDescription];
//            DLog(@"ready for video (%d)", _videoWriter.isVideoReady);
        }
        NSError *error = [_videoWriter prepareToRecordVideo];
        if (!error) {
            self.thumbnailVideoImage = nil;
            _flags.recording = YES;
            _flags.videoWritten = NO;
        }
//        else{
//            NSLog(@"准备录像video失败:%@",error);
//        }
//        _flags.recording = YES;
//        _flags.videoWritten = NO;
    });
}
//停止录制
- (void)stopRecording
{
    dispatch_async(_samplebufferQueue, ^{
        if (!_flags.recording) {
            return;
        }
        if (!_videoWriter) {
            DDLogDebug(@"没有videoWriter");
            return;
        }
        _flags.recording = NO;
        
        WEAKSELF
        void (^finishWritingCompletionHandler)(void) = ^{
            
            //        NSMutableDictionary *videoDict = [[NSMutableDictionary alloc] init];
            //        NSString *path = [_videoWriter.outputURL path];
            //        if (path) {
            //            NSLog(@"录制路径是:%@",path);
            //        }
            STRONGSELF
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(videoDidFinishRecordingToOutputFileURL:error:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate videoDidFinishRecordingToOutputFileURL:strongSelf.videoWriter.outputURL error:nil];
                });
            }
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(videoDidFinishRecordingToOutputFileURL:thumbnailVideoImage:error:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.delegate videoDidFinishRecordingToOutputFileURL:strongSelf.videoWriter.outputURL thumbnailVideoImage:strongSelf.thumbnailVideoImage error:nil];
                });
            }
        };
        [_videoWriter finishWritingWithCompletionHandler:finishWritingCompletionHandler];
    });
//    dispatch_sync(_sessionQueue, ^{
//        [_movieFileOutput stopRecording];
        
        
        
//        [self removeVideoInputWhenViewDismiss];
//    });
}
#pragma mark - AVCaptureFileOutputRecordingDelegate methods
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    //Recording started
//    NSLog(@"开始录制");
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDidBeginRecording)]) {
        [self.delegate videoDidBeginRecording];
    }
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    //Recording finished - do something with the file at outputFileURL
//    NSLog(@"录制完毕");
//    [self copyFileToCameraRoll:outputFileURL];
//    NSError *copyError = [self copyFileToDocuments:outputFileURL];
//    if (copyError) {
//        NSLog(@"复制文件到document失败:%@",copyError);
//        return;
//    }
    //判断当前是否有用户登录
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser || !currentUser.username || ![currentUser.username length]) {
        return;
    }

//    if (!self.currentUserName || ![self.currentUserName length]) {
//        DDLogDebug(@"当前登录用户为空");
//        return;
//    }
//    AVAsset *asset = [AVAsset assetWithURL:outputFileURL];
//    [self.assets addObject:asset];
//    [self processVideoToPath:[self processedVideoFilePath] completionBlock:^(BOOL finished) {
//        if (finished) {
//            NSLog(@"视频处理成功");
//        }else{
//            NSLog(@"视频处理失败");
//        }
//    }];
    NSURL *filePath = [self processedVideoFilePath];
    NSError *copyError = [self copyFileAtPath:outputFileURL toPath:filePath];
    if (copyError) {
        DDLogDebug(@"复制文件失败");
    }else{
        //移除tmp文件
        [self removeFile:outputFileURL];
        //代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoDidFinishRecordingToOutputFileURL:error:)]) {
            [self.delegate videoDidFinishRecordingToOutputFileURL:filePath error:error];
        }
    }
}
#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)TXVideoFocusObserverContext) {
        
        BOOL isFocusing = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        if (isFocusing) {
            [self _focusStarted];
        } else {
            [self _focusEnded];
        }
        
    }
}
#pragma mark - FileManager
- (NSURL *)tempFileURL
{
    NSString *path = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSInteger i = 0;
    while(path == nil || [fm fileExistsAtPath:path]){
        path = [NSString stringWithFormat:@"%@output%ld.mp4", NSTemporaryDirectory(), (long)i];
        i++;
    }
    return [NSURL fileURLWithPath:path];
}

- (void)removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            DDLogDebug(@"error removing file: %@", [error localizedDescription]);
        }
    }
}
//视频合成的保存路径
- (NSURL *)processedVideoFilePath
{
//    if (!_currentUserName || ![_currentUserName length]) {
//        return nil;
//    }
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
                       [NSString stringWithFormat:@"video-%d%d.mp4",(int)time,x]];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}
//复制文件到某文件
- (NSError *)copyFileAtPath:(NSURL *)fileURL
                     toPath:(NSURL *)toPath
{
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:toPath error:&error];
    if(error){
        DDLogDebug(@"error copying file: %@", [error localizedDescription]);
        return error;
    }
    return nil;
}
//复制文件
- (NSError *)copyFileToDocuments:(NSURL *)fileURL
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/output_%@.mp4", [dateFormatter stringFromDate:[NSDate date]]];
    NSError	*error;
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if(error){
        DDLogDebug(@"error copying file: %@", [error localizedDescription]);
        return error;
    }
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:destinationPath]];
    [self.assets addObject:asset];
    return nil;
}

- (void)copyFileToCameraRoll:(NSURL *)fileURL
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
        DDLogDebug(@"video incompatible with camera roll");
    }
    [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if(error){
            DDLogDebug(@"Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
        } else if(assetURL == nil){
            
            //It's possible for writing to camera roll to fail, without receiving an error message, but assetURL will be nil
            //Happens when disk is (almost) full
            DDLogDebug(@"Error saving to camera roll: no error message, but no url returned");
            
        } else {
            //remove temp file
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
            if(error){
                DDLogDebug(@"error: %@", [error localizedDescription]);
            }
            
        }
    }];
    
}
#pragma mark - 相机Focus
- (void)_focusStarted
{
    //    DLog(@"focus started");
    if (_delegate && [_delegate respondsToSelector:@selector(videoWillStartFocus)]){
        [_delegate videoWillStartFocus];
    }
}

- (void)_focusEnded
{
    AVCaptureFocusMode focusMode = [_cameraDevice focusMode];
    BOOL isFocusing = [_cameraDevice isAdjustingFocus];
    BOOL isAutoFocusEnabled = (focusMode == AVCaptureFocusModeAutoFocus ||
                               focusMode == AVCaptureFocusModeContinuousAutoFocus);
    if (!isFocusing && isAutoFocusEnabled) {
        NSError *error = nil;
        if ([_cameraDevice lockForConfiguration:&error]) {
            
            [_cameraDevice setSubjectAreaChangeMonitoringEnabled:NO];
            [_cameraDevice unlockForConfiguration];
            
        } else if (error) {
            DLog(@"error locking device post exposure for subject area change monitoring (%@)", error);
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoDidEndFocus)]){
        [_delegate videoDidEndFocus];
    }
}
//获取转化后的坐标点
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates inFrame:(CGRect)frame
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = frame.size;
    
    // TODO: add check for AVCaptureConnection videoMirrored
    //        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    
    AVCaptureVideoPreviewLayer *previewLayer = [[TXVideoRecordManager sharedManager] previewLayer];
    
    if ( [[previewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGSize apertureSize = CGSizeMake(CGRectGetHeight(frame), CGRectGetWidth(frame));
        if (!CGSizeEqualToSize(apertureSize, CGSizeZero)) {
            CGPoint point = viewCoordinates;
            CGFloat apertureRatio = apertureSize.height / apertureSize.width;
            CGFloat viewRatio = frameSize.width / frameSize.height;
            CGFloat xc = .5f;
            CGFloat yc = .5f;
            
            if ( [[previewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                if (viewRatio > apertureRatio) {
                    CGFloat y2 = frameSize.height;
                    CGFloat x2 = frameSize.height * apertureRatio;
                    CGFloat x1 = frameSize.width;
                    CGFloat blackBar = (x1 - x2) / 2;
                    if (point.x >= blackBar && point.x <= blackBar + x2) {
                        xc = point.y / y2;
                        yc = 1.f - ((point.x - blackBar) / x2);
                    }
                } else {
                    CGFloat y2 = frameSize.width / apertureRatio;
                    CGFloat y1 = frameSize.height;
                    CGFloat x2 = frameSize.width;
                    CGFloat blackBar = (y1 - y2) / 2;
                    if (point.y >= blackBar && point.y <= blackBar + y2) {
                        xc = ((point.y - blackBar) / y2);
                        yc = 1.f - (point.x / x2);
                    }
                }
            } else if ([[previewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                if (viewRatio > apertureRatio) {
                    CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                    xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                    yc = (frameSize.width - point.x) / frameSize.width;
                } else {
                    CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                    yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                    xc = point.y / frameSize.height;
                }
            }
            
            pointOfInterest = CGPointMake(xc, yc);
        }
    }
    
    return pointOfInterest;
}
// focusExposeAndAdjustWhiteBalanceAtAdjustedPoint: will put focus and exposure into auto
- (void)focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:(CGPoint)adjustedPoint
{
    if ([_cameraDevice isAdjustingFocus] || [_cameraDevice isAdjustingExposure])
        return;
    
    NSError *error = nil;
    if ([_cameraDevice lockForConfiguration:&error]) {
        
        BOOL isFocusAtPointSupported = [_cameraDevice isFocusPointOfInterestSupported];
        BOOL isExposureAtPointSupported = [_cameraDevice isExposurePointOfInterestSupported];
        BOOL isWhiteBalanceModeSupported = [_cameraDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        if (isFocusAtPointSupported && [_cameraDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [_cameraDevice setFocusPointOfInterest:adjustedPoint];
            [_cameraDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if (isExposureAtPointSupported && [_cameraDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [_cameraDevice setExposurePointOfInterest:adjustedPoint];
            [_cameraDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        
        if (isWhiteBalanceModeSupported) {
            [_cameraDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        
        [_cameraDevice setSubjectAreaChangeMonitoringEnabled:NO];
        
        [_cameraDevice unlockForConfiguration];
        
    } else if (error) {
        DDLogDebug(@"error locking device for focus / exposure / white-balance adjustment (%@)", error);
    }
}
#pragma mark - 图片解码
- (UIImage *)videoThumbnailFromURL:(NSURL *)url
{
    if (!url) {
        return nil;
    }
    AVAsset *m_asset = [AVAsset assetWithURL:url];
    NSError *error = nil;
    AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:m_asset error:&error];
    if(error) {
//        NSLog(@"解码成图片失败");
        return nil;
    }
    NSArray* videoTracks = [m_asset tracksWithMediaType:AVMediaTypeVideo];
    if (!videoTracks || ![videoTracks count]) {
        return nil;
    }
    AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
    // 视频播放时，m_pixelFormatType=kCVPixelFormatType_32BGRA
    // 其他用途，如视频压缩，m_pixelFormatType=kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:
                                                                (int)kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc]
                                                   initWithTrack:videoTrack outputSettings:options];
    [reader addOutput:videoReaderOutput];
    [reader startReading];
    UIImage *image = nil;
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0 && image == nil) {
        // 读取video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
        //            [m_delegate mMovieDecoder:self onNewVideoFrameReady:videoBuffer);
        image = [self imageFromSampleBuffer:videoBuffer];
    }
    return image;
}
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
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
#pragma mark - 视频处理
- (void)processVideoToPath:(NSURL *)filePath
           completionBlock:(void (^)(BOOL))completion
{
    if ([self.assets count] != 0) {
        
        // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
        // 2 - Video track
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        __block CMTime time = kCMTimeZero;
        __block CGAffineTransform translate;
        __block CGSize size;
        
        [self.assets enumerateObjectsUsingBlock:^(AVAsset *asset, NSUInteger idx, BOOL *stop) {
            
            // AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:string]];//obj]];
            AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:videoAssetTrack atTime:time error:nil];
            
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                ofTrack:[[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            if(idx == 0)
            {
                // Set your desired output aspect ratio here. 1.0 for square, 16/9.0 for widescreen, etc.
                CGFloat desiredAspectRatio = self.aspectRatio;
                CGSize naturalSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
                CGSize adjustedSize = CGSizeApplyAffineTransform(naturalSize, videoAssetTrack.preferredTransform);
                adjustedSize.width = ABS(adjustedSize.width);
                adjustedSize.height = ABS(adjustedSize.height);
                if (adjustedSize.width > adjustedSize.height) {
                    size = CGSizeMake(adjustedSize.height * desiredAspectRatio, adjustedSize.height);
                    translate = CGAffineTransformMakeTranslation(-(adjustedSize.width - size.width) / 2.0, 0);
                } else {
                    size = CGSizeMake(adjustedSize.width, adjustedSize.width / desiredAspectRatio);
                    translate = CGAffineTransformMakeTranslation(0, -(adjustedSize.height - size.height) / 2.0);
                }
                CGAffineTransform newTransform = CGAffineTransformConcat(videoAssetTrack.preferredTransform, translate);
                [videoTrack setPreferredTransform:newTransform];
                
                // Check the output size - for best results use sizes that are multiples of 16
                // More info: http://stackoverflow.com/questions/22883525/avassetexportsession-giving-me-a-green-border-on-right-and-bottom-of-output-vide
                if (fmod(size.width, 4.0) != 0)
                    DDLogDebug(@"NOTE: The video output width %0.1f is not a multiple of 4, which may cause a green line to appear at the edge of the video", size.width);
                if (fmod(size.height, 4.0) != 0)
                    DDLogDebug(@"NOTE: The video output height %0.1f is not a multiple of 4, which may cause a green line to appear at the edge of the video", size.height);
            }
            
            time = CMTimeAdd(time, asset.duration);
        }];
        
        AVMutableVideoCompositionInstruction *vtemp = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        vtemp.timeRange = CMTimeRangeMake(kCMTimeZero, time);
        DDLogDebug(@"\nInstruction vtemp's time range is %f %f", CMTimeGetSeconds( vtemp.timeRange.start),
              CMTimeGetSeconds(vtemp.timeRange.duration));
        
        // Also tried videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack
        AVMutableVideoCompositionLayerInstruction *vLayerInstruction = [AVMutableVideoCompositionLayerInstruction
                                                                        videoCompositionLayerInstructionWithAssetTrack:videoTrack];
        
        
        [vLayerInstruction setTransform:videoTrack.preferredTransform atTime:kCMTimeZero];
        vtemp.layerInstructions = @[vLayerInstruction];
        
        AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.renderSize = size;
        videoComposition.frameDuration = CMTimeMake(1,30);
        videoComposition.instructions = @[vtemp];
        
        // 4 - Get path
        NSURL *url = filePath;
        
        // 5 - Create exporter
        self.exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                              presetName:AVAssetExportPresetHighestQuality];
        self.exportSession.outputURL = url;
        //导出为MP4文件
        self.exportSession.outputFileType = AVFileTypeMPEG4;
        self.exportSession.shouldOptimizeForNetworkUse = YES;
        self.exportSession.videoComposition = videoComposition;
        
//        self.exportProgressBarTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self.delegate selector:@selector(updateProgress) userInfo:nil repeats:YES];
        
        //测试，保存到相册方便查看效果
//        [self copyFileToCameraRoll:url];
        __weak id weakSelf = self;
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            DDLogDebug (@"i is in your block, exportin. status is %ld",(long)self.exportSession.status);
//            dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf handleVideoByBufferRefWithSession:self.exportSession toPath:url completion:completion];
//            });
        }];
    }
}
-(void)exportDidFinish:(AVAssetExportSession*)session
           withFileUrl:(NSURL *)fileUrl
   withCompletionBlock:(void(^)(BOOL success))completion {
    self.exportSession = nil;
    
    __weak id weakSelf = self;
    //delete stored pieces
    [self.assets enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(AVAsset *asset, NSUInteger idx, BOOL *stop) {
        
        NSURL *fileURL = nil;
        if ([asset isKindOfClass:AVURLAsset.class])
        {
            AVURLAsset *urlAsset = (AVURLAsset*)asset;
            fileURL = urlAsset.URL;
        }
        
        if (fileURL)
            [weakSelf removeFile:fileURL];
    }];
    
    [self.assets removeAllObjects];
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
//        NSURL *outputURL = session.outputURL;
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
//            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
//                //delete file from documents after saving to camera roll
//                [weakSelf removeFile:outputURL];
//                
//                if (error) {
//                    completion (NO);
//                } else {
//                    completion (YES);
//                }
//            }];
//        }
        DDLogDebug(@"导出成功");
        if (_delegate && [_delegate respondsToSelector:@selector(videoDidFinishRecordingToOutputFileURL:error:)]) {
            [_delegate videoDidFinishRecordingToOutputFileURL:fileUrl error:nil];
        }
    }else{
        DDLogDebug(@"导出失败");
        if (_delegate && [_delegate respondsToSelector:@selector(videoDidFinishRecordingToOutputFileURL:error:)]) {
            [_delegate videoDidFinishRecordingToOutputFileURL:nil error:[NSError errorWithDomain:@"export Failed" code:-1000 userInfo:nil]];
        }
    }
}
- (void)handleVideoByBufferRefWithSession:(AVAssetExportSession*)session
                                   toPath:(NSURL *)filePath
                               completion:(void(^)(BOOL))completion
{
    [self exportDidFinish:session withFileUrl:filePath withCompletionBlock:completion];
//    return;
    
//    if ([self.assets count] != 0) {
//        AVAsset *m_asset = self.assets[0];
//        if (_delegate && [_delegate respondsToSelector:@selector(videoDidFinishedWithAVAsset:error:)]) {
//            [_delegate videoDidFinishedWithAVAsset:m_asset error:nil];
//        }

        
//        NSError *error = nil;
//        AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:m_asset error:&error];
//        if(error) {
//            NSLog(@"处理失败");
//            return;
//        }
//        NSArray* videoTracks = [m_asset tracksWithMediaType:AVMediaTypeVideo];
//        AVAssetTrack* videoTrack = [videoTracks objectAtIndex:0];
//        // 视频播放时，m_pixelFormatType=kCVPixelFormatType_32BGRA
//        // 其他用途，如视频压缩，m_pixelFormatType=kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
//        NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:
//                                                                    (int)kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//        AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc]
//                                                       initWithTrack:videoTrack outputSettings:options];
//        [reader addOutput:videoReaderOutput];
//        [reader startReading];
//        // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
//        while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
//            // 读取video sample
//            CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
////            [m_delegate mMovieDecoder:self onNewVideoFrameReady:videoBuffer);
//            CFRelease(videoBuffer);
//            // 根据需要休眠一段时间；比如上层播放视频时每帧之间是有间隔的
////            [NSThread sleepForTimeInterval:sampleInternal];
//        }

//        [self exportDidFinish:session withFileUrl:filePath withCompletionBlock:completion];
//    }
}
#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CFRetain(sampleBuffer);
    
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        DLog(@"sample buffer data is not ready");
        CFRelease(sampleBuffer);
        return;
    }
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    if (captureOutput == _captureOutputVideo) {
        self.outputVideoFormatDescription = formatDescription;
    }else if (captureOutput == _captureOutputAudio) {
        self.outputAudioFormatDescription = formatDescription;
    }

    if (!_flags.recording) {
        CFRelease(sampleBuffer);
        return;
    }

    BOOL isVideo = (captureOutput == _captureOutputVideo);
//    if (!isVideo && !_videoWriter.isAudioReady) {
//        [self _setupMediaWriterAudioInputWithSampleBuffer:sampleBuffer];
//        DLog(@"ready for audio (%d)", _videoWriter.isAudioReady);
//    }
//    if (isVideo && !_videoWriter.isVideoReady) {
//        [self _setupMediaWriterVideoInputWithSampleBuffer:sampleBuffer];
//        DLog(@"ready for video (%d)", _videoWriter.isVideoReady);
//    }
    
//    NSLog(@"开始录制视频了");
    // setup media writer
    if (!_videoWriter) {
        CFRelease(sampleBuffer);
        DDLogDebug(@"没有videoWriter");
        return;
    }

    BOOL isReadyToRecord = ((!_flags.audioCaptureEnabled || _videoWriter.isAudioReady) && _videoWriter.isVideoReady);
    if (!isReadyToRecord) {
        DDLogDebug(@"还没准备好录制");
        CFRelease(sampleBuffer);
        return;
    }
    
//    CMTime currentTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    // calculate the length of the interruption and store the offsets
//    if (_flags.recording) {
//        if (isVideo) {
//            CFRelease(sampleBuffer);
//            return;
//        }
//        
//        // calculate the appropriate time offset
//        if (CMTIME_IS_VALID(currentTimestamp) && CMTIME_IS_VALID(_mediaWriter.audioTimestamp)) {
//            if (CMTIME_IS_VALID(_timeOffset)) {
//                currentTimestamp = CMTimeSubtract(currentTimestamp, _timeOffset);
//            }
//            
//            CMTime offset = CMTimeSubtract(currentTimestamp, _mediaWriter.audioTimestamp);
//            _timeOffset = CMTIME_IS_INVALID(_timeOffset) ? offset : CMTimeAdd(_timeOffset, offset);
//            DLog(@"new calculated offset %f valid (%d)", CMTimeGetSeconds(_timeOffset), CMTIME_IS_VALID(_timeOffset));
//        }
//        _flags.interrupted = NO;
//    }
    
    // adjust the sample buffer if there is a time offset
    CMSampleBufferRef bufferToWrite = NULL;
    bufferToWrite = sampleBuffer;
    CFRetain(bufferToWrite);

//    if (CMTIME_IS_VALID(_timeOffset)) {
//        //CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
//        bufferToWrite = [PBJVisionUtilities createOffsetSampleBufferWithSampleBuffer:sampleBuffer withTimeOffset:_timeOffset];
//        if (!bufferToWrite) {
//            DLog(@"error subtracting the timeoffset from the sampleBuffer");
//        }
//    } else {
//        bufferToWrite = sampleBuffer;
//        CFRetain(bufferToWrite);
//    }
    
    // write the sample buffer
    if (bufferToWrite) {
//        NSLog(@"写samplebuffer");
        if (isVideo) {
            [_videoWriter writeSampleBuffer:bufferToWrite withMediaTypeVideo:isVideo];
            _flags.videoWritten = YES;
        }else if (!isVideo && _flags.videoWritten) {
            [_videoWriter writeSampleBuffer:bufferToWrite withMediaTypeVideo:isVideo];
        }
//        if (!self.thumbnailVideoImage) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                CMSampleBufferRef thumbnailBuffer = NULL;
//                thumbnailBuffer = bufferToWrite;
//                CFRetain(thumbnailBuffer);
//                self.thumbnailVideoImage = [self imageFromSampleBuffer:thumbnailBuffer];
//                CFRelease(thumbnailBuffer);
//            });
//        }
//        _flags.videoWritten = YES;
        
        // process the sample buffer for rendering onion layer or capturing video photo
        
    }
    
//    [self _automaticallyEndCaptureIfMaximumDurationReachedWithSampleBuffer:sampleBuffer];
    
    if (bufferToWrite) {
        CFRelease(bufferToWrite);
    }
    
    CFRelease(sampleBuffer);

}
#pragma mark - media writer setup

- (BOOL)_setupMediaWriterAudioInputWithFormatDescription:(CMFormatDescriptionRef)formatDescription
{
//    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    if (formatDescription == NULL) {
        return NO;
    }
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
    if (!asbd) {
        DLog(@"audio stream description used with non-audio format description");
        return NO;
    }
    
    unsigned int channels = asbd->mChannelsPerFrame;
    double sampleRate = asbd->mSampleRate;
    
//    DLog(@"audio stream setup, channels (%d) sampleRate (%f)", channels, sampleRate);
    
    size_t aclSize = 0;
    const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(formatDescription, &aclSize);
    NSData *currentChannelLayoutData = ( currentChannelLayout && aclSize > 0 ) ? [NSData dataWithBytes:currentChannelLayout length:aclSize] : [NSData data];
    
    NSDictionary *audioCompressionSettings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                                AVNumberOfChannelsKey : @(channels),
                                                AVSampleRateKey :  @(sampleRate),
                                                AVEncoderBitRateKey : @(_audioBitRate),
                                                AVChannelLayoutKey : currentChannelLayoutData };
    
    return [_videoWriter setupAudioWithSettings:audioCompressionSettings];
}

- (BOOL)_setupMediaWriterVideoInputWithFormatDescription:(CMFormatDescriptionRef)formatDescription
{
//    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    if (formatDescription == NULL) {
        return NO;
    }
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    
    CMVideoDimensions videoDimensions = dimensions;
    switch (_videoFormat) {
        case TXVideoOutputFormatSquare:
        {
            int32_t min = MIN(dimensions.width, dimensions.height);
            videoDimensions.width = min;
            videoDimensions.height = min;
            break;
        }
        case TXVideoOutputFormatWidescreen:
        {
            videoDimensions.width = dimensions.width;
            videoDimensions.height = (int32_t)(dimensions.width * 9 / 16.0f);
            break;
        }
        case TXVideoOutputFormatStandard:
        {
            videoDimensions.width = dimensions.width;
            videoDimensions.height = (int32_t)(dimensions.width * 3 / 4.0f);
            break;
        }
        case TXVideoOutputFormatPreset:
        default:
            break;
    }
    int numPixels = videoDimensions.width * videoDimensions.height;
    int bitsPerSecond;
    float bitsPerPixel;

    if ( numPixels <= ( 640 * 480 ) ) {
        bitsPerPixel = 4.05; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetMedium or Low.
    }
    else {
        bitsPerPixel = 10.1; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetHigh.
    }
    bitsPerSecond = numPixels * bitsPerPixel;

    //压缩视频大小，节省流量
    NSDictionary *compressionSettings = nil;
    compressionSettings = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                             AVVideoMaxKeyFrameIntervalKey : @(_videoFrameRate),
                             AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline30 };
    
//    NSDictionary *videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
//                                     AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
//                                     AVVideoWidthKey : @(videoDimensions.width),
//                                     AVVideoHeightKey : @(videoDimensions.height)};
    NSDictionary *videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                     AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                     AVVideoWidthKey : @(videoDimensions.width),
                                     AVVideoHeightKey : @(videoDimensions.height),
                                     AVVideoCompressionPropertiesKey : compressionSettings};
    
    return [_videoWriter setupVideoWithSettings:videoSettings withAdditional:nil];
}

@end
