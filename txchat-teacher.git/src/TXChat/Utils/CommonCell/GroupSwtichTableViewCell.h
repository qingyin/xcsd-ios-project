//
//  GroupSwtichTableViewCell.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SwitchValueChanged)(id sender);


@interface GroupSwtichTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UISwitch *sw;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@property(nonatomic, strong)IBOutlet UILabel *nameLabel;
-(IBAction)switchAction:(id)sender;
@property(nonatomic, strong)SwitchValueChanged switchValueChanged;

@end
