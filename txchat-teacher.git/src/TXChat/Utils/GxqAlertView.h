//
//  GxqBackgroundView.h
//  自定义弹出框
//
//  Created by 高盛通 on 16/2/16.
//  Copyright © 2016年 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GxqAlertView : UIView
typedef void (^GxqLeftBlock)();
typedef void (^GxqRightBlock)();
@property (nonatomic,copy)GxqLeftBlock leftBlock;
@property (nonatomic,copy)GxqRightBlock rightBlock;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger seconds;
@property (nonatomic,strong)UILabel *timeLabel;
+ (void)showWithTipText:(NSString *)tipText descText:(NSString *)descText LeftText:(NSString *)leftText second:(NSInteger)seconds rightText:(NSString *)rightText LeftBlock:(GxqLeftBlock)leftBlock RightBlock:(GxqRightBlock)rightBlock;
@end
