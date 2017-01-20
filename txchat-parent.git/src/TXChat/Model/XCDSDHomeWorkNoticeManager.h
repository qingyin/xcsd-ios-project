//
//  XCDSDHomeWorkNoticeManager.h
//  TXChatParent
//
//  Created by gaoju on 16/3/23.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XCSDHomeWorkNotice;
@interface XCDSDHomeWorkNoticeManager : NSObject
{
    BOOL _isInHomeWorkVC;
}

//单例
+ (instancetype)shareInstance;

//获取最新的通知
-(XCSDHomeWorkNotice *)getHomeWorlLastHomeWorks;
//获取 未读通知数目
-(NSUInteger)unreadHomeWorksCount;
//- (void)refreshNotifyDataSource;
-(void)asyncNewsHomeWorks;
//更新当前是不是在通知界面
-(void)updateHomeWorksStatus:(BOOL)isHomeWorksVC;

- (XCSDHomeWork *)getLastHomework:(NSError **)outError;
@end
