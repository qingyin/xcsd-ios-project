//
//  CustomAlertView.m
//  TXChat
//
//  Created by Cloud on 15/6/9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "CustomAlertView.h"
#import "TXCustomAlertWindow.h"

@implementation CustomAlertView

- (void)show
{
    self.dialogView = [self createContainerView];
    
    self.dialogView.layer.shouldRasterize = YES;
    self.dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
#if (defined(__IPHONE_7_0))
    if (self.useMotionEffects) {
        [self applyMotionEffects];
    }
#endif
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:self.dialogView];
    
    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (self.parentView != NULL) {
        [self.parentView addSubview:self];
        
        // Attached to the top most window
    } else {
        
        // On iOS7, calculate with orientation
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
            
            UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
            switch (interfaceOrientation) {
                case UIInterfaceOrientationLandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationLandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                    break;
                    
                case UIInterfaceOrientationPortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                    break;
                    
                default:
                    break;
            }
            
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            
            // On iOS8, just place the dialog in the middle
        } else {
            
            CGSize screenSize = [self countScreenSize];
            CGSize dialogSize = [self countDialogSize];
            CGSize keyboardSize = CGSizeMake(0, 0);
            
            self.dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
            
        }
        
//        [[TXCustomAlertWindow sharedWindow] showWithView:self];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    self.dialogView.layer.opacity = 0.5f;
    self.dialogView.layer.transform = CATransform3DMakeScale(1.1f, 1.1f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         self.dialogView.layer.opacity = 1.0f;
                         self.dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
    
}

//- (void)close
//{
//    CATransform3D currentTransform = self.dialogView.layer.transform;
//    
//    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
//        CGFloat startRotation = [[self.dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
//        CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
//        
//        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
//    }
//    
//    self.dialogView.layer.opacity = 1.0f;
//    
//    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
//                     animations:^{
//                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
//                         self.dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
//                         self.dialogView.layer.opacity = 0.0f;
//                     }
//                     completion:^(BOOL finished) {
//                         for (UIView *v in [self subviews]) {
//                             [v removeFromSuperview];
//                         }
//                         [self removeFromSuperview];
//                         [[TXCustomAlertWindow sharedWindow] hide];
//                     }
//     ];
//
//}

@end
