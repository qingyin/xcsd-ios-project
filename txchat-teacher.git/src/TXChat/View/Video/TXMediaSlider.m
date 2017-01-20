//
//  TXMediaSlider.m
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/6.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXMediaSlider.h"

@implementation TXMediaSlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect rect = bounds;
//    NSInteger height = (NSInteger)bounds.size.height;
//    if (height % 2 == 0) {
//        rect.size.height = height - 1;
//    }
    rect.origin.y = (rect.size.height - 3) / 2.f;
    rect.size.height = 3;
    return rect;
}
@end
