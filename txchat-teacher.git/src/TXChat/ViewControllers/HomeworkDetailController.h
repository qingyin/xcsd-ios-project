//
//  HomeworkDetailController.h
//  TXChatTeacher
//
//  Created by gaoju on 16/6/27.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeworkDetailController : BaseViewController

@property (nonatomic, copy) void (^setData)(int64_t childUserId, int64_t class_Id);

@end
