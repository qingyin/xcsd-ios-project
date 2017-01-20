//
//  UIView+FirstViewcontroller.m
//  TXChat
//
//  Created by lyt on 15-7-1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "UIView+FirstViewcontroller.h"

@implementation UIView (FirstViewcontroller)
- (UIViewController *) firstViewController {
    // convenience function for casting and to "mask" the recursive function
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController {
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        return nextResponder;
    } else if ([nextResponder isKindOfClass:[UIView class]]) {
        return [nextResponder traverseResponderChainForUIViewController];
    } else {
        return nil;
    }
}

@end
