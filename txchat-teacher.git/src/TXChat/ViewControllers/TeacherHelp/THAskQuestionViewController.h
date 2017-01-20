//
//  THAskQuestionViewController.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface THAskQuestionViewController : BaseViewController

@property (nonatomic,strong) TXPBTag *tag;
@property (nonatomic,weak) UIViewController *backVc;
//是否是添加新回答界面
@property (nonatomic,assign) int64_t questionId;
@property (nonatomic,assign) BOOL isAddNewAnswer;
//是否禁止变更tag，默认为NO
@property (nonatomic,assign) BOOL forbiddenChangeTag;
//专家id
@property (nonatomic,assign) int64_t expertId;

@end
