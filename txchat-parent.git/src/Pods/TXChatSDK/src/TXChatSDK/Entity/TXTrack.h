//
//  TXTrack.h
//  TXChatSDK
//
//  Created by lingqingwan on 10/22/15.
//  Copyright © 2015 lingiqngwan. All rights reserved.
//

#import "TXEntityBase.h"

typedef NS_ENUM(SInt32, TXTrackType) {
    TXTrackTypeAudio = 0,
    TXTrackTypeVideo = 1,
};

@interface TXTrack : TXEntityBase
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;
@property(nonatomic) TXTrackType trackType;
@property(nonatomic) int64_t duration;
@property(nonatomic) int64_t albumId;
@end
