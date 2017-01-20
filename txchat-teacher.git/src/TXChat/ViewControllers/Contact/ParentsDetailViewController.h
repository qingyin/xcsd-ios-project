//
//  ParentsDetailViewController.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface ParentsDetailViewController : BaseViewController

@property (nonatomic,copy) NSString *emChatterId;

//初始化家长和教师 更具用户id
-(id)initWithIdentity:(int64_t)userId;
@end
