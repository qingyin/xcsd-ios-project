//
//  VideoRecordProgressView.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/9/23.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "VideoRecordProgressView.h"

@interface VideoRecordProgressView()
{
    CAShapeLayer *_backgroundLayer;
    CAShapeLayer *_circleLayer;
    UILabel *_tipLabel;
}
@property (nonatomic) BOOL isAnimating;

@end

@implementation VideoRecordProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
        [self setupCircleView];
    }
    return self;
}
- (void)commonInit
{
    self.curveColor = RGBCOLOR(0xfc, 0xa0, 0x29);
    self.backgroundCircleColor = RGBCOLOR(48, 48, 48);
    self.curveWidth = 3.f;
    self.backgroundCircleWidth = 1.f;
    self.radius = CGRectGetWidth(self.bounds) * 0.5;
    self.duration = 15.0;
    _tipString = @"按住拍摄";
}
- (void)setupCircleView
{
    CGPoint arcCenter = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:_radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.path = circlePath.CGPath;
    _backgroundLayer.lineCap = kCALineCapRound;
    _backgroundLayer.strokeColor = _backgroundCircleColor.CGColor;
    _backgroundLayer.fillColor = nil;
    _backgroundLayer.lineWidth = _backgroundCircleWidth;
    [self.layer addSublayer:_backgroundLayer];
    //添加提示文字
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.font = [UIFont systemFontOfSize:22];
    _tipLabel.textColor = self.curveColor;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.text = _tipString;
    [self addSubview:_tipLabel];
}
- (void)setTipString:(NSString *)tipString
{
    _tipString = tipString;
    _tipLabel.text = _tipString;
}
- (void)addMovingCircleView
{
    CGPoint arcCenter = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds) * 0.5);
    UIBezierPath *curvePath = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:_radius startAngle:- M_PI_2 endAngle:M_PI_2 * 3 clockwise:YES];
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.path = curvePath.CGPath;
    _circleLayer.lineCap = kCALineCapRound;
    _circleLayer.strokeColor = _curveColor.CGColor;
    _circleLayer.fillColor = nil;
    _circleLayer.lineWidth = _curveWidth;
    _circleLayer.strokeStart = 0.f;
    _circleLayer.strokeEnd = 0.f;
    [self.layer addSublayer:_circleLayer];
    
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = _duration;
    strokeEndAnimation.fromValue = @(0);
    strokeEndAnimation.toValue = @(1);
    strokeEndAnimation.beginTime = CACurrentMediaTime();
    strokeEndAnimation.autoreverses = NO;
    strokeEndAnimation.repeatCount = 0.f;
    strokeEndAnimation.fillMode = kCAFillModeForwards;
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.delegate = self;

    [_circleLayer addAnimation:strokeEndAnimation forKey:@"circleAnimation"];
}

- (void)removeMovingCircleView
{
    [_circleLayer removeAllAnimations];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        if (_delegate && [_delegate respondsToSelector:@selector(progressAnimationDidFinsihed:)]) {
            [_delegate progressAnimationDidFinsihed:self];
        }
    }
}
#pragma mark - Public Methods
- (void)resetProgressView
{
    if (_circleLayer) {
        [_circleLayer removeAllAnimations];
        [_circleLayer removeFromSuperlayer];
        _circleLayer = nil;
    }
}
- (void)startAnimating
{
    if (!_isAnimating) {
        self.isAnimating = YES;
        [self addMovingCircleView];
    }
}
- (void)stopAnimating
{
    if (_isAnimating) {
        self.isAnimating = NO;
        [self removeMovingCircleView];
    }
}

@end
