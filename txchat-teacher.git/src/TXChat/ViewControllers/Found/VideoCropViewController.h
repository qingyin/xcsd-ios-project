//
//  VideoCropViewController.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/6/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^TXVideoCropFinishBlock)(NSURL *videoURL,NSDate *videoDate);

@interface VideoCropViewController : BaseViewController

@property (nonatomic,copy) TXVideoCropFinishBlock finishBlock;
@property (nonatomic,strong) NSDate *videoDate;

- (instancetype)initWithVideoURL:(NSURL *)videoURL;

@end
