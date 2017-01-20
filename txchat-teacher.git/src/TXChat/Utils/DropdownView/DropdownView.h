//
//  DropdownView.h
//  TXChatTeacher
//
//  Created by Cloud on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DropdownBlock)(int);

@interface DropdownView : NSObject
{
    DropdownBlock _block;
}

@property (nonatomic, assign) int selectedIndex;

- (void)showInView:(UIView *)view
        andListArr:(NSArray *)arr
  andDropdownBlock:(DropdownBlock)block;

- (void)showDropDownView:(CGFloat)originY;

@end
