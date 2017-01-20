//
//  MJTXRefreshNormalHeader.m
//  TXChat
//
//  Created by lyt on 15/8/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#define KTitlesToBottom 25.0f

#import "MJTXRefreshNormalHeader.h"
@interface MJTXRefreshNormalHeader()
{
    __weak UIImageView *_arrowView;
}
@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@end

@implementation MJTXRefreshNormalHeader
#pragma mark - 懒加载子控件
- (UIImageView *)arrowView
{
    if (!_arrowView) {
        UIImage *image = [UIImage imageNamed:@"pull_down_icon"];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_arrowView = arrowView];
    }
    return _arrowView;
}

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorViewStyle];
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

#pragma mark - 公共方法
- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    self.loadingView = nil;
    [self setNeedsLayout];
}

#pragma makr - 重写父类的方法
- (void)prepare
{
    [super prepare];
    // 初始化文字
//    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
//    [self setTitle:@"下拉刷新" forState:MJRefreshStatePulling];
//    [self setTitle:@"下拉刷新" forState:MJRefreshStateRefreshing];
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
}

- (void)placeSubviews
{
    [super placeSubviews];
    // 箭头
    self.arrowView.mj_size = self.arrowView.image.size;
    CGFloat arrowCenterX = self.mj_w * 0.5;
    if (!self.stateLabel.hidden) {
        arrowCenterX -= 50;
    }
    CGFloat arrowCenterY =  self.mj_h -KTitlesToBottom;
    self.arrowView.center = CGPointMake(arrowCenterX, arrowCenterY);
    
    // 圈圈
    self.loadingView.frame = self.arrowView.frame;
    
    self.stateLabel.mj_x = self.mj_w*0.5-35;
    self.stateLabel.mj_y =  self.mj_h -KTitlesToBottom - KTitlesToBottom/2;
    self.stateLabel.mj_w = self.mj_w*0.5;
    self.stateLabel.mj_h = KTitlesToBottom;
    self.stateLabel.textColor = RGBCOLOR(0x8e , 0x8e, 0x8e);
    [self.stateLabel setTextAlignment:NSTextAlignmentLeft];
    
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            self.arrowView.transform = CGAffineTransformIdentity;
            
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
                self.arrowView.hidden = NO;
            }];
        } else {
            [self.loadingView stopAnimating];
            self.arrowView.hidden = NO;
            [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                self.arrowView.transform = CGAffineTransformIdentity;
            }];
        }
    } else if (state == MJRefreshStatePulling) {
        [self.loadingView stopAnimating];
        self.arrowView.hidden = NO;
        [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
            self.arrowView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
        }];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
        self.arrowView.hidden = YES;
    }
}
//
- (UILabel *)lastUpdatedTimeLabel
{
    return nil;
}



@end
