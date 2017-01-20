//
//  TMedicineTableViewCell.h
//  TXChat
//
//  Created by lyt on 15/7/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMedicineTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *headerImageview;
@property(nonatomic, strong)IBOutlet UIImageView *unreadImageView;
@property(nonatomic, strong)IBOutlet UILabel *contentLabel;
@property(nonatomic, strong)IBOutlet UILabel *fromLabel;
@property(nonatomic, strong)IBOutlet UILabel *timeLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
