//
//  TXPhotoBrowserViewController.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface TXPhotoBrowserViewController : BaseViewController

@property (nonatomic, assign) id preVC;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) int totalCount;

- (instancetype)initWithFullScreen:(BOOL)isFullScreen;

- (void)showBrowserWithImages:(NSArray *)imageArray
                 currentIndex:(NSInteger)index;

@end
