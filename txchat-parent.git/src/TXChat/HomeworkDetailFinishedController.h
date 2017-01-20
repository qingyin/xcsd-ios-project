//
//  HomeworkDetailFinishedController.h
//  TXChatParent
//
//  Created by gaoju on 16/6/21.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "BaseViewController.h"
#import "XCSDHomeWork.h"

@interface HomeworkDetailFinishedController : BaseViewController

@property (nonatomic ,copy) HomeworkDetailFinishedController *(^setHomework)(XCSDHomeWork *homework);

@end
