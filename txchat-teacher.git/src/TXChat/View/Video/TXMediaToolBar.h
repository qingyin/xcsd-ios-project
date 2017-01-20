//
//  TXMediaToolBar.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/12.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TXMediaToolType) {
    TXMediaToolType_WriteComment,
    TXMediaToolType_Comment,
    TXMediaToolType_Like,
    TXMediaToolType_Share
};

typedef void(^TXMediaToolClickBlock)(TXMediaToolType type);

@interface TXMediaToolBar : UIView

@property (nonatomic,strong) TXPBResource *resource;
@property (nonatomic,getter=isLiked) BOOL liked;
@property (nonatomic,copy) TXMediaToolClickBlock clickBlock;

- (instancetype)initWithFrame:(CGRect)frame
                      resouce:(TXPBResource *)resource;

//更新竖屏布局
- (void)updateLayoutToPortrait;
//更新横屏布局
- (void)updateLayoutToLandscape;

@end
