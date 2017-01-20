//
//  NotifyDetailViewController.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"

@interface NoticeDetailViewController : BaseViewController
//根据通知 初始化通知详情
-(id)initWithNotice:(TXNotice *)notice;
@end
