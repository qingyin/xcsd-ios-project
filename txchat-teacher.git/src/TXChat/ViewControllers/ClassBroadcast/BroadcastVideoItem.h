//
//  BroadcastVideoItem.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TXChatCommon/AUMediaPlayer.h>

@interface BroadcastVideoItem : NSObject <AUMediaItem>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *remotePath;
@property (nonatomic, assign) AUMediaType itemType;
@property (nonatomic, copy) NSString *ablumId;
@property (nonatomic, strong) TXPBResource *resource;
@property (nonatomic) NSInteger duration;

@end

@interface BroadcastVideoAlbum : NSObject <AUMediaItemCollection>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *mediaItems;

@end