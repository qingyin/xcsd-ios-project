//
//  XCDSDHomeWorkNoticeManager.m
//  TXChatParent
//
//  Created by gaoju on 16/3/23.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "XCDSDHomeWorkNoticeManager.h"
#import "TXEaseMobHelper.h"
#import <TXChatClient.h>
#import "XCSDHomeWorkNotice.h"
#import "TXSystemManager.h"

@implementation XCDSDHomeWorkNoticeManager
//单例
+ (instancetype)shareInstance;
{
    static XCDSDHomeWorkNoticeManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
//        [[TXEaseMobHelper sharedHelper] addEaseMobRefreshObserver:self selector:@selector(refreshNotifyDataSource) type:TXEaseMobRefreshNotifyType];
    }
    return self;
}

//获取最新的通知
-(XCSDHomeWorkNotice *)getHomeWorlLastHomeWorks
{
    //模拟添加通知信息
    NSError *error = nil;
    XCSDHomeWork *lastHomeWork = [[TXChatClient sharedInstance] getLastHomework:&error];
    if(error)
    {
        DLog(@"error:%@", error);
        return nil;
    }
    
    if(lastHomeWork == nil)
    {
        return nil;
    }
    XCSDHomeWork *homeWork = [[XCDSDHomeWorkNoticeManager shareInstance] getLastHomework:&error];
     NSDictionary *homeWorkDict = @{@"lastMsg": lastHomeWork.senderAvatar,@"time": [NSString stringWithFormat:@"%@", @(lastHomeWork.sendTime/1000)], @"unreadNumbe":@([self unreadHomeWorksCount]), @"senderName":([NSString stringWithFormat:@"%@布置给%@的%@",homeWork.senderName,homeWork.targetName,homeWork.title])};
    XCSDHomeWorkNotice *HomeWorkConversation = [[XCSDHomeWorkNotice alloc] initWithConversationAttributes:homeWorkDict];
    return HomeWorkConversation;
}


//获取 未读通知数目
-(NSUInteger)unreadHomeWorksCount
{
    NSUInteger count = 0;
    NSDictionary *countDic = [[TXChatClient sharedInstance] getCountersDictionary];
    if(countDic != nil)
    {
        
        NSNumber *noticeUnreadCount = [countDic objectForKey:TX_COUNT_HOMEWORK];
        if(noticeUnreadCount != nil)
        {
            count = [noticeUnreadCount unsignedIntegerValue];
        }
    }
    return count;
}





//刷新消息通知列表
- (void)refreshNotifyDataSource
{
    //    NSLog(@"在此处刷新通知信息");
    
    [[TXChatClient sharedInstance] fetchHomeWorks:YES maxHomeWorkId:LLONG_MAX onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            if(lastOneHasChanged)
            {
                if(_isInHomeWorkVC)
                {
                   [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
                }
                else
                {
                    [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:nil emMessage:nil];
                }
            }
           dispatch_async(dispatch_get_main_queue(), ^{
               [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_HOMEWORKS object:txNotices];
  
         });
                          }
    }];
    
}


-(void)asyncNewsHomeWorks
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TXChatClient sharedInstance] fetchHomeWorks:YES maxHomeWorkId:LLONG_MAX onCompleted:^(NSError *error, NSArray *homeworks, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
            if(error)
            {
                DDLogDebug(@"error:%@",error);
            }
            else
            {
                if(lastOneHasChanged)
                {
                    if(_isInHomeWorkVC)
                    {
                        [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
                    }
                    else
                    {
                        [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:nil emMessage:nil];
                    }
                }
                DDLogDebug(@"txnoticesCount:%lu", (unsigned long)[homeworks count]);
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_HOMEWORKS object:homeworks];
            }
        }];
    });
}

//更新当前是不是在通知界面
-(void)updateHomeWorksStatus:(BOOL)isHomeWorksVC
{
    _isInHomeWorkVC = isHomeWorksVC;
}

- (XCSDHomeWork *)getLastHomework:(NSError **)outError
{
    return [[TXChatClient sharedInstance]getLastHomework:outError];
}

@end
