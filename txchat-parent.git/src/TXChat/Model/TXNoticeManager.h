//
//  TXNoticeManager.h
//  TXChat
//
//  Created by lyt on 15-6-15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TXChatNotifyConversation;

@interface TXNoticeManager : NSObject
{
    BOOL _isInNoticeVC;
}
//单例
+ (instancetype)shareInstance;
//获取最新的通知
-(TXChatNotifyConversation *)getLastNotice;
//获取 未读通知数目
-(NSUInteger)unreadNoticesCount;

-(void)asyncNewsNotices;
//更新当前是不是在通知界面
-(void)updateNoticeStatus:(BOOL)isNoticeVC;

@end
