//
//  LeaveDetailViewController.h
//  TXChatTeacher
//
//  Created by Cloud on 15/11/26.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void(^blockEdit)(BOOL,NSInteger);

@interface EditDetailViewController : BaseViewController

@property (nonatomic,copy) blockEdit editBtn;
@property (nonatomic,strong) TXPBCourse *course;

- (id)initWithLeave:(TXPBLeave *)leave;

@end
