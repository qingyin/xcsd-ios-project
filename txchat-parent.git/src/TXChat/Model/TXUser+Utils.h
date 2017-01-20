//
//  TXUser+Utils.h
//  TXChat
//
//  Created by lyt on 15-6-19.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXUser.h"

@interface TXUser (Utils)
//获取性别
-(NSString *)getSexStr;
//获取格式化后的头像
-(NSString *)getFormatAvatarUrl:(CGFloat)width hight:(CGFloat)hight;

//获取监护人信息
-(NSString *)getGuarDerStr;

@end
