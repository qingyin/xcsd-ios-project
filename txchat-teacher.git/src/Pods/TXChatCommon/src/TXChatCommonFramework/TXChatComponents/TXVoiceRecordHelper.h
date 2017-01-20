//
//  TXVoiceRecordHelper.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^TXPrepareRecorderCompletion)();
typedef void(^TXStartRecorderCompletion)();
typedef void(^TXStopRecorderCompletion)();
typedef void(^TXPauseRecorderCompletion)();
typedef void(^TXResumeRecorderCompletion)();
typedef void(^TXCancellRecorderDeleteFileCompletion)();
typedef void(^TXRecordProgress)(float progress);
typedef void(^TXPeakPowerForChannel)(float peakPowerForChannel);


@interface TXVoiceRecordHelper : NSObject

@property (nonatomic, copy) TXStopRecorderCompletion maxTimeStopRecorderCompletion;
@property (nonatomic, copy) TXRecordProgress recordProgress;
@property (nonatomic, copy) TXPeakPowerForChannel peakPowerForChannel;
@property (nonatomic, copy, readonly) NSString *recordPath;
@property (nonatomic, copy) NSString *recordDuration;
@property (nonatomic) CGFloat maxRecordTime; // 默认 60秒为最大
@property (nonatomic, readonly) NSTimeInterval currentTimeInterval;

- (void)prepareRecordingWithPath:(NSString *)path prepareRecorderCompletion:(TXPrepareRecorderCompletion)prepareRecorderCompletion;
- (void)startRecordingWithStartRecorderCompletion:(TXStartRecorderCompletion)startRecorderCompletion;
- (void)pauseRecordingWithPauseRecorderCompletion:(TXPauseRecorderCompletion)pauseRecorderCompletion;
- (void)resumeRecordingWithResumeRecorderCompletion:(TXResumeRecorderCompletion)resumeRecorderCompletion;
- (void)stopRecordingWithStopRecorderCompletion:(TXStopRecorderCompletion)stopRecorderCompletion;
- (void)cancelledDeleteWithCompletion:(TXCancellRecorderDeleteFileCompletion)cancelledDeleteCompletion;

@end
