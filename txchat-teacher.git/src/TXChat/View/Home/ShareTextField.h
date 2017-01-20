//
//  ShareTextField.h
//  TXChatTeacher
//
//  Created by gaoju on 16/11/16.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareSelectIconsView;

@interface ShareTextField : UITextField

@property (nonatomic, copy) void(^deleteClick)(NSInteger count);

@property (nonatomic, assign) BOOL isHolderLeft;

@property (nonatomic, weak) UIImageView *imageView;

- (void)setHolderLeftAndLeftViewHidden:(BOOL) isSet;

- (void)revertDeleteCount;

@end
