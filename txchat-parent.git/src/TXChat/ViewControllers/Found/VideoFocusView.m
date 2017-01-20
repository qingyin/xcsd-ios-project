//
//  VideoFocusView.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/9.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "VideoFocusView.h"

@interface VideoFocusView()
{
    UIImageView *_focusRingView;
}
@end

@implementation VideoFocusView

#pragma mark - init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
        _focusRingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"capture_focus"]];
        [self addSubview:_focusRingView];
        
        self.frame = _focusRingView.frame;
    }
    return self;
}

- (void)dealloc
{
    [self.layer removeAllAnimations];
}

#pragma mark -

- (void)startAnimation
{
    [self.layer removeAllAnimations];
    
    self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.alpha = 0;
    
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
        
    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:10.f animations:^{
//            self.alpha = 1.f;
//        } completion:^(BOOL finished) {
//            [self stopAnimation];
//        }];
//        [UIView animateWithDuration:5.f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
////            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
////            self.alpha = 1;
//        } completion:^(BOOL finished1) {
//            [self stopAnimation];
//        }];
    }];
}

- (void)stopAnimation
{
    [self.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
//        self.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
    }];
}


@end
