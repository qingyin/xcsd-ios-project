//
//  TXMediaTrackTableViewCell.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/8.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TXMediaItem;
@interface TXMediaTrackTableViewCell : UITableViewCell

@property (nonatomic,weak) TXMediaItem *item;
@property (nonatomic,weak) TXPBAlbum *album;
@property (nonatomic,weak) TXPBResource *resource;
@property (nonatomic,getter=isPlaying) BOOL playing;

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                    cellWidth:(CGFloat)cellWidth;

@end
