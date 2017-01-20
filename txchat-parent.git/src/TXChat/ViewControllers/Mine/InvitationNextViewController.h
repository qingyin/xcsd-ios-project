//
//  InvitationNextViewController.h
//  TXChat
//
//  Created by Cloud on 15/7/3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "BaseViewController.h"
@class InvitationListViewController;

@interface InvitationNextViewController : BaseViewController

@property (nonatomic, assign) TXPBParentType type;
@property (nonatomic, weak) InvitationListViewController *invitationVC;

@end
