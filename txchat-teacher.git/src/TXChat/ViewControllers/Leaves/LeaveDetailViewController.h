//
//  LeaveDetailViewController.h
//  TXChatTeacher
//
//  Created by Cloud on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class LeavesListViewController;

@interface LeaveDetailViewController : BaseViewController

@property (nonatomic, strong) TXPBLeave *leave;
@property (nonatomic, assign) LeavesListViewController *listVC;

- (id)initWithLeave:(TXPBLeave *)leave;

@end
