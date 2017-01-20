//
//  EditViewController.h
//  TXChat
//
//  Created by Cloud on 15/6/7.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface EditViewController : BaseViewController

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) id presentVC;

- (id)init;

@end
