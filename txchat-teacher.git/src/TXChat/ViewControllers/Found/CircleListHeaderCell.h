//
//  CircleListHeaderCell.h
//  TXChat
//
//  Created by Cloud on 15/6/30.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleListHeaderCell : UITableViewCell

@property (nonatomic, assign) id listVC;

@property (nonatomic, strong) UIButton *newsBtn;

- (void)setPortrait:(NSString *)portrait andNickname:(NSString *)nickName andLevel:(int)level andLevelName:(NSString *)levelName;

+(CGFloat)GetHeaderCellHeight:(BOOL)isShow andLevelName:(NSString *)levelName;

@end
