//
//  MJRefreshGifHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/4/24.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "MJTXRefreshGifHeader.h"
#import <FLAnimatedImage.h>

@interface MJTXRefreshGifHeader()
@property (weak, nonatomic) FLAnimatedImageView *gifView;
@property (weak, nonatomic) UIImageView *pullView;
@property (weak, nonatomic) UIImageView *pullBackgroundView;
@property(nonatomic,strong)CAShapeLayer * verticalLineLayer;
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation MJTXRefreshGifHeader
#pragma mark - 懒加载
- (FLAnimatedImageView *)gifView
{
    if (!_gifView) { 
        FLAnimatedImageView *gifView = [[FLAnimatedImageView alloc] init];
        [self addSubview:_gifView = gifView];
    } 
    return _gifView; 
}
- (UIImageView *)pullView
{
    if (!_pullView) {
        UIImageView *pullView = [[UIImageView alloc] init];
        [self addSubview:_pullView = pullView];
    }
    return _pullView;
}


- (UIImageView *)pullBackgroundView
{
    if (!_pullBackgroundView) {
        UIImageView *pullBackgroundView = [[UIImageView alloc] init];
        pullBackgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_pullBackgroundView = pullBackgroundView];
    }
    return _pullBackgroundView;
}

- (NSMutableDictionary *)stateImages 
{ 
    if (!_stateImages) { 
        self.stateImages = [NSMutableDictionary dictionary]; 
    } 
    return _stateImages; 
}

- (NSMutableDictionary *)stateDurations 
{ 
    if (!_stateDurations) { 
        self.stateDurations = [NSMutableDictionary dictionary]; 
    } 
    return _stateDurations; 
}

- (CAShapeLayer *) verticalLineLayer {
    if(!_verticalLineLayer)
    {
        CAShapeLayer *verticalLineLayer = [CAShapeLayer layer];
        verticalLineLayer.strokeColor = kColorBackground.CGColor;
        verticalLineLayer.lineWidth = 1.0;
        verticalLineLayer.fillColor = kColorBackground.CGColor;
        [self.pullBackgroundView.layer addSublayer:verticalLineLayer];
        _verticalLineLayer = verticalLineLayer;
    }
    return _verticalLineLayer;
}

- (CGPathRef) getLeftLinePathWithAmount:(CGFloat)amount {
    UIBezierPath *verticalLine = [UIBezierPath bezierPath];
    CGPoint topPoint = CGPointMake(0, 0);
    
    CGFloat width = kScreenWidth;
    if(self.bounds.size.width != 0)
    {
        width = self.bounds.size.width;
    }
    CGPoint midControlPoint = CGPointMake(width/2, amount);
    CGPoint bottomPoint = CGPointMake(width, 0);
    verticalLine.lineCapStyle = kCGLineCapRound; //线条拐角
    verticalLine.lineJoinStyle = kCGLineCapRound; //终点处理
    [verticalLine moveToPoint:topPoint];
    [verticalLine addQuadCurveToPoint:bottomPoint controlPoint:midControlPoint];
    [verticalLine closePath];
    
    return [verticalLine CGPath];
}

#pragma mark - 公共方法

-(void)setImage:(NSString *)imagePath  forState:(MJRefreshState)state
{
    if (imagePath == nil) return;

    self.stateImages[@(state)] = imagePath;
//    UIImage *imageForSize = [UIImage imageNamed:imagePath];
    /* 根据图片设置控件的高度 */
//    if (imageForSize.size.height > self.mj_h) {
//        self.mj_h = imageForSize.size.height;
//    }
}

-(void)setBackgroundImage:(UIImage *)image
{
    if(image)
    {
        [self.pullBackgroundView setImage:image];
//        self.mj_h = image.size.height;
    }
}

//修改填充颜色
-(void)updateFillerColor:(UIColor *)fillerColor
{
    if(!fillerColor)
    {
        return;
    }
    self.verticalLineLayer.strokeColor = fillerColor.CGColor;
    self.verticalLineLayer.fillColor = fillerColor.CGColor;
}


//创建 自动的下拉控件
+(MJTXRefreshGifHeader *)createGifRefreshHeader:(MJRefreshComponentRefreshingBlock)refreshingBlock
{
    MJTXRefreshGifHeader *gifHeader = [MJTXRefreshGifHeader headerWithRefreshingBlock:refreshingBlock];
    NSString *gifImagePath = [[NSBundle mainBundle] pathForResource:@"mfresh_pull" ofType:@"gif"];
    [gifHeader setImage:gifImagePath forState:MJRefreshStateRefreshing];
//    [gifHeader setBackgroundImage:[UIImage imageNamed:@"circle_freshBG"]];
    NSString *ImagePath = [[NSBundle mainBundle] pathForResource:@"circle_pullStop" ofType:@"png"];
    [gifHeader setImage:ImagePath forState:MJRefreshStatePulling];
    [gifHeader placeSubviews];
    return gifHeader;
}


#pragma mark - 实现父类的方法
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    CGSize backGroundSize = self.pullBackgroundView.image?self.pullBackgroundView.image.size:self.bounds.size;
    CGFloat hight = (pullingPercent)*self.bounds.size.height;
    CGFloat hight1 = hight>backGroundSize.height?backGroundSize.height:hight;
//    self.verticalLineLayer.path = [self getLeftLinePathWithAmount:hight1*2];
    CGSize viewSize = [FLAnimatedImage sizeForImage:self.gifView.animatedImage];
    viewSize =(viewSize.height==0||viewSize.width == 0)?CGSizeMake(60, 60):CGSizeMake(viewSize.width/2, viewSize.height/2);
    
//    DLog(@"size:%@ gifView:%@, pullView:%@ state:%@ pullingPercent:%@", NSStringFromCGSize(viewSize), @(self.gifView.isHidden), @(self.pullView.isHidden), @(self.state), @(pullingPercent));
    CGFloat originalY =self.bounds.size.height-backGroundSize.height;
    CGFloat width = kScreenWidth;
    if(self.bounds.size.width != 0)
    {
        width = self.bounds.size.width;
    }
    //self.gifView.frame = CGRectMake(width/2-viewSize.width/2-10,originalY+ hight1-viewSize.height, viewSize.width, viewSize.height);
    self.gifView.frame = CGRectMake(width/2-viewSize.width/2,originalY+ hight1-viewSize.height, viewSize.width, viewSize.height);
    
    CGFloat pullWidth = viewSize.width*(pullingPercent>1?1:pullingPercent);
    CGFloat pullHight = viewSize.height*(pullingPercent>1?1:pullingPercent);
    self.pullView.frame = CGRectMake(width/2-pullWidth/2,originalY+ hight1-pullHight,pullWidth , pullHight);
//    NSLog(@"gifView:%@ pullView:%@", NSStringFromCGRect(self.gifView.frame), NSStringFromCGRect(self.pullView.frame));
    if(!self.pullView.isHidden && !self.pullView.image)
    {
        [self updatePullViewImage];
    }
    
    [self bringSubviewToFront:self.gifView];
    [self bringSubviewToFront:self.pullView];
    [self layoutIfNeeded];

}

-(void)updatePullViewImage
{
    NSString  *imagePath = self.stateImages[@(MJRefreshStatePulling)];
    NSURL *url = [NSURL fileURLWithPath:imagePath];
    if(url)
    {
        self.pullView.image = [UIImage imageNamed:imagePath];
    }
}

- (void)placeSubviews
{
    [super placeSubviews];
    CGFloat width = kScreenWidth;
    if(self.bounds.size.width != 0)
    {
        width = self.bounds.size.width;
    }
    CGSize backGroundSize = self.pullBackgroundView.image?self.pullBackgroundView.image.size:self.bounds.size;
    self.pullBackgroundView.frame = CGRectMake(0, self.bounds.size.height-backGroundSize.height, width, backGroundSize.height);
    self.stateLabel.hidden = YES;
    self.lastUpdatedTimeLabel.hidden = YES;
    self.gifView.contentMode = UIViewContentModeScaleAspectFit;
    self.pullView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)prepare
{
    [super prepare];
    self.mj_h = 74.0f;
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
//    NSLog(@"state:%@", @(state));
    
    
    // 根据状态做事情
    if (state == MJRefreshStateRefreshing) {
        NSString  *imagePath = self.stateImages[@(state)];
        
        NSURL *url = [NSURL fileURLWithPath:imagePath];
        if(url)
        {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
        // 设置当前需要显示的图片
            self.gifView.animatedImage =image;
            self.gifView.hidden = NO;
            self.pullView.hidden = YES;
        }
    }
    else if (state == MJRefreshStatePulling ) {
        NSString  *imagePath = self.stateImages[@(state)];
        
        NSURL *url = [NSURL fileURLWithPath:imagePath];
        if(url)
        {
            self.pullView.hidden = NO;
            self.gifView.hidden = YES;
            self.pullView.image = [UIImage imageNamed:imagePath];
        }
    }
    else if(state == MJRefreshStateWillRefresh)
    {
        NSString  *imagePath = self.stateImages[@(MJRefreshStateRefreshing)];
        
        NSURL *url = [NSURL fileURLWithPath:imagePath];
        if(url)
        {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:url]];
            // 设置当前需要显示的图片
            self.gifView.animatedImage =image;
            self.gifView.hidden = NO;
            self.pullView.hidden = YES;
        }
    }
    else
    {
        self.pullView.hidden = NO;
        self.pullView.frame = CGRectZero;
        self.gifView.hidden = YES;
    }
        
//    DLog(@"gifView:%@, pullView:%@",  @(self.gifView.isHidden), @(self.pullView.isHidden));
//    DLog(@"gifView:%@ pullview:%@", NSStringFromCGRect(self.gifView.frame), NSStringFromCGRect(self.pullView.frame));
}

- (void)beginRefreshing
{
    self.state = MJRefreshStatePulling;
    [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    // 只要正在刷新，就完全显示
    if (self.window) {
        self.state = MJRefreshStateRefreshing;
    } else {
        self.state = MJRefreshStateWillRefresh;
        // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
        [self setNeedsDisplay];
    }
}

@end
