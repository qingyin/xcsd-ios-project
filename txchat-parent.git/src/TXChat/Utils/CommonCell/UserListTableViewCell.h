//
//  UserListTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserListTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *header1;
@property(nonatomic, strong)IBOutlet UIImageView *header2;
@property(nonatomic, strong)IBOutlet UIImageView *header3;
@property(nonatomic, strong)IBOutlet UIImageView *header4;
@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)IBOutlet UILabel *nameLabel;
-(void)setHeaderList:(NSArray *)headerList;
@property(nonatomic, strong, setter=setHeaderList:)NSArray *headerList;

@end
