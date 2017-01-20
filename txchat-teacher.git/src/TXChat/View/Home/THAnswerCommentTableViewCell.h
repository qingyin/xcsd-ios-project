//
//  THAnswerCommentTableViewCell.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/2.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THAnswerDetailViewController;
@interface THAnswerCommentTableViewCell : UITableViewCell

@property (nonatomic,strong) TXComment *answerComment;
@property (nonatomic,weak) THAnswerDetailViewController *answerVc;

+ (CGFloat)heightForCellWithAnswerComment:(TXComment *)dict
                                cellWidth:(CGFloat)cellWidth;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
