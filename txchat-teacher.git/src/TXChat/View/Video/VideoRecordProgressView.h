//
//  VideoRecordProgressView.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/23.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoRecordProgressView;
@protocol VideoRecordProgressViewDelegate <NSObject>

- (void)progressAnimationDidFinsihed:(VideoRecordProgressView *)progressView;

@end

@interface VideoRecordProgressView : UIView

@property (nonatomic,weak) id<VideoRecordProgressViewDelegate> delegate;
/**
 *  弧形的颜色
 */
@property (nonatomic,strong) UIColor *curveColor;

/**
 *  弧形的宽度，默认为3
 */
@property (nonatomic) CGFloat curveWidth;

/**
 *  底部圆环颜色
 */
@property (nonatomic,strong) UIColor *backgroundCircleColor;

/**
 *  底部圆环宽度，默认为1
 */
@property (nonatomic) CGFloat backgroundCircleWidth;

/**
 *  半径
 */
@property (nonatomic) CGFloat radius;

/**
 *  动画间隔时间,默认15秒
 */
@property (nonatomic) CGFloat duration;

//提示文字，默认是按住拍摄
@property (nonatomic,copy) NSString *tipString;

//重置视图
- (void)resetProgressView;

//开始动画
- (void)startAnimating;

//结束动画
- (void)stopAnimating;

@end
