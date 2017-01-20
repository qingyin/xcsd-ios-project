//
//  CHProgressImgeView.m
//  ChildHoodStemp
//
//  Created by Cloud on 14/12/29.
//
//

#import "CHProgressImgeView.h"



@implementation CHProgressImgeView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.progressLb = [[UILabel alloc] init];
        _progressLb.frame = CGRectMake(0, 0, 40, 20);
        _progressLb.font = [UIFont systemFontOfSize:12];
        _progressLb.textAlignment = NSTextAlignmentCenter;
        _progressLb.textColor = [UIColor whiteColor];
        _progressLb.center = self.center;
        _progressLb.text = @"0%";
        _progressLb.textColor = [UIColor whiteColor];
        _progressLb.backgroundColor = [UIColor clearColor];
        _progressLb.layer.backgroundColor = [UIColor colorWithHue:.48 saturation:.45 brightness:.45 alpha:.6].CGColor;
        _progressLb.layer.cornerRadius = 5.0f;
        _progressLb.hidden = YES;
        [self addSubview:_progressLb];
    }
    return self;
}

- (void)setProgress:(float)num{
    if (num < 1) {
        float progress = num * 100;
        if (progress <= 0) {
            progress = 0;
        }
        _progressLb.text = [NSString stringWithFormat:@"%.0f%%",progress];
        _progressLb.hidden = NO;
        [self bringSubviewToFront:_progressLb];
    }else{
        _progressLb.hidden = YES;
    }
}

@end
