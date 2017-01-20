//
//  TXChatListTableViewCell.h
//  HuanXinChatDemo
//
//  Created by 陈爱彬 on 15/6/4.
//  Copyright (c) 2015年 陈爱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXChatConversation.h"

@interface TXChatListTableViewCell : UITableViewCell

@property (nonatomic,strong) id<TXChatConversationData> conversationData;
@property (nonatomic) BOOL isBottomCell;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier width:(CGFloat)width;

@end
