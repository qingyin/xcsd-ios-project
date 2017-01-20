//
//  LeftInsetLabel.m
//  TXChatParent
//
//  Created by gaoju on 12/27/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "LeftInsetLabel.h"

@implementation LeftInsetLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void) drawTextInRect:(CGRect)rect {
    UIEdgeInsets inset = UIEdgeInsetsMake(0, _leftInset, 0, 0);
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, inset)];
}

@end
