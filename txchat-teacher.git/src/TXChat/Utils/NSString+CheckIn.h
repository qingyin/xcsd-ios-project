//
//  NSString+CheckIn.h
//  TXChatTeacher
//
//  Created by lyt on 15/10/13.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CheckIn)
//是不是刷卡消息
+(BOOL)isCardInfo:(NSString *)scanedUrl;
//解析user_id
+(NSString *)getUserIdByUrl:(NSString *)scanedUrl;
//解析名字
+(NSString *)getUserNameByUrl:(NSString *)scanedUrl;
//解析名字
+(NSString *)getUserTypeByUrl:(NSString *)scanedUrl;
//解析卡号
+(NSString *)getUserCardNumberByUrl:(NSString *)scanedUrl;
@end
