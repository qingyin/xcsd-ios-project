//
//  NotifySelectMembersTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^UPDATESELECTEDNUMBER)(int64_t userId, BOOL isSelected);
@interface NotifySelectMembersTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *userIconImageView;
@property(nonatomic, strong)IBOutlet UILabel *userNameLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)UPDATESELECTEDNUMBER selectedBock;
@property(nonatomic, strong)IBOutlet UIButton *checkBtn;
@property(nonatomic, assign)int64_t userId;//当前cell的用户id

-(IBAction)checkboxClick:(UIButton*)btn;

//设置选中状态
-(void)setCheckStatus:(BOOL)isSelected;

@end
