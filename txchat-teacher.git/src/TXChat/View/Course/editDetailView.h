//
//  editDetailView.h
//  TXChatParent
//
//  Created by frank on 16/3/14.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface editDetailView : UIView
@property (weak, nonatomic) IBOutlet UILabel *levelLable;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *hodleLable;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;
@property (weak, nonatomic) IBOutlet UIButton *button5;
@property (weak, nonatomic) IBOutlet UIView *swipView;

@property (nonatomic) NSInteger starNum;


@end
