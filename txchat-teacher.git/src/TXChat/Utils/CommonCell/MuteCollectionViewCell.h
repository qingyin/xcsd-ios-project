//
//  MuteCollectionViewCell.h
//  TXChat
//
//  Created by lyt on 15/7/23.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MuteCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong)UIImageView *headerImage;
//@property(nonatomic, strong)UIImageView *headerMaskImage;
@property(nonatomic, strong)UILabel *nameLabel;
@property(nonatomic, strong)UIImageView *delImageView;

//更新删除状态
-(void)updateDelStatus:(BOOL)delStatus;

@end
