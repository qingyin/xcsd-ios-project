//
//  TXRequestHelper.h
//  TXChat
//
//  Created by lyt on 15-7-1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestBLock)(NSError *error, int64_t taskId);


@interface TXRequestHelper : NSObject

//单例
+ (instancetype)shareInstance;

//提交喂药信息到服务器
-(void)sendMedicineRequestToServer:(NSArray *)selectedPhotos content:(NSString *)content beginDate:(int64_t)beginDate completeBlock:(RequestBLock)completeBlcok;
//上传devicetoken到服务器
-(void)updateDeviceTokenToServer:(NSString *)devicetoken;

//用广告id做设备id
+ (NSString *) uniqueGlobalDeviceIdentifier;
//手机信息
-(NSString *)getMobileInfo;


@end
