//
//  TXVideoPreviewViewController.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/22.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface TXVideoPreviewViewController : BaseViewController

//是否必须先缓存才能播放
@property (nonatomic) BOOL mustCachedFirst;
//缩略图片地址
@property (nonatomic,copy) NSString *thumbImageURLString;
//本地地址
@property (nonatomic) BOOL isRemoteVideo;

- (instancetype)initWithVideoURLString:(NSString *)urlString;

@end
