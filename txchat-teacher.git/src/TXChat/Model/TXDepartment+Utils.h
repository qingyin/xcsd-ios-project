//
//  TXDepartment+Utils.h
//  TXChat
//
//  Created by lyt on 15-7-3.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXDepartment.h"

@interface TXDepartment (Utils)
//获取学校名字
-(NSString *)getKindergartenName;
//获取群头像
-(NSString *)getFormatAvatarUrl:(CGFloat)width hight:(CGFloat)hight;

@end
