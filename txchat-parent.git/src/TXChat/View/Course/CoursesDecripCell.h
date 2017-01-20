//
//  CoursesDecripCell.h
//  1
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoursesDecripCell : UITableViewCell

@property (nonatomic,strong) UILabel *lable;
@property (nonatomic,strong) UILabel *decripLable;
@property (nonatomic,strong) UIButton *MoreBtn;
@property (nonatomic,strong) UIView *lineView;

- (void)setDateWithCourse:(TXPBCourse *)course andBool:(BOOL)reload;

@end
