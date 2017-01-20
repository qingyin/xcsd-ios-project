//
//  SpecialResponseTableViewCell.h
//  TXChatTeacher
//
//  Created by lyt on 15/11/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpecialResponseTableViewCell : UITableViewCell
@property(nonatomic, strong)IBOutlet UILabel *questionTitleLabel;
@property(nonatomic, strong)IBOutlet UILabel *answerDetailLabel;
@property(nonatomic, strong)IBOutlet UILabel *supportCountLabel;
@property(nonatomic, strong)IBOutlet UIImageView *supportIconImgView;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;
@end
