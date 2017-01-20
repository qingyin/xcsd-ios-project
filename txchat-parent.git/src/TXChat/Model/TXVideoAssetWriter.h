//
//  TXVideoAssetWriter.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/21.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TXVideoAssetWriter : NSObject

- (instancetype)initWithOutputURL:(NSURL *)outputURL;

@property (nonatomic, readonly) NSURL *outputURL;
@property (nonatomic, readonly) NSError *error;
// configure settings before writing
@property (nonatomic, readonly, getter=isAudioReady) BOOL audioReady;
@property (nonatomic, readonly, getter=isVideoReady) BOOL videoReady;
// write methods, time durations
@property (nonatomic, readonly) CMTime audioTimestamp;
@property (nonatomic, readonly) CMTime videoTimestamp;


- (BOOL)setupAudioWithSettings:(NSDictionary *)audioSettings;
- (BOOL)setupVideoWithSettings:(NSDictionary *)videoSettings withAdditional:(NSDictionary *)additional;

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer withMediaTypeVideo:(BOOL)video;
- (void)finishWritingWithCompletionHandler:(void (^)(void))handler;

//准备录制
- (NSError *)prepareToRecordVideo;

@end
