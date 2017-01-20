//
//  ClassTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *classIconImageView;
@property(nonatomic, strong)IBOutlet UILabel *classNameLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
