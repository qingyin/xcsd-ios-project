//
//  UserDetailTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UILabel *titleLabel;
@property(nonatomic, strong)IBOutlet UILabel *contentLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
