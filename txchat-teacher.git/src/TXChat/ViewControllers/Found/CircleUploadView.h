//
//  CircleUploadView.h
//  TXChat
//
//  Created by Cloud on 15/7/6.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAProgressOverlayView.h"

@interface CircleUploadView : UIView

@property (nonatomic, strong) UIButton *uploadBtn;
@property (nonatomic, strong) DAProgressOverlayView *vProgress;
@property (nonatomic, strong) NSString *uuidKey;

@end
