//
//  TXMessageZoomViewController.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/17.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXMessageZoomViewController : UIViewController

@property (nonatomic,copy) NSString *displayString;

- (instancetype)initWithDisplayMessage:(NSString *)msg;

@end
