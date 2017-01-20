//
//  uploadImageView.h
//  TXChat
//
//  Created by lyt on 15-6-29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadImageStatus.h"

@protocol UploadImageDelegate <NSObject>
-(void)delItem:(NSInteger)viewTag;
@end


@interface uploadImageView : UIView

@property(nonatomic, assign)id<UploadImageDelegate> delegate;

//用图标初始化
-(id)initWithImage:(UIImage *)image isShowDelImage:(BOOL)isShowDelImage;

//设置显示图片
-(void)setImage:(UIImage *)image;

//更新view状态
-(void)updateViewStatus:(UPLOADIMAGE_STATUS_T)newStatus;

//获取当前状态
-(UPLOADIMAGE_STATUS_T)getCurrentStatus;

//更新进度 通知
-(void)updateUploadProcess:(CGFloat)process;

@end
