//
//  ParnentInfoTableViewCell.h
//  TXChatTeacher
//
//  Created by lyt on 15/11/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 孩子家长 列表 家长信息cell
 */

typedef NS_ENUM(NSInteger, ParentStatus) {
    ParentStatus_Actived,   //已激活
    ParentStatus_InActived, //未激活
    ParentStatus_Invited,   //已邀请
    ParentStatus_NoCallNumber,   //没有手机号
};

@interface ParnentInfoTableViewCell : UITableViewCell

@property(nonatomic, strong) UIImageView *headerImgView;
@property(nonatomic, strong) UILabel *parentNameLabel;
@property(nonatomic, assign) ParentStatus parentStatusValue;
@property(nonatomic, strong) UIButton   *callBtn;
@property(nonatomic, strong) UIButton   *inviteBtn;
@end
