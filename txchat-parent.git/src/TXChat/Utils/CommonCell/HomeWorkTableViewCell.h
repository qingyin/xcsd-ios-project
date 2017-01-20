//
//  NotifyTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-8.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeWorkTableViewCell : UITableViewCell

@property(nonatomic, strong)IBOutlet UILabel *toUserLabel;
@property(nonatomic, strong)IBOutlet UILabel *messageLabel;
@property(nonatomic, strong)IBOutlet UILabel *timeLabel;
@property(nonatomic, strong)IBOutlet UIImageView *stateImage;
@property (weak, nonatomic) IBOutlet UILabel *arrangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;


@property(nonatomic, strong)IBOutlet UIImageView *fromHeader;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)IBOutlet UIImageView *unreadImage;

@property (nonatomic) BOOL *ToDo;
@end
