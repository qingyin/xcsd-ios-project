//
//  ShareDetailView.h
//  TXChatTeacher
//
//  Created by gaoju on 16/11/15.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareDetailView : UIView

@property (nonatomic, strong) NSArray<NSArray *>*selectArr;

@property (nonatomic, strong) NSString *articleTitle;

@property (nonatomic, copy) void(^confirmBlock)(NSString *text);

@property (nonatomic, copy) void(^cancleBlock)();

- (void)endEditing;

@end
