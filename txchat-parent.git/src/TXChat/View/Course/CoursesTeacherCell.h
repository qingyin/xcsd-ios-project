//
//  CoursesTeacherCell.h
//  1
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoursesTeacherCell : UITableViewCell

@property (nonatomic,strong) UILabel *lableTitle;
@property (nonatomic,strong) UIImageView *iconImage;
@property (nonatomic,strong) UILabel *lableName;
@property (nonatomic,strong) UILabel *lableContent;
@property (nonatomic,strong) UIView *lineView;

- (void)setDateWithCourse:(TXPBCourse *)course;

@end
