//
//  TXVideoAssetWriter.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/21.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXVideoAssetWriter.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface TXVideoAssetWriter()
{
    AVAssetWriter *_assetWriter;
    AVAssetWriterInput *_assetWriterAudioInput;
    AVAssetWriterInput *_assetWriterVideoInput;
    
    NSURL *_outputURL;
    
    CMTime _audioTimestamp;
    CMTime _videoTimestamp;
}
@property (nonatomic) BOOL haveStartedSession;

@end
@implementation TXVideoAssetWriter


#pragma mark - getters/setters

- (BOOL)isAudioReady
{
    if (!IOS7_OR_LATER) {
        return _assetWriterAudioInput != nil;
    }
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    BOOL isAudioNotAuthorized = (audioAuthorizationStatus == AVAuthorizationStatusNotDetermined || audioAuthorizationStatus == AVAuthorizationStatusDenied);
    BOOL isAudioSetup = (_assetWriterAudioInput != nil) || isAudioNotAuthorized;
    
    return isAudioSetup;
}

- (BOOL)isVideoReady
{
    if (!IOS7_OR_LATER) {
        return _assetWriterVideoInput != nil;
    }
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    BOOL isVideoNotAuthorized = (videoAuthorizationStatus == AVAuthorizationStatusNotDetermined || videoAuthorizationStatus == AVAuthorizationStatusDenied);
    BOOL isVideoSetup = (_assetWriterVideoInput != nil) || isVideoNotAuthorized;
    
    return isVideoSetup;
}

- (NSError *)error
{
    return _assetWriter.error;
}

#pragma mark - init

- (id)initWithOutputURL:(NSURL *)outputURL
{
    self = [super init];
    if (self) {
        NSError *error = nil;
        _assetWriter = [AVAssetWriter assetWriterWithURL:outputURL fileType:(NSString *)kUTTypeMPEG4 error:&error];
        if (error) {
            NSLog(@"error setting up the asset writer (%@)", error);
            _assetWriter = nil;
            return nil;
        }
        
        _outputURL = outputURL;
        
        _assetWriter.shouldOptimizeForNetworkUse = YES;
        _assetWriter.metadata = [self _metadataArray];
        
        _audioTimestamp = kCMTimeInvalid;
        _videoTimestamp = kCMTimeInvalid;
        
        // ensure authorization is permitted, if not already prompted
        // it's possible to capture video without audio or audio without video
//        if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
//            
//            AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
//            
//            if (audioAuthorizationStatus == AVAuthorizationStatusNotDetermined || audioAuthorizationStatus == AVAuthorizationStatusDenied) {
//                if (audioAuthorizationStatus == AVAuthorizationStatusDenied && [_delegate respondsToSelector:@selector(mediaWriterDidObserveAudioAuthorizationStatusDenied:)]) {
//                    [_delegate mediaWriterDidObserveAudioAuthorizationStatusDenied:self];
//                }
//            }
//            
//            AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//            
//            if (videoAuthorizationStatus == AVAuthorizationStatusNotDetermined || videoAuthorizationStatus == AVAuthorizationStatusDenied) {
//                if (videoAuthorizationStatus == AVAuthorizationStatusDenied && [_delegate respondsToSelector:@selector(mediaWriterDidObserveVideoAuthorizationStatusDenied:)]) {
//                    [_delegate mediaWriterDidObserveVideoAuthorizationStatusDenied:self];
//                }
//            }
//            
//        }
        
        NSLog(@"prepared to write to (%@)", outputURL);
    }
    return self;
}

#pragma mark - private

- (NSArray *)_metadataArray
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    // device model
    AVMutableMetadataItem *modelItem = [[AVMutableMetadataItem alloc] init];
    [modelItem setKeySpace:AVMetadataKeySpaceCommon];
    [modelItem setKey:AVMetadataCommonKeyModel];
    [modelItem setValue:[currentDevice localizedModel]];
    
    // software
    AVMutableMetadataItem *softwareItem = [[AVMutableMetadataItem alloc] init];
    [softwareItem setKeySpace:AVMetadataKeySpaceCommon];
    [softwareItem setKey:AVMetadataCommonKeySoftware];
    [softwareItem setValue:@"TXVideo"];
    
    // creation date
    AVMutableMetadataItem *creationDateItem = [[AVMutableMetadataItem alloc] init];
    [creationDateItem setKeySpace:AVMetadataKeySpaceCommon];
    [creationDateItem setKey:AVMetadataCommonKeyCreationDate];
    [creationDateItem setValue:[self TXformattedTimestampStringFromDate:[NSDate date]]];
    
    return @[modelItem, softwareItem, creationDateItem];
}

- (NSString *)TXformattedTimestampStringFromDate:(NSDate *)date
{
    if (!date)
        return nil;
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [dateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
    });
    
    return [dateFormatter stringFromDate:date];
}

#pragma mark - setup

- (BOOL)setupAudioWithSettings:(NSDictionary *)audioSettings
{
    if (!_assetWriterAudioInput && [_assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio]) {
        NSLog(@"初始化audioinput");
        _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
        _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
        
        if (_assetWriterAudioInput && [_assetWriter canAddInput:_assetWriterAudioInput]) {
            [_assetWriter addInput:_assetWriterAudioInput];
            
            NSLog(@"setup audio input with settings sampleRate (%f) channels (%lu) bitRate (%ld)",
                 [[audioSettings objectForKey:AVSampleRateKey] floatValue],
                 (unsigned long)[[audioSettings objectForKey:AVNumberOfChannelsKey] unsignedIntegerValue],
                 (long)[[audioSettings objectForKey:AVEncoderBitRateKey] integerValue]);
            
        } else {
            NSLog(@"couldn't add asset writer audio input");
        }
        
    } else {
        
        _assetWriterAudioInput = nil;
        NSLog(@"couldn't apply audio output settings");
        
    }
    
    return self.isAudioReady;
}

- (BOOL)setupVideoWithSettings:(NSDictionary *)videoSettings withAdditional:(NSDictionary *)additional {
    if (!_assetWriterVideoInput && [_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
        NSLog(@"初始化videoinput");
        _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
        _assetWriterVideoInput.transform = CGAffineTransformIdentity;
        
        if (_assetWriterVideoInput && [_assetWriter canAddInput:_assetWriterVideoInput]) {
            [_assetWriter addInput:_assetWriterVideoInput];
            
#if !defined(NDEBUG) && LOG_WRITER
            NSDictionary *videoCompressionProperties = videoSettings[AVVideoCompressionPropertiesKey];
            if (videoCompressionProperties) {
                NSLog(@"setup video with compression settings bps (%f) frameInterval (%ld)",
                     [videoCompressionProperties[AVVideoAverageBitRateKey] floatValue],
                     (long)[videoCompressionProperties[AVVideoMaxKeyFrameIntervalKey] integerValue]);
            } else {
                NSLog(@"setup video");
            }
#endif
            
        } else {
            NSLog(@"couldn't add asset writer video input");
        }
        
    } else {
        
        _assetWriterVideoInput = nil;
        NSLog(@"couldn't apply video output settings");
        
    }
    
    return self.isVideoReady;
}
//准备录制
- (NSError *)prepareToRecordVideo
{
    // setup the writer
    NSError *error = nil;
    BOOL success = [_assetWriter startWriting];
    if (!success) {
        error = _assetWriter.error;
        return error;
    }
    return nil;
//    if ( _assetWriter.status == AVAssetWriterStatusUnknown ) {
//        
//        if ([_assetWriter startWriting]) {
//            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//            [_assetWriter startSessionAtSourceTime:timestamp];
//            NSLog(@"started writing with status (%ld)", (long)_assetWriter.status);
//        } else {
//            NSLog(@"error when starting to write (%@)", [_assetWriter error]);
//            return;
//        }
//    }
}
#pragma mark - sample buffer writing

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer withMediaTypeVideo:(BOOL)video
{
    if (!CMSampleBufferDataIsReady(sampleBuffer)) {
        return;
    }
    
    // setup the writer
//    if ( _assetWriter.status == AVAssetWriterStatusUnknown ) {
//        
//        if ([_assetWriter startWriting]) {
//            CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//            [_assetWriter startSessionAtSourceTime:timestamp];
//            NSLog(@"started writing with status (%ld)", (long)_assetWriter.status);
//        } else {
//            NSLog(@"error when starting to write (%@)", [_assetWriter error]);
//            return;
//        }
//        
//    }
    
    // check for completion state
    if ( _assetWriter.status == AVAssetWriterStatusFailed ) {
        NSLog(@"writer failure, (%@)", _assetWriter.error.localizedDescription);
        return;
    }
    
    if (_assetWriter.status == AVAssetWriterStatusCancelled) {
        NSLog(@"writer cancelled");
        return;
    }
    
    if ( _assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"writer finished and completed");
        return;
    }
    
    // perform write
    if ( _assetWriter.status == AVAssetWriterStatusWriting ) {
//        CFRetain(sampleBuffer);

        if(!_haveStartedSession && video) {
            [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
            _haveStartedSession = YES;
        }
        
        CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        if (duration.value > 0) {
            timestamp = CMTimeAdd(timestamp, duration);
        }
        
        if (video) {
            if (_assetWriterVideoInput.readyForMoreMediaData) {
                if ([_assetWriterVideoInput appendSampleBuffer:sampleBuffer]) {
                    _videoTimestamp = timestamp;
                } else {
                    NSLog(@"writer error appending video (%@)", _assetWriter.error);
                }
            }
        } else {
            if (_assetWriterAudioInput.readyForMoreMediaData) {
                if ([_assetWriterAudioInput appendSampleBuffer:sampleBuffer]) {
                    _audioTimestamp = timestamp;
                } else {
                    NSLog(@"writer error appending audio (%@)", _assetWriter.error);
                }
            }
        }
//        CFRetain(sampleBuffer);
        
    }
}

- (void)finishWritingWithCompletionHandler:(void (^)(void))handler
{
    if (_assetWriter.status == AVAssetWriterStatusUnknown ||
        _assetWriter.status == AVAssetWriterStatusCompleted) {
        NSLog(@"asset writer was in an unexpected state (%@)", @(_assetWriter.status));
        return;
    }
//    [_assetWriterVideoInput markAsFinished];
//    [_assetWriterAudioInput markAsFinished];
    [_assetWriter finishWritingWithCompletionHandler:handler];
}



@end
