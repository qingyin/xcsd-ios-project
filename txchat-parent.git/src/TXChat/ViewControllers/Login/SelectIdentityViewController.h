//
//  SelectIdentityViewController.h
//  TXChat
//
//  Created by Cloud on 15/7/1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectIdentityViewController : BaseViewController
@property (nonatomic, strong) TXUser *txUser;
@property (nonatomic, assign) NSInteger selected;
@property (nonatomic, assign) UIViewController *parentVC;
@property (nonatomic, assign) BOOL isEditInfo;


@end
