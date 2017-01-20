//
//  TXCacheManage.h
//  TXChat
//
//  Created by Cloud on 15/6/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TXChatSwipeCardConversation;

@interface TXCacheManage : NSObject


//获取当前用户信息
+ (instancetype)shareInstance;
-(TXChatSwipeCardConversation *)getLastCheckin;
//刷新刷卡列表
-(void)refreshCheckinDataSource;

@end
