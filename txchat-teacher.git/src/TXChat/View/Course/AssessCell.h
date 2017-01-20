//
//  assessCell.h
//  TXChatParent
//
//  Created by frank on 16/3/11.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssessCell : UITableViewCell
@property (strong, nonatomic)  UIImageView *iconImage;
@property (strong, nonatomic)  UILabel *lableName;
@property (strong, nonatomic)  UILabel *lableData;
@property (strong, nonatomic)  UILabel *lableContent;
@property (strong, nonatomic)  UIImageView *image1;
@property (strong, nonatomic)  UIImageView *image2;
@property (strong, nonatomic)  UIImageView *image3;
@property (strong, nonatomic)  UIImageView *image4;
@property (strong, nonatomic)  UIImageView *image5;
@property (nonatomic,strong) UIView *lineView;

- (void)bindDateWithCourseComment:(TXPBCourseComment *)comment;

@end
