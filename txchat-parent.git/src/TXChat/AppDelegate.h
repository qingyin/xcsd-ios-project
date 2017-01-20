//
//  AppDelegate.h
//  TXChat
//
//  Created by lingiqngwan on 5/17/15.
//  Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>


@class RDVTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) RDVTabBarController *viewController;
@property (nonatomic, assign) BOOL isConnected;                     //网络连通状态
@property (nonatomic, strong) NSMutableArray *circleUploadArr;      //亲子圈上传队列

- (void)createTabBarView;

- (void)createLoginView;

- (BOOL)isAutoLogin;

@end

