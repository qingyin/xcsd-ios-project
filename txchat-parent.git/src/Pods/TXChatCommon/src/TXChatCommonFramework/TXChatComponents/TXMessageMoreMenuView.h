//
//  TXMessageMoreMenuView.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TXMessageMoreMenuType) {
    TXMessageMoreMenuTypePhoto,            //照片
    TXMessageMoreMenuTypeTakePicture,      //拍摄
    TXMessageMoreMenuTypeTakeVideo,        //视频
};

@protocol TXMessageMoreMenuDelegate <NSObject>

- (void)clickMoreMenuButtonWithType:(TXMessageMoreMenuType)type;

@end

@interface TXMessageMoreMenuView : UIView

@property (nonatomic,weak) id<TXMessageMoreMenuDelegate>delegate;

@end
