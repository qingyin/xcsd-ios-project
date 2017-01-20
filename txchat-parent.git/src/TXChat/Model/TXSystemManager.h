//
//  TXSystemManager.h
//  TXChat
//
//  Created by 陈爱彬 on 15/6/29.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TXGlobalNoDisturbStatus) {
    TXGlobalNoDisturbStatusClose = 0,           //全局消息免打扰关闭
    TXGlobalNoDisturbStatusDay,                 //全局消息免打扰全天开启
    TXGlobalNoDisturbStatusNightOnly,           //全局消息免打扰夜间开启
};
typedef NS_ENUM(NSInteger, TXMediaPlayNetworkType) {
    TXMediaPlayNetworkType_OnlyByWifi = 0,      //只在wifi下播放
    TXMediaPlayNetworkType_All,                 //所有网络下均可播放
};
//定义外部可直接访问数据的key值
extern NSString * const kChatListNotifyDeleteFlag;
extern NSString * const kChatListLastNotifyId;
extern NSString * const kChatListSwipeCardDeleteFlag;
extern NSString * const kChatListLastSwipeCardId;
extern NSString * const kChatListGardenPostDeleteFlag;
extern NSString * const kChatListLastGardenPostId;
extern NSString * const kChatListLastAttendanceTime;
extern NSString * const kChatListHasAttendanceFlag;
extern NSString * const kChatListLastHomeWorkId;
extern NSString * const kChatListHomeWorkDeleteFlag; //add by mey


@interface TXSystemManager : NSObject

/**
 *  是否是开发版本,默认YES,当发布到Appstore时改为NO
 */
@property (nonatomic,getter=isDevVersion) BOOL devVersion;
//声音提示是否开启
@property (nonatomic,getter=isEnableGlobalSoundPlay) BOOL enableGlobalSoundPlay;
//震动提示是否开启
@property (nonatomic,getter=isEnableGlobalVibrationPlay) BOOL enableGlobalVibrationPlay;
//全局的消息免打扰状态
@property (nonatomic) TXGlobalNoDisturbStatus globalNoDisturbStatus;

/**
 *  音视频播放网络类型
 */
@property (nonatomic) TXMediaPlayNetworkType mediaNetworkType;
//当前聊天窗口的环信id,如不在聊天窗口内则为空
@property (nonatomic,copy) NSString *currentChatId;
/**
 *  是否是家长端App
 */
@property (nonatomic,readonly,getter=isParentApp) BOOL parentApp;

@property (nonatomic, strong) NSMutableArray *circleHistoryArr;

//创建单例
+ (instancetype)sharedManager;

//执行程序激活的流程
- (void)setupAppLaunchActions;

//程序从后台唤醒机制
- (void)fetchInfoWhenAppBecomeActive;

//更新环信推送配置
- (void)updateEaseMobPushNotificationOptions;

//重新登录
- (void)reLoginToServerWhenKickOffWithCompletion:(void(^)(BOOL isLoginSuccess,BOOL isInit,NSError *error))block;


//播放声音和震动
- (void)playSoundAndVibrationWithGroupId:(NSString *)groupId
                               emMessage:(EMMessage *)message;

//播放震动
- (void)playVibrationWithGroupId:(NSString *)groupId
                       emMessage:(EMMessage *)message;

//App前台时弹出提醒
- (void)showLocalNotificationOnAppInActiveWithTitle:(NSString *)title;

//清空缓存文件
- (void)clearAllUnusedCache;

//保存图片到本地cache，避免自己上传的图片二次加载
- (void)saveImageToCache:(UIImage *)image forURLString:(NSString *)urlString;

//删除本地cache的图片
- (void)deleteCacheImageForURLString:(NSString *)urlString;

//获取聊天界面保存的信息
- (NSNumber *)chatListDataForKey:(NSString *)key;
//保存聊天界面的数据
- (void)saveChatListData:(NSNumber *)data forKey:(NSString *)key;

//请求相机和麦克风的权限
- (void)requestCameraAndMicrophonePermissionWithBlock:(void(^)(BOOL cameraGranted,BOOL microphoneGranted))block;

//请求相机的权限
- (void)requestCameraPermissionWithBlock:(void(^)(BOOL cameraGranted))block;

//请求相册的权限
- (void)requestPhotoPermissionWithBlock:(void(^)(BOOL photoGranted))block;

//请求通讯录权限
-(void)CheckAddressBookAuthorization:(void (^)(bool isAuthorized))block;
//检查多媒体播放权限
- (void)checkMediaPlayAuthorization:(void(^)(BOOL authorization))block;
- (NSString *)getJSHostUrlString;

#pragma mark - 开发时的网络请求Host
// 更新自定义环境
- (void)updateCustomServerModeInfo;
//获取请求的Host
- (NSString *)requestHost;
//过滤h5的Host
- (NSString *)filtedHost;
//请求端口号
- (NSString *)requestPort;
//环信应用key
- (NSString *)easeMobAppKey;
//h5页面baseUrl
- (NSString *)webBaseUrlString;

@end
