//
//  TXNoticeManage.h
//  TXChat
//
//  Created by lyt on 15-6-15.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TXNotice.h>

@interface TXSendNotice:TXNotice
@property(nonatomic, strong)NSArray *toUsers;
@end


@interface TXSendNoticeManager : NSObject

-(BOOL)addNoticeSender:(TXSendNotice *)notice;


@end
