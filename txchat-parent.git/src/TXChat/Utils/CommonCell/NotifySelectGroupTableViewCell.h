//
//  NotifySelectGroupTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UPDATESELECTEDNUMBER)(NSString *groupName, BOOL isSelected);


@interface NotifySelectGroupTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIButton *checkBtn;
@property(nonatomic, strong)IBOutlet UIImageView *groupIcon;
@property(nonatomic, strong)IBOutlet UILabel *groupName;
@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)UPDATESELECTEDNUMBER selectedBock;
-(IBAction)checkboxClick:(UIButton*)btn;



@end
