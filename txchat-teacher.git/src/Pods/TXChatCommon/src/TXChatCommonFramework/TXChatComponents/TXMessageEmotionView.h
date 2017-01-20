//
//  TXMessageEmotionView.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TXMessageEmotionViewDelegate <NSObject>

- (void)sendEmotion;
- (void)selectedEmotion:(NSString *)str isDeleted:(BOOL)isDeleted;

@end

@interface TXMessageEmotionView : UIView

@property (nonatomic,weak) id<TXMessageEmotionViewDelegate> delegate;

- (BOOL)stringIsFace:(NSString *)string;

@end
