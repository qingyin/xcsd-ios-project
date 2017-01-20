//
//  HomeworkResultCompareController.h
//  TXChatParent
//
//  Created by gaoju on 12/27/16.
//  Copyright © 2016 xcsd. All rights reserved.
//

#import "BaseViewController.h"

@interface HomeworkResultCompareController : BaseViewController

@property (nonatomic, copy) void(^onCompleted)(NSInteger index);

@property (nonatomic, strong) NSArray *dataArr;

@end
