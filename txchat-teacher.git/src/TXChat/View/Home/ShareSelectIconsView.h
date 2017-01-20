//
//  ShareSelectIconsView.h
//  TXChatTeacher
//
//  Created by yarn on 2016/11/29.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kIconWH 35
#define kIconsCount 6

#define kLeftMargin 5
#define kMargin 8

@interface ShareSelectIconsView : UIView


- (void)addSelectPerson:(id) person;

- (void)deleteSelectPerson:(id) person;

- (void)deleteHalfAnimation;

- (id)deleteLastPerson;

- (void)revertHalfAnimation;

@end
