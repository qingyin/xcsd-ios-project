//
//  TXMediaPlayerView.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/20.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AUMediaItem.h>
#import "TXMediaView.h"
#import <TXChatCommon/AUMediaPlayer.h>

typedef NS_ENUM(NSInteger,TXMediaPlayerViewType) {
    TXMediaPlayerViewType_Normal,                    //普通模式
    TXMediaPlayerViewType_FullscreenRight,           //全屏模式右
    TXMediaPlayerViewType_FullscreenLeft,            //全屏模式左
};

@protocol TXMediaPlayerViewDelegate <NSObject>

//返回
- (void)onMediaBackButtonTapped;
//暂停
- (void)onPlayPauseButtonTapped;
//播放器放大
- (void)onMediaZoomButtonTapped;
//播放器时间轴拖动
- (void)onMediaSliderValueChanged:(UISlider *)slider;
//上一个
- (void)onMediaPrevButtonTapped;
//下一个
- (void)onMediaNextButtonTapped;
//双击了播放器
- (void)onGestureDoubleTapHandled;
//音频图片请求成功
- (void)fetchAudioImageSuccessed:(UIImage *)image;

@end

@class TXMediaSlider;
@interface TXMediaPlayerView : UIView

@property (nonatomic,weak) id<TXMediaPlayerViewDelegate> delegate;
@property (nonatomic,assign) TXMediaPlayerViewType playType;
@property (nonatomic,readonly) TXMediaView *mediaView;
@property (nonatomic,strong) id<AUMediaItem> mediaItem;
@property (nonatomic,assign) AUMediaPlaybackStatus playStatus;
@property (nonatomic,readonly) TXMediaSlider *slider;
@property (nonatomic,readonly) UILabel *currentTimeLabel;
@property (nonatomic,readonly) UILabel *timeLabel;
@property (nonatomic,getter=isPlayable) BOOL playable;

@property (nonatomic,strong) UIView *guidV;
@property (nonatomic,strong) UILabel *lable;
@property (nonatomic) BOOL GifLable;

//更改下一曲按钮的状态
- (void)updateNextMediaButtonState:(BOOL)enabled;

//启用播放器工具栏
- (void)enablePlayToolBar:(BOOL)enabled;
//是否加载滚动lable
- (void)initView;
- (void)setTitleLabel;

@end
