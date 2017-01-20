//
//  TXMediaItem.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/19.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TXChatCommon/AUMediaPlayer.h>

@interface TXMediaItem : NSObject <AUMediaItem>

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *coverUrl;

@property (nonatomic, strong) NSString *remotePath;

@property (nonatomic, strong) NSString *fileTypeExtension;

@property (nonatomic, copy) NSString *ablumId;

@property (nonatomic, copy) NSString *timeString;

@property (nonatomic) NSInteger episodes;
@property (nonatomic) SInt32 viewedCount;
@property (nonatomic) SInt32 likedCount;
@property (nonatomic, strong) TXPBResource *resource;

@end

@interface TXMediaAudioItem : TXMediaItem
@end

@interface TXMediaVideoItem : TXMediaItem
@end


@interface TXMediaCollection :NSObject <AUMediaItemCollection>

@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *mediaItems;

@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *playCount;
@property (nonatomic, strong) TXPBAlbum *albumInfo;

@end
