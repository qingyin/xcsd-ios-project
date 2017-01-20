//
//  BroadcastInfoViewController.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/3/10.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "TXMediaPlayerView.h"


@class BroadcastVideoItem;

@interface BroadcastInfoViewController : BaseViewController

@property (nonatomic,strong) TXMediaPlayerView *videoView;

@property (nonatomic,strong) NSMutableArray *resourceList;
@property (nonatomic,strong) NSMutableArray *assessList;
@property (nonatomic,strong) TXPBCourse *course;
@property (nonatomic) NSInteger courseID;
@property (nonatomic) BOOL hasEdit;
@property (nonatomic) BOOL hasPase;
@property (nonatomic, copy) NSString *coverImgUrl;

- (void)onMediaChangeWithIndex:(NSInteger)index;
- (void)updateVideoAlbumData;
- (void)onPlayPauseButtonTapped;
//评价列表
- (void)getDateAssessWithMaxid:(NSInteger)maxID andIsUpRefresh:(BOOL)isUpRefresh;
//获取简介列表数据
- (void)getDateDescrip;


@end
