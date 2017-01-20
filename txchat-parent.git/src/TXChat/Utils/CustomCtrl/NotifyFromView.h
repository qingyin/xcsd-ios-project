//
//  NotifyFromView.h
//  TXChat
//
//  Created by lyt on 15-6-9.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotifyFromViewDelegate <NSObject>

-(void)UserTouchUpInView;

@end


@interface NotifyFromView : UIView
@property(nonatomic, strong)IBOutlet UILabel *titleLabel;
@property(nonatomic, strong)IBOutlet UILabel *fromLabel;
@property(nonatomic, strong)IBOutlet UIImageView *rightArrow;
@property(nonatomic, strong)IBOutlet UIView *seperatorLine;

@property(nonatomic, assign)id<NotifyFromViewDelegate>delegate;

//@property(nonatomic, strong)IBOutlet UITapGestureRecognizer *tab;
//
//
//-(void)FromViewTapEvent:(UITapGestureRecognizer*)recognizer;

-(IBAction)btnPressed:(id)sender;


@end
