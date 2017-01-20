//
//  TXNoticeManage.h
//  TXChat
//
//  Created by lyt on 15-6-15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TXNotice.h>

typedef void(^SendNoticeRequestBLock)(NSError *error, int64_t taskId);


@interface TXSendNotice:TXNotice
@property(nonatomic, strong)NSString* noticeContent;
@property(nonatomic, strong)NSArray *toUsers;
@property(nonatomic, strong)NSArray *attachList;
@end


@interface TXSendNoticeManager : NSObject

//单例
+ (instancetype)shareInstance;

-(BOOL)addNoticeSender:(TXSendNotice *)notice  completeBlock:(SendNoticeRequestBLock)completeBlcok;




@end
