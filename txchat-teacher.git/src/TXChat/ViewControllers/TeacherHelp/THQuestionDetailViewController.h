//
//  THQuestionDetailViewController.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface THQuestionDetailViewController : BaseViewController

@property (nonatomic,strong) TXPBQuestion *pbQuestion;

//回复
- (void)replyAnswerWithComment:(TXPBQuestionAnswer *)answer;

//删除
- (void)deleteAnswerWithId:(int64_t)answerId;

//赞
- (void)likeAnswerWithComment:(TXPBQuestionAnswer *)answer;

//点击头像
- (void)onAvtarTappedWithComment:(TXPBQuestionAnswer *)answer;

@end
