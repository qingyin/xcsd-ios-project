//
//  BabyDetailTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyDetailTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *headerImage;
@property(nonatomic, strong)IBOutlet UIImageView *headerMaskImage;
@property(nonatomic, strong)IBOutlet UILabel *nameLabel;
@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
