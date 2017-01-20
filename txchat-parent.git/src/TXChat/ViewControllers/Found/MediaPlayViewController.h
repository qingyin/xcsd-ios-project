//
//  MediaPlayViewController.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/19.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
#import "TXMediaItem.h"

@interface MediaPlayViewController : BaseViewController

@property (nonatomic, strong) TXMediaItem *item;
@property (nonatomic, strong) TXMediaCollection *collection;

@end
