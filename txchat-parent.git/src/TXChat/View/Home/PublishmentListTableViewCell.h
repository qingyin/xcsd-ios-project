//
//  PublishmentListTableViewCell.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/26.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomePublishmentEntity;
@interface PublishmentListTableViewCell : UITableViewCell

@property (nonatomic,strong) HomePublishmentEntity *entity;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)width;

@end
