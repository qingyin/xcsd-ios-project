//
//  THAnswerView.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol THAnswerViewDelegate <NSObject>

- (void)onAnswerPhotoTapped:(NSInteger)index;

@end

@interface THAnswerView : UIView

@property (nonatomic,assign,readonly) CGFloat answerHeight;
@property (nonatomic,strong) TXPBQuestionAnswer *answerDict;
@property (nonatomic,weak) id<THAnswerViewDelegate> delegate;

@end
