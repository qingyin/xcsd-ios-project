//
//  THGuideArticleTableViewCell.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/27.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THGuideArticleTableViewCell : UITableViewCell

@property (nonatomic,strong) TXPBKnowledge *articleDict;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)width;

@end
