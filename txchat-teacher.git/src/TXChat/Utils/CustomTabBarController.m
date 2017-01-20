//
//  CustomTabBarController.m
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CustomTabBarController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "XCSDDataProto.pb.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //禁用滑动返回
    self.fd_interactivePopDisabled = YES;
    
    if (self.bid && self.bid.length > 0) {
        
        [self reportEvent:XCSDPBEventTypeChannelIn];
        
    }
}
- (void)setNeedsStatusBarAppearanceUpdate{
    if (IOS7_OR_LATER) {
        [super setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (!IOS7_OR_LATER) {
        //ios7以前的系统禁掉动画显示，性能优化
        [super setTabBarHidden:hidden animated:NO];
    }else{
        [super setTabBarHidden:hidden animated:animated];
    }
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [super setSelectedIndex:selectedIndex];
    UIViewController *vc = [self.viewControllers objectAtIndex:selectedIndex];
    [MobClick event:@"tabcount" label:[NSString stringWithFormat:@"%@", [vc class]]];

}

- (void)dealloc {
    
    if (self.bid.length > 0) {
        [self reportEvent:XCSDPBEventTypeChannelOut];
    }
}

- (void)reportEvent:(XCSDPBEventType)eventType {
    
    NSAssert(self.bid.length > 0, @"bid为空");
    
    [[TXChatClient sharedInstance].dataReportManager reportEventBid:eventType bid:self.bid];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KDataReport object:@ {KDataReport : event}];
}

@end
