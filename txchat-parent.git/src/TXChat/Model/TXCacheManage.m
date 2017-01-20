//
//  TXCacheManage.m
//  TXChat
//
//  Created by Cloud on 15/6/12.
//  Copyright (c) 2015年 lingiqngwan. All rights reserved.
//

#import "TXCacheManage.h"
#import "TXEaseMobHelper.h"
#import "TXChatSwipeCardConversation.h"

#define kCacheDataDir                   @"Data"
#define kCacheUserInfo                  @"kCacheUserInfo"
#define kCacheCheckins                  @"kCacheCheckins"

@implementation TXCacheManage

//单例
+ (instancetype)shareInstance
{
    static TXCacheManage *_instance = nil;
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

//刷新刷卡列表
- (void)refreshCheckinDataSource
{
    [[TXChatClient sharedInstance] fetchCheckIns:LLONG_MAX onCompleted:^(NSError *error, NSArray *txCheckIns, BOOL hasMore) {
        if(error)
        {
            DDLogDebug(@"获取刷卡信息error:%@", error);
            
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_RCV_CHECKIN object:txCheckIns];
                
            });
        }

    }];
}

//获取最新的通知
-(TXChatSwipeCardConversation *)getLastCheckin
{
    NSError *error = nil;
    TXCheckIn *checkin = [[TXChatClient sharedInstance] getLastCheckIn:&error];
    if (checkin) {
        NSDictionary *dict = [self countValueForType:TXClientCountType_Checkin];
        NSInteger countValue = [dict[TXClientCountNewValueKey] integerValue];
        NSString *lastMsg;
        if (countValue > 0) {
            lastMsg = @"有新的刷卡消息";
        }else{
            lastMsg = [NSString stringWithFormat:@"%@刷卡了",checkin.parentName];
        }
        NSDictionary *checkinDict = @{@"lastMsg": lastMsg,@"time": [NSString stringWithFormat:@"%@", @(checkin.checkInTime/1000)], @"unreadNumbe":@(countValue) };
        TXChatSwipeCardConversation *checkinConversation = [[TXChatSwipeCardConversation alloc] initWithConversationAttributes:checkinDict];
        return checkinConversation;
    }
    return nil;
}

///** 当前用户信息 */
//+ (TXUser *)currentUserInfo
//{
//    NSData *data = [TXCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheUserInfo];
//    TXUser *mUserInfo = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
//    return mUserInfo;
//}
//
//+ (BOOL)setCurrentUserInfo:(TXUser *)mUserInfo
//{
//    BOOL isSucceed = NO;
//    
//    if (mUserInfo) {
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mUserInfo];
//        isSucceed = [TXCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheUserInfo data:data];
//    }
//    return isSucceed;
//}

////获取当前用户本地刷卡信息
//+ (NSArray *)getLocalCheckins{
//    NSData *data = [TXCacheManage loadCacheWithDirName:kCacheDataDir fileName:kCacheCheckins];
//    NSArray *checkins = data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
//    return checkins;
//}

////清空本地刷卡信息
//+ (BOOL)removeLocalCheckins{
//    BOOL isSucceed = NO;
//    NSData *data = [NSData data];
//    isSucceed = [TXCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheCheckins data:data];
//    return isSucceed;
//}

////添加新的刷卡信息
//+ (BOOL)addLocalCheckins:(NSArray *)checkins{
//    BOOL isSucceed = NO;
//    NSMutableArray *arr = [NSMutableArray arrayWithArray:[TXCacheManage getLocalCheckins]];
//    [arr addObjectsFromArray:checkins];
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
//    isSucceed = [TXCacheManage saveCacheWithDirName:kCacheDataDir fileName:kCacheUserInfo data:data];
//    return isSucceed;
//}

#pragma mark - Cache
/** 读取缓存 */
+ (NSData *)loadCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName
{
    NSString *filePath = [TXCacheManage isExistsCachePath:dirName fileName:fileName];
    if (filePath) {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        return data;
    }
    return nil;
}

/** 保存缓存 */
+ (BOOL)saveCacheWithDirName:(NSString *)dirName fileName:(NSString *)fileName data:(NSData *)data
{
    NSString *filePath = [self getCacheFilePath:dirName fileName:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = [TXCacheManage getCacheDirPath:dirName];
    BOOL isDir;
    BOOL isExists = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    if (!(isExists && isDir))
        [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return [data writeToFile:filePath atomically:YES];
}

/** 是否存在缓存文件 */
+ (NSString *)isExistsCachePath:(NSString *)dirName fileName:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [self getCacheFilePath:dirName fileName:fileName];
    
    BOOL isDir;
    BOOL isExists = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if (isExists && !isDir)
        return filePath;
    return nil;
}

/** 获取缓存文件路径 */
+ (NSString *)getCacheFilePath:(NSString *)dirName fileName:(NSString *)fileName
{
    NSString *filePath;
    filePath = [[TXCacheManage getCacheDirPath:dirName] stringByAppendingPathComponent:fileName.md5];
    return filePath;
}

/** 获取缓存目录路径 */
+ (NSString *)getCacheDirPath:(NSString *)dirName
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //缓存目录路径
    NSString *dirPath = [cachesPath stringByAppendingPathComponent:dirName];
    return dirPath;
}

@end
