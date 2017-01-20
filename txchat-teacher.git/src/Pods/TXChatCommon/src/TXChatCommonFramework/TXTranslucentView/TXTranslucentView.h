//
//  TXTranslucentView.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/12/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  用法如下
    _blurBarView = [[TXTranslucentView alloc] initWithFrame:CGRectMake(0, 0, self.view.width_, 100)];
    _blurBarView.translucentAlpha = 1;
    _blurBarView.translucentStyle = UIBarStyleDefault;
    _blurBarView.translucentTintColor = [UIColor clearColor];
    _blurBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_blurBarView];

 */
@interface TXTranslucentView : UIView

@property (nonatomic) BOOL translucent;
@property (nonatomic) CGFloat translucentAlpha;
@property (nonatomic) UIBarStyle translucentStyle;
@property (nonatomic, strong) UIColor *translucentTintColor;

@end
