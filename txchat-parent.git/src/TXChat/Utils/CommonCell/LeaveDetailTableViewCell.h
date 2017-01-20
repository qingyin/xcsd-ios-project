//
//  LeaveDetailTableViewCell.h
//  TXChatParent
//
//  Created by lyt on 15/11/25.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaveDetailTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *headerImageView;
@property(nonatomic, strong)IBOutlet UILabel *leaveTypeLabel;
@property(nonatomic, strong)IBOutlet UILabel *leaveCountLabel;
@property(nonatomic, strong)IBOutlet UILabel *leaveResultLabel;
@property(nonatomic, strong)IBOutlet UILabel *leaveTimeLabel;
@property(nonatomic, strong)IBOutlet UIView *leaveBgView;
@property(nonatomic, strong)IBOutlet UILabel *leaveReasonLabel;
@property(nonatomic, strong)IBOutlet UILabel *leaveReasonTitleLabel;
@property(nonatomic, strong)IBOutlet UILabel *leaveTimeTitleLabel;

@property(nonatomic, assign)TXPBLeaveType leaveType;
@property(nonatomic, assign)TXPBLeaveStatus resolvedStatus;
@end
