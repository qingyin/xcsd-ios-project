//
//  TXMediaCommentTableViewCell.h
//  TXChatParent
//
//  Created by 陈爱彬 on 16/1/19.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TXMediaCommentTableViewCell : UITableViewCell

@property (nonatomic,strong) TXComment *comment;

+ (CGFloat)heightForCellWithMediaComment:(TXComment *)dict
                               cellWidth:(CGFloat)cellWidth;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
