//
//  TXNoticeManage.m
//  TXChat
//
//  Created by lyt on 15-6-15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXSendNoticeManager.h"
#import <TXChatClient.h>

@implementation TXSendNotice



@end


@interface TXSendNoticeManager()
{
    NSMutableArray *_noticeList;
    dispatch_queue_t _noticeQ;
}

@end



@implementation TXSendNoticeManager

//单例
+ (instancetype)shareInstance
{
    static TXSendNoticeManager *_instance = nil;
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
        _noticeList = [NSMutableArray arrayWithCapacity:5];
        _noticeQ = dispatch_queue_create("tx.gcd.NoticeQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


-(BOOL)addNoticeSender:(TXSendNotice *)notice
{
    @synchronized(_noticeList)
    {
        [_noticeList addObject:notice];
    }
    if([_noticeList count] == 1)
    {
        dispatch_async(_noticeQ, ^{
            
            
            
        });
        
    }
    
    return YES;
}



-(void)fireNetwork
{
    if([_noticeList count] > 0)
    {
        TXSendNotice *notice = [_noticeList objectAtIndex:0];
        if(notice)
        {
//            [[TXChatClient sharedInstance] sendNotice:notice.content attaches:notice.attaches toDepartments:notice.toUsers onCompleted:^(NSError *error, TXNotice *txNotice) {
//                if(error)
//                {
//                    
//                }
//                else
//                {
//                    
//                    
//                    
//                }
//            }];
            
            [[TXChatClient sharedInstance] sendNotice:notice.content attaches:notice.attaches toDepartments:notice.toUsers onCompleted:^(NSError *error, int64_t noticeId) {
                DLog(@"error:%@", error);
            }];
        }
    }
}



@end
