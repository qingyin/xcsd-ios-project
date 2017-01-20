//
//  CoursesTitleCell.h
//  1
//
//  Created by frank on 16/3/10.
//  Copyright © 2016年 frank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoursesTitleCell : UITableViewCell

@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) UILabel *studyCount;
@property (nonatomic,strong) UILabel *assments;
@property (nonatomic,strong) UIImageView *image1;
@property (nonatomic,strong) UIImageView *image2;
@property (nonatomic,strong) UIImageView *image3;
@property (nonatomic,strong) UIImageView *image4;
@property (nonatomic,strong) UIImageView *image5;
@property (nonatomic,strong) UIView *lineView;


- (void)setDateWithCourse:(TXPBCourse *)course;

@end
