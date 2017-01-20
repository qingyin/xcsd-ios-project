//
//  TXNoticeManager.m
//  TXChat
//
//  Created by lyt on 15-6-15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXNoticeManager.h"
#import "TXEaseMobHelper.h"
#import <TXChatClient.h>
#import "TXChatNotifyConversation.h"
#import "TXSystemManager.h"

@implementation TXNoticeManager


//单例
+ (instancetype)shareInstance
{
    static TXNoticeManager *_instance = nil;
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
//        _noticeList = [NSMutableArray arrayWithCapacity:5];
//        _noticeQ = dispatch_queue_create("tx.gcd.NoticeQueue", DISPATCH_QUEUE_SERIAL);
        [[TXEaseMobHelper sharedHelper] addEaseMobRefreshObserver:self selector:@selector(refreshNotifyDataSource) type:TXEaseMobRefreshNotifyType];        
    }
    return self;
}

//获取最新的通知
-(TXChatNotifyConversation *)getLastNotice
{
    //模拟添加通知信息
    NSError *error = nil;
    TXNotice *lastNotice = [[TXChatClient sharedInstance] getLastNotice:&error];
    if(error)
    {
        DLog(@"error:%@", error);
        return nil;
    }
    
    if(lastNotice == nil)
    {
        return nil;
    }
    TXUser *from = [[TXChatClient sharedInstance] getUserByUserId:lastNotice.fromUserId error:nil];
    NSDictionary *notifyDict = @{@"lastMsg": lastNotice.content,@"time": [NSString stringWithFormat:@"%@", @(lastNotice.sentOn/1000)], @"unreadNumbe":@([self unreadNoticesCount]), @"senderName":(from && from.nickname)? from.nickname : @""};
    TXChatNotifyConversation *notifyConversation = [[TXChatNotifyConversation alloc] initWithConversationAttributes:notifyDict];
    return notifyConversation;
}


//获取 未读通知数目
-(NSUInteger)unreadNoticesCount
{
    NSUInteger count = 0;
    NSDictionary *countDic = [[TXChatClient sharedInstance] getCountersDictionary];
    if(countDic != nil)
    {
        NSNumber *noticeUnreadCount = [countDic objectForKey:TX_COUNT_NOTICE];
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
    
    [[TXChatClient sharedInstance] fetchNotices:YES maxNoticeId:LLONG_MAX onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
        if(error)
        {
            DDLogDebug(@"error:%@", error);
        }
        else
        {
            if(lastOneHasChanged)
            {
                if(_isInNoticeVC)
                {
                    [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
                }
                else
                {
                    [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:nil emMessage:nil];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_NOTICES object:txNotices];
            });
        }
    }];
    
}


-(void)asyncNewsNotices
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[TXChatClient sharedInstance] fetchNotices:YES maxNoticeId:LLONG_MAX onCompleted:^(NSError *error, NSArray *txNotices, BOOL isInbox, BOOL hasMore, BOOL lastOneHasChanged) {
            if(error)
            {
                DDLogDebug(@"error:%@",error);
            }
            else
            {
                if(lastOneHasChanged)
                {
                    if(_isInNoticeVC)
                    {
                        [[TXSystemManager sharedManager] playVibrationWithGroupId:nil emMessage:nil];
                    }
                    else
                    {
                        [[TXSystemManager sharedManager] playSoundAndVibrationWithGroupId:nil emMessage:nil];
                    }
                }
                DDLogDebug(@"txnoticesCount:%lu", (unsigned long)[txNotices count]);
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_NOTICES object:txNotices];
            }
        }];
    });
}

//更新当前是不是在通知界面
-(void)updateNoticeStatus:(BOOL)isNoticeVC
{
    _isInNoticeVC = isNoticeVC;
}



@end
