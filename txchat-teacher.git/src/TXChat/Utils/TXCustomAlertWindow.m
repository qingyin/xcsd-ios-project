//
//  TXCustomAlertWindow.m
//  TXChat
//
//  Created by 陈爱彬 on 15/7/14.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXCustomAlertWindow.h"

@implementation TXCustomAlertWindow

+ (TXCustomAlertWindow *)sharedWindow
{
    static TXCustomAlertWindow *_sharedWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWindow = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return _sharedWindow;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelNormal + 10;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)showWithView:(UIView *)view
{
    [self makeKeyWindow];
    self.hidden = NO;
    //添加view
    [self addSubview:view];
}
- (void)hide
{
    [self resignKeyWindow];
    self.hidden = YES;
}
@end
