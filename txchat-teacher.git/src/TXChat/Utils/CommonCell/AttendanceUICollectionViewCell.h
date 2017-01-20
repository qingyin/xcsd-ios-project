//
//  AttendanceUICollectionViewCell.h
//  TXChatTeacher
//
//  Created by lyt on 15/11/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendanceUICollectionViewCell : UICollectionViewCell
@property(nonatomic, strong)UIImageView *headerImage;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UIImageView *selectedImageView;

//更新选中状态
-(void)updateSelectedStatus:(BOOL)selectedStatus;
@end
