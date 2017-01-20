//
//  TextTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-11.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *rightArrowImageView;
@property(nonatomic, strong)IBOutlet UILabel *nameLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
