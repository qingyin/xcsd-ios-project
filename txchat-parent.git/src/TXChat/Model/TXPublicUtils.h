//
//  TXPublicUtils.h
//  TXChatParent
//
//  Created by lyt on 16/1/26.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TXPublicUtils : NSObject
/**
 *  整数转化为 以万结尾的字符串 小数点后保留1位
 *
 *  @param number 需要转化的数
 *
 *  @return 转化后的结果
 */
+(NSString *)fortmatInt64ToTenThousandStr:(int64_t)number;
@end
