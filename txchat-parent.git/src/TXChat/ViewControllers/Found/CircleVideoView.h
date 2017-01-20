//
//  CircleVideoView.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/8.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleVideoView : UIButton

//是否在下载中
@property (nonatomic,getter=isDownloading) BOOL downloading;
//下载进度
@property (nonatomic) CGFloat downloadProgress;

//开始下载视频
- (void)startDownloadVideo;
//下载视频已完成/失败
- (void)downloadVideoFinished;

@end
