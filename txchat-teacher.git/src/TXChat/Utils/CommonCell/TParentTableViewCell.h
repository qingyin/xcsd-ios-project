//
//  TParentTableViewCell.h
//  TXChat
//
//  Created by lyt on 15/7/22.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^callOperation)(NSInteger viewTag);

@interface TParentTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UIImageView *userImageView;
@property(nonatomic, strong)IBOutlet UILabel *userNameLabel;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)IBOutlet UIButton *callButton;
@property(nonatomic, strong)IBOutlet UIButton *inActiveBtn;
@property(nonatomic, strong)callOperation callBlock;
-(IBAction)callButton:(id)sender;

@end
