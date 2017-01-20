//
//  THQuestionView.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol THQuestionViewDelegate <NSObject>

- (void)onQuestionPhotoTapped:(NSInteger)index;

@end

@interface THQuestionView : UIView

@property (nonatomic,assign,readonly) CGFloat questionHeight;
@property (nonatomic,strong) TXPBQuestion *questionDict;
@property (nonatomic,weak) id<THQuestionViewDelegate> delegate;
@property (nonatomic,assign) int64_t replyNumber;

@end
