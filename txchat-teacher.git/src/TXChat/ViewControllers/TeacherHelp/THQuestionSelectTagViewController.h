//
//  THQuestionSelectTagViewController.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^THQuestionSelectTagBlock)(TXPBTag *tag);

@interface THQuestionSelectTagViewController : BaseViewController

@property (nonatomic,strong) TXPBTag *currentTag;
@property (nonatomic,copy) THQuestionSelectTagBlock tagBlock;
@property (nonatomic,weak) UIViewController *backVc;
@property (nonatomic,strong) NSArray *tagsArray;

@end
