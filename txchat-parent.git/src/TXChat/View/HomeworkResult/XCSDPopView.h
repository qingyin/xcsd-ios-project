//
//  XCSDPopView.h
//  TXChatTeacher
//
//  Created by gaoju on 16/7/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCSDPopView : UIView

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *text;

- (void)setTitle:(NSString *)title text:(NSString *)text;

@end
