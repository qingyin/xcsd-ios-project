//
//  CheckInDetailTableViewCell.h
//  TXChatTeacher
//
//  Created by lyt on 15/9/24.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckInDetailTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UILabel *cardNumberOrNickNameLabel;
@property(nonatomic, strong)IBOutlet UILabel *timeLabel;
@property(nonatomic, strong)IBOutlet UILabel *statusLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
