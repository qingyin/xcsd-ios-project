//
//  THQuestionAnswerTableViewCell.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/12/1.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THQuestionDetailViewController;
@interface THQuestionAnswerTableViewCell : UITableViewCell

@property (nonatomic,strong) TXPBQuestionAnswer *questionAnswer;
@property (nonatomic,weak) THQuestionDetailViewController *detailVc;

+ (CGFloat)heightForCellWithQuestionAnswer:(TXPBQuestionAnswer *)dict
                                 cellWidth:(CGFloat)cellWidth;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)cellWidth;

@end
