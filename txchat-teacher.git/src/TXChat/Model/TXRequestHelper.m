//
//  TXRequestHelper.m
//  TXChat
//
//  Created by lyt on 15-7-1.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXRequestHelper.h"
#import <TXChatClient.h>
#import "UploadImageStatus.h"
#import "UIDevice+IdentifierAddition.h"
#import <AdSupport/ASIdentifierManager.h>
#import <sys/utsname.h>


@implementation TXRequestHelper
//单例
+ (instancetype)shareInstance
{
    static TXRequestHelper *_instance = nil;
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

    }
    return self;
}

//提交喂药信息到服务器
-(void)sendMedicineRequestToServer:(NSArray *)selectedPhotos content:(NSString *)content beginDate:(int64_t)beginDate completeBlock:(RequestBLock)completeBlcok
{
    NSMutableArray *photoArray = [NSMutableArray arrayWithCapacity:5];
    for(UploadImageStatus *uploadStatusIndex in selectedPhotos)
    {
        TXPBAttachBuilder *txpbAttachBuilder = [TXPBAttach builder];
        txpbAttachBuilder.attachType = TXPBAttachTypePic;
        txpbAttachBuilder.fileurl = uploadStatusIndex.serverFileKey;
        TXPBAttach *txpbAttach = [txpbAttachBuilder build];
        [photoArray addObject:txpbAttach];
    }
    [[TXChatClient sharedInstance] sendFeedMedicineTask:content attaches:photoArray beginDate:beginDate onCompleted:^(NSError *error, int64_t feedMedicineTaskId) {
        DLog(@"error:%@, taskId:%lld", error, feedMedicineTaskId);
        if(completeBlcok)
        {
            completeBlcok(error, feedMedicineTaskId);
        }
    }];
}
//上传devicetoken到服务器
-(void)updateDeviceTokenToServer:(NSString *)devicetoken
{
    
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    [[TXChatClient sharedInstance] updateDeviceToken:devicetoken platformType:TXPBPlatformTypeIos osVersion:systemVersion mobileVersion:[self deviceString] deviceId:[TXRequestHelper uniqueGlobalDeviceIdentifier] onCompleted:^(NSError *error) {
        if (error) {
            DDLogDebug(@"上传设备信息到服务器失败:%@",error);
        }
    }];
}

-(NSString *)getMobileInfo
{
    return [NSString stringWithFormat:@"systemversion:%@ deviceString:%@ uinqueGlobalDeviceIdentifier:%@", [UIDevice currentDevice].systemVersion, [self deviceString], [TXRequestHelper uniqueGlobalDeviceIdentifier] ];
}

+ (NSString *) uniqueGlobalDeviceIdentifier
{
    NSString *uniqueIdentifier = nil;
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] < 7.0) {
        NSString *macaddress = [[UIDevice currentDevice] macaddress];
        uniqueIdentifier = [macaddress stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    else
    {
        uniqueIdentifier = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return uniqueIdentifier;
    
}

- (NSString*)deviceString
{
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    NSLog(@"NOTE: Unknown device type: %@", deviceString);
    return deviceString;
}


@end
