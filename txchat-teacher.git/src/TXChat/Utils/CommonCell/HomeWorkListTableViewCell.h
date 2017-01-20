//
//  HomeWorkListTableViewCell.h
//  TXChatTeacher
//
//  Created by gaoju on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeWorkListTableViewCell : UITableViewCell
@property (strong, nonatomic)  UIImageView *avatarImage;
@property (strong, nonatomic)  UILabel *classLabel;
@property (strong, nonatomic)  UILabel *homeWorkTypeLabel;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong,nonatomic)   UILabel  *numberLabel;
@property (strong, nonatomic)  UIView *lineView;
@end
