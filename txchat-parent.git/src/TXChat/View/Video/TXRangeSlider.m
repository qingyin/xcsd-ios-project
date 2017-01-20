//
//  TXRangeSlider.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/6/22.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXRangeSlider.h"

@interface TXRangeSlider()
{
    CGFloat _lowerTouchOffset;
    CGFloat _upperTouchOffset;
}
@property (strong, nonatomic) UIImageView* lowerHandle;
@property (strong, nonatomic) UIImageView* upperHandle;

@end

@implementation TXRangeSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _minimumRange = 0.0;
    
    _lowerValue = _minimumValue;
    _upperValue = _maximumValue;
    
    _lowerMaximumValue = NAN;
    _upperMinimumValue = NAN;
    
    _lowerTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    _upperTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    
}
#pragma mark - Public
- (void)setup
{
    self.lowerHandle = [[UIImageView alloc] initWithImage:self.lowerHandleImage];
    self.lowerHandle.backgroundColor = [UIColor clearColor];
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImage];
    
    self.upperHandle = [[UIImageView alloc] initWithImage:self.upperHandleImage];
    self.upperHandle.backgroundColor = [UIColor clearColor];
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImage];
    
    [self addSubview:self.lowerHandle];
    [self addSubview:self.upperHandle];
}
- (CGFloat)value
{
    CGFloat sliderValue = 0.f;
    if (self.lowerHandle.highlighted) {
        sliderValue = _lowerValue;
    }else if (self.upperHandle.highlighted) {
        sliderValue = _upperValue;
    }
    if (sliderValue >= 1.f) {
        sliderValue = 1.f;
    }
    return sliderValue;
}
#pragma mark - Value Update methods
- (void)setLowerValue:(CGFloat)lowerValue
{
    CGFloat value = lowerValue;
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _minimumValue);
    
    if (!isnan(_lowerMaximumValue)) {
        value = MIN(value, _lowerMaximumValue);
    }
    
    value = MIN(value, _upperValue - _minimumRange);
    
    _lowerValue = value;
    
    [self setNeedsLayout];
}

- (void)setUpperValue:(CGFloat)upperValue
{
    CGFloat value = upperValue;
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _maximumValue);
    
    if (!isnan(_upperMinimumValue)) {
        value = MAX(value, _upperMinimumValue);
    }
    
    value = MAX(value, _lowerValue+_minimumRange);
    
    _upperValue = value;
    
    [self setNeedsLayout];
}


- (void)setLowerValue:(CGFloat) lowerValue upperValue:(CGFloat) upperValue animated:(BOOL)animated
{
    if((!animated) && (isnan(lowerValue) || lowerValue==_lowerValue) && (isnan(upperValue) || upperValue==_upperValue))
    {
        //nothing to set
        return;
    }
    
    __block void (^setValuesBlock)(void) = ^ {
        
        if(!isnan(lowerValue))
        {
            [self setLowerValue:lowerValue];
        }
        if(!isnan(upperValue))
        {
            [self setUpperValue:upperValue];
        }
        
    };
    
    if(animated)
    {
        [UIView animateWithDuration:0.25  delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             setValuesBlock();
                             [self layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
    }
    else
    {
        setValuesBlock();
    }
    
}
- (void)setLowerValue:(CGFloat)lowerValue animated:(BOOL) animated
{
    [self setLowerValue:lowerValue upperValue:NAN animated:animated];
}
- (void)setUpperValue:(CGFloat)upperValue animated:(BOOL) animated
{
    [self setLowerValue:NAN upperValue:upperValue animated:animated];
}
#pragma mark - View methods
-(void)layoutSubviews
{
    [super layoutSubviews];
    //重新计算位置
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImage];
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImage];
}
#pragma mark - Helper methods
- (CGRect)thumbRectForValue:(CGFloat)value image:(UIImage*) thumbImage
{
    CGRect thumbRect;
    UIEdgeInsets insets = thumbImage.capInsets;
    thumbRect.size = CGSizeMake(thumbImage.size.width, thumbImage.size.height);
    if(insets.top || insets.bottom)
    {
        thumbRect.size.height = self.bounds.size.height;
    }
    CGFloat xValue = ((self.bounds.size.width-thumbRect.size.width)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
    thumbRect.origin = CGPointMake(xValue, (self.bounds.size.height/2.0f) - (thumbRect.size.height/2.0f));
    return CGRectIntegral(thumbRect);
}
- (CGFloat)lowerValueForCenterX:(CGFloat)x
{
    CGFloat _padding = _lowerHandle.frame.size.width / 2.0f;
    CGFloat value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    return value;
}
- (CGFloat)upperValueForCenterX:(CGFloat)x
{
    CGFloat _padding = _upperHandle.frame.size.width/2.0;
    
    CGFloat value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    return value;
}
#pragma mark - Touch handling
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(UIEdgeInsetsInsetRect(_lowerHandle.frame, self.lowerTouchEdgeInsets), touchPoint))
    {
        _lowerHandle.highlighted = YES;
        _lowerTouchOffset = touchPoint.x - _lowerHandle.center.x;
    }
    
    if(CGRectContainsPoint(UIEdgeInsetsInsetRect(_upperHandle.frame, self.upperTouchEdgeInsets), touchPoint))
    {
        _upperHandle.highlighted = YES;
        _upperTouchOffset = touchPoint.x - _upperHandle.center.x;
    }
    
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_lowerHandle.highlighted && !_upperHandle.highlighted ){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    
    if(_lowerHandle.highlighted)
    {
        CGFloat newValue = [self lowerValueForCenterX:(touchPoint.x - _lowerTouchOffset)];
        
        //if both upper and lower is selected, then the new value must be LOWER
        //otherwise the touch event is ignored.
        if(!_upperHandle.highlighted || newValue<_lowerValue)
        {
            _upperHandle.highlighted=NO;
            [self bringSubviewToFront:_lowerHandle];
            
            [self setLowerValue:newValue animated:NO];
        }
        else
        {
            _lowerHandle.highlighted=NO;
        }
    }
    
    if(_upperHandle.highlighted )
    {
        CGFloat newValue = [self upperValueForCenterX:(touchPoint.x - _upperTouchOffset)];
        
        //if both upper and lower is selected, then the new value must be HIGHER
        //otherwise the touch event is ignored.
        if(!_lowerHandle.highlighted || newValue>_upperValue)
        {
            _lowerHandle.highlighted=NO;
            [self bringSubviewToFront:_upperHandle];
            [self setUpperValue:newValue animated:NO];
        }
        else
        {
            _upperHandle.highlighted=NO;
        }
    }
    
    
    //send the control event
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    
    //redraw
    [self setNeedsLayout];
    
    return YES;
}



-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerHandle.highlighted = NO;
    _upperHandle.highlighted = NO;
    
//    [self sendActionsForControlEvents:UIControlEventValueChanged];
}
@end
