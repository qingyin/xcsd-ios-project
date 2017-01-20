//
//  THAnswerDetailViewController.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface THAnswerDetailViewController : BaseViewController

@property (nonatomic,strong) TXPBQuestionAnswer *questionAnswer;
@property (nonatomic,assign) BOOL showReplyViewImmediately;

//回复某人
- (void)replyCommentWithUserName:(NSString *)userName
                          userId:(int64_t)userId
                         comment:(TXComment *)comment;

//删除某条评论
- (void)deleteCommentWithId:(int64_t)commentId;

@end
