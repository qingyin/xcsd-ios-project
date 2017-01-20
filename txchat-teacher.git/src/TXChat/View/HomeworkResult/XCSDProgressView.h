//
//  XCSDProgressView.h
//  TXChatParent
//
//  Created by gaoju on 16/7/12.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCSDProgressView : UIView

//- (void)setProgress:(float)progress;

@property (nonatomic, copy) XCSDProgressView *(^setProgress)(NSString *str, BOOL isPercent);

@property (nonatomic, copy) XCSDProgressView *(^setProgressColor)(NSString *hexColor);

@property (nonatomic, copy) XCSDProgressView *(^setTitle)(NSString *title);

@property (nonatomic, copy) XCSDProgressView *(^setRightArrow)();

@end
