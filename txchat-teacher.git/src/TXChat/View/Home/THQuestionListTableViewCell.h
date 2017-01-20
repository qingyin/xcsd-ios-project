//
//  THQuestionListTableViewCell.h
//  TXChatTeacher
//
//  Created by 陈爱彬 on 15/11/25.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THQuestionListTableViewCell : UITableViewCell

@property (nonatomic,strong) TXPBQuestion *questionDict;
@property (nonatomic,strong) TXPBCommunionMessage *communionMessage;
@property (nonatomic,assign) BOOL isRead;

+ (CGFloat)heightForCellWithQuestion:(TXPBQuestion *)dict
                        contentWidth:(CGFloat)contentWidth;

+ (CGFloat)heightForCellWithCommunion:(TXPBCommunionMessage *)dict
                         contentWidth:(CGFloat)contentWidth;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellWidth:(CGFloat)width;

@end
