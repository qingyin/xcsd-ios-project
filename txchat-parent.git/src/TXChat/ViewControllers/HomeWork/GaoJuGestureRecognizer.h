//
//  KMGestureRecognizer.h
//  拖动手势
//
//  Created by gaoju on 16/4/15.
//  Copyright © 2016年 xcsdedu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  NS_ENUM(NSUInteger, Direction) {
    DirectionUnknown,
    DirectionLeft,
    DirectionRight
};

@interface GaoJuGestureRecognizer : UIGestureRecognizer
@property (assign, nonatomic) NSUInteger tickleCount; //挠痒次数
@property (assign, nonatomic) CGPoint currentTickleStart; //当前挠痒开始坐标位置
@property (assign, nonatomic) Direction lastDirection; //最后一次挠痒方向

@end
