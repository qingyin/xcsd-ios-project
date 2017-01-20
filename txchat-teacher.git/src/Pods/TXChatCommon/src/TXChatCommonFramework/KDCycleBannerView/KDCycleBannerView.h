//
//  KDCycleBannerView.h
//  KDCycleBannerViewDemo
//
//  Created by Kingiol on 14-4-11.
//  Copyright (c) 2014年 Kingiol. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDCycleBannerView;

typedef void(^CompleteBlock)(void);

@protocol KDCycleBannerViewDataource <NSObject>

@required
- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView;
- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index;
- (id)imageSourceForContent:(id)content;

@optional
- (UIImage *)placeHolderImageOfZeroBannerView;
- (UIImage *)placeHolderImageOfBannerView:(KDCycleBannerView *)bannerView atIndex:(NSUInteger)index;

@end

@protocol KDCycleBannerViewDelegate <NSObject>

@optional
- (void)cycleBannerView:(KDCycleBannerView *)bannerView didScrollToOffset:(CGPoint)offset;
- (void)cycleBannerView:(KDCycleBannerView *)bannerView didScrollToIndex:(NSUInteger)index;
- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index;

@end

@interface KDCycleBannerView : UIView

// Delegate and Datasource
@property (weak, nonatomic) IBOutlet id<KDCycleBannerViewDataource> datasource;
@property (weak, nonatomic) IBOutlet id<KDCycleBannerViewDelegate> delegate;

@property (assign, nonatomic, getter = isContinuous) BOOL continuous;   // if YES, then bannerview will show like a carousel, default is NO
@property (assign, nonatomic) NSUInteger autoPlayTimeInterval;  // if autoPlayTimeInterval more than 0, the bannerView will autoplay with autoPlayTimeInterval value space, default is 0
/**
 *  是否添加弧线,默认是NO
 */
@property (assign, nonatomic, getter = isAddCurveLine) BOOL addCurveLine;
/**
 *  底部弧线的颜色，默认是RGBCOLOR(243,243,243)
 */
@property (strong, nonatomic) UIColor *backgroundCurveColor;
/**
 *  上面弧线的颜色，默认是白色
 */
@property (strong, nonatomic) UIColor *maskCurveColor;
/**
 *  两个分割线的间隔，默认为2
 */
@property (assign, nonatomic) CGFloat curveDistance;
/**
 *  默认的pageControl小点颜色
 */
@property (strong, nonatomic) UIColor *pageIndicatorTintColor;
/**
 *  选中时的pageControl小点颜色
 */
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor;

- (void)reloadDataWithCompleteBlock:(CompleteBlock)competeBlock;
- (void)setCurrentPage:(NSInteger)currentPage animated:(BOOL)animated;

@end
