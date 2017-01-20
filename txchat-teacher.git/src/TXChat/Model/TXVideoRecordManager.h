//
//  TXVideoRecordManager.h
//  TXChat
//
//  Created by 陈爱彬 on 15/9/4.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, TXVideoOutputFormat) {
    TXVideoOutputFormatPreset = 0,
    TXVideoOutputFormatSquare, // 1:1
    TXVideoOutputFormatWidescreen, // 16:9
    TXVideoOutputFormatStandard // 4:3
};

@protocol TXVideoCaptureSessionDelegate;

@interface TXVideoRecordManager : NSObject

@property (nonatomic, weak) id<TXVideoCaptureSessionDelegate> delegate;
@property (nonatomic, strong) dispatch_queue_t delegateCallbackQueue;
//视频合成时的宽高比，默认为640:480
@property (nonatomic, assign) CGFloat aspectRatio;
//当前登录用户的id,不设置会导致不保存视频
//@property (nonatomic, copy) NSString *currentUserName;
//默认是4:3
@property (nonatomic, assign) TXVideoOutputFormat videoFormat;

//创建单例
+ (instancetype)sharedManager;
//设置代理
- (void)setDelegate:(id<TXVideoCaptureSessionDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;
//开始
- (void)startRunning;
//停止
- (void)stopRunning;
- (void)stopRunningWithFinishBlock:(void(^)())block;
//开始录制
- (void)startRecording;
//停止录制
- (void)stopRecording;
//previewLayer
- (AVCaptureVideoPreviewLayer *)previewLayer;
//添加deviceInput
//- (void)setupVideoRecordDeviceInput;
//当view将dismiss时移除audio的输入，避免出现红色（类似打电话的顶部红条）的过渡效果
- (void)removeVideoInputWhenViewDismiss;
//获取视频的第一帧图片
- (UIImage *)videoThumbnailFromURL:(NSURL *)url;
//获取转化后的坐标点
+ (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates inFrame:(CGRect)frame;
//设置聚焦曝光和白平衡
- (void)focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:(CGPoint)adjustedPoint;
//删除文件
- (void)removeFile:(NSURL *)fileURL;

@end

@protocol TXVideoCaptureSessionDelegate <NSObject>

@optional

- (void)videoWillStartFocus;
- (void)videoDidEndFocus;
- (void)videoDidBeginRecording;
- (void)videoDidFinishRecordingToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error;
- (void)videoDidFinishRecordingToOutputFileURL:(NSURL *)outputFileURL
                           thumbnailVideoImage:(UIImage *)image
                                         error:(NSError *)error;

@end
