//
//  NotifyRcverTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-10.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifyRcverTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *groupIcon;
@property(nonatomic, strong)IBOutlet UILabel *groupNamelLabel;
@property(nonatomic, strong)IBOutlet UILabel *countLabel;
@property(nonatomic, strong)IBOutlet UILabel *unreadLabel;
@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
