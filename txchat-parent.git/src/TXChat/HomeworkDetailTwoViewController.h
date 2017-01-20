//
//  HomeworkDetailTwoViewController.h
//  TXChatParent
//
//  Created by gaoju on 16/6/20.
//  Copyright © 2016年 xcsd. All rights reserved.
//

#import "BaseViewController.h"
#import "XCSDHomeWork.h"

@interface HomeworkDetailTwoViewController : BaseViewController

@property (nonatomic, copy) HomeworkDetailTwoViewController *(^setHomework)(XCSDHomeWork *homework);

@property (nonatomic, copy) void(^didStartHomework)(BOOL isStart);

@end
