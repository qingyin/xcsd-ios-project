//
//  VideoPickerViewController.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/6/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "VideoCropViewController.h"

typedef void(^TXVideoCropFinishBlock)(NSURL *videoURL,NSDate *videoDate);

@interface VideoPickerViewController : BaseViewController

@property (nonatomic,copy) TXVideoCropFinishBlock finishBlock;
@property (nonatomic,assign) BOOL isPresentType;

@end
