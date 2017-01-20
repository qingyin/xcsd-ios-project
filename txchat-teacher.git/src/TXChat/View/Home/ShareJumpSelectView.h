//
//  ShareJumpView.h
//  TXChatTeacher
//
//  Created by gaoju on 16/11/17.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectBlock)();

@interface ShareJumpSelectView : UIView

@property (nonatomic, copy) SelectBlock articleBlock;

@property (nonatomic, copy) SelectBlock msgBlock;

- (instancetype)initWithArticleBlock:(SelectBlock) articleBlock msgBlock:(SelectBlock) msgBlock;

@end
