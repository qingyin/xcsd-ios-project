//
//  NotifySelectMembersTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^UPDATESELECTEDNUMBER)(NSString *groupName, BOOL isSelected);
@interface NotifySelectMembersTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *userIconImageView;
@property(nonatomic, strong)IBOutlet UILabel *userNameLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)UPDATESELECTEDNUMBER selectedBock;
@property(nonatomic, strong)IBOutlet UIButton *checkBtn;
-(IBAction)checkboxClick:(UIButton*)btn;

@end
