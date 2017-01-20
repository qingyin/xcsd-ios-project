//
//  HomeworkTableView.m
//  TXChatParent
//
//  Created by gaoju on 16/6/23.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "HomeworkTableView.h"

@implementation HomeworkTableView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.allowsSelection = NO;
        self.rowHeight = 60;
    }
    
    return self;
}

//- (void)drawRect:(CGRect)rect{
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    uigraphicsb
//    
//    
//}

@end
