//
//  HomeViewController.h
//  TXChatDemo
//
//  Created by Cloud on 15/6/1.
//  Copyright (c) 2015年 IST. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeViewController : BaseViewController

- (void)setUnreadWithNum:(NSInteger)num andType:(HomeListType)type;

@end
