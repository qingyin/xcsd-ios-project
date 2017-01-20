//
//  CircleDetailViewController.h
//  TXChat
//
//  Created by Cloud on 15/7/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@class CircleHomeViewController;

@interface CircleDetailViewController : BaseViewController

@property (nonatomic, strong) TXFeed *feed;
@property (nonatomic, assign) BaseViewController *presentVC;


- (void)onFeedLikeResponse:(TXFeed *)feed andIsLike:(BOOL)isLike;
//播放视频
- (void)playVideoWithURLString:(NSString *)urlString
       thumbnailImageURLString:(NSString *)imageUrlString;

@end
