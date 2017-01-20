//
//  contentsCell.h
//  TXChatParent
//
//  Created by frank on 16/3/16.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BroadcastVideoItem;

@interface ContentsCell : UITableViewCell

@property (strong, nonatomic)  UILabel *lable1;
@property (strong, nonatomic)  UILabel *titleLable;
@property (strong, nonatomic)  UILabel *timeLable;
@property (nonatomic,strong) UIImageView *imageV;
@property (nonatomic,strong) UIView *lineView;

- (void)setDateWithItem:(BroadcastVideoItem *)item andIndex:(NSInteger)index;

@end
