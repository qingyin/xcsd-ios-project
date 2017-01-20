//
//  HomeWorkTypeTableViewCell.h
//  TXChatTeacher
//
//  Created by gaoju on 16/3/31.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeWorkTypeTableViewCell : UITableViewCell
@property (strong, nonatomic)  UIView *lineView;
@property (strong, nonatomic)  UILabel *classLabel;
@property (strong, nonatomic)  UILabel *homeWorkTypeLabel;
@property (strong,nonatomic) UILabel *homeWorkBriefLabel; //作业简介
@property  (strong,nonatomic) UILabel *stateLabel;
@end
