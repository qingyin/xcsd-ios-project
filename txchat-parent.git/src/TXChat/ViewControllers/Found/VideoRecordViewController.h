//
//  VideoRecordViewController.h
//  TXChat
//
//  Created by 陈爱彬 on 15/9/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, TXVideoRecordVCShowType) {
    TXVideoRecordVCShowType_Push = 0,          //Push
    TXVideoRecordVCShowType_Present,           //弹出
};

@protocol TXVideoRecordViewControllerDelegate <NSObject>

- (void)recordFinishedWithVideoURL:(NSURL *)url;

@end

@interface VideoRecordViewController : BaseViewController

@property (nonatomic,weak) id<TXVideoRecordViewControllerDelegate> delegate;
@property (nonatomic) TXVideoRecordVCShowType showType;
@property (nonatomic,weak) UIViewController *backVc;

@end
