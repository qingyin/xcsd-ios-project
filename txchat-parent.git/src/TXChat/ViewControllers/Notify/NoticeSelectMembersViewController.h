//
//  NotifySelectMembersViewController.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
typedef void(^UPDATEMEMEBERSELECTED)(NSArray *userArray, NSString *groupName);


@interface NoticeSelectMembersViewController : BaseViewController
@property(nonatomic, strong)UPDATEMEMEBERSELECTED updateMemberSelected;
@end
