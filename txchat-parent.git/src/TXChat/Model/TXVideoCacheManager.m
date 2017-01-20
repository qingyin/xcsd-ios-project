//
//  TXVideoCacheManager.m
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/8.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import "TXVideoCacheManager.h"
#import <AFDownloadRequestOperation.h>
#import <CommonCrypto/CommonDigest.h>
#include <fcntl.h>
#include <unistd.h>

@interface TXVideoCacheManager()
{
    NSOperationQueue *_videoCacheOperationQueue;
}
@end

@implementation TXVideoCacheManager

//单例
+ (TXVideoCacheManager *)sharedManager
{
    static TXVideoCacheManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _videoCacheOperationQueue = [[NSOperationQueue alloc] init];
        _videoCacheOperationQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}
#pragma mark - Map视频PathByURL
- (NSString *)videoMD5StringForURLString:(NSString *)urlString
{
    if (!urlString || ![urlString length]) {
        return @"";
    }
    //cv即cachedVideo的简称
    NSString *md5URLString = [[self class] videoMd5StringForString:urlString];
    return [NSString stringWithFormat:@"%@.mp4",md5URLString];
}
//通过URL读取缓存的视频路径，如果为nil说明该视频尚未下载到本地
- (NSString *)videoCachePathForURL:(NSString *)urlString
{
    NSString *cacheFileName = [self cachedVideoFilePathForURL:urlString];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cacheFileName]) {
        return cacheFileName;
    }
    return nil;
}
#pragma mark - 下载视频
//下载视频
- (AFDownloadRequestOperation *)downloadVideoWithURL:(NSString *)urlString
                                            progress:(void(^)(CGFloat progress))progressBlock
                                         onCompleted:(void(^)(NSString *localFileURLString,NSError *error))onCompleted
{
    NSString *targetPath = [self cachedVideoFilePathForURL:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFDownloadRequestOperation *downloadOperation = [[AFDownloadRequestOperation alloc] initWithRequest:urlRequest targetPath:targetPath shouldResume:YES];
    [downloadOperation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile){
        CGFloat progress = totalBytesReadForFile /  (CGFloat)totalBytesExpectedToReadForFile;
        progressBlock(progress);
    }];
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        onCompleted(targetPath,nil);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if (onCompleted) {
            onCompleted(nil,error);
        }
    }];
    [_videoCacheOperationQueue addOperation:downloadOperation];
    return downloadOperation;
}
//取消视频下载
- (void)cancelDownloadVideoWithOperation:(AFDownloadRequestOperation *)operation
{
    if (!operation) {
        return;
    }
    if ([operation isFinished] || [operation isCancelled]) {
        return;
    }
    [operation cancel];
    operation = nil;
}
#pragma mark - 路径生成
- (NSString *)documentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
//删除所有缓存的亲子圈视频
- (void)removeAllCachedCircleVideo
{
    //判断当前是否有用户登录
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser || !currentUser.username || ![currentUser.username length]) {
        return;
    }
    NSString *folderPath = [self currentUserVideoCacheFolderPath:currentUser.username];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if ([fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory]) {
        NSError *error;
        [fileManager removeItemAtPath:folderPath error:&error];
    }
}
//读取/创建用户的视频缓存文件夹
- (NSString *)currentUserVideoCacheFolderPath:(NSString *)userName
{
    BOOL isDir;
    NSString *documentsDirectory = [self documentDirectoryPath];
    NSString *userFilePath = [documentsDirectory stringByAppendingPathComponent:userName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:userFilePath isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:userFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheVideoFolder = [userFilePath stringByAppendingPathComponent:@"circleCacheVideo"];
    if (![fileManager fileExistsAtPath:cacheVideoFolder isDirectory:&isDir]) {
        [fileManager createDirectoryAtPath:cacheVideoFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return cacheVideoFolder;
}
//视频下载的最终路径
- (NSString *)cachedVideoFilePathForURL:(NSString *)urlString
{
    //判断当前是否有用户登录
    TXUser *currentUser = [[TXChatClient sharedInstance] getCurrentUser:nil];
    if (!currentUser || !currentUser.username || ![currentUser.username length]) {
        return nil;
    }
    //添加当前登录用户
    NSString *userFilePath = [self currentUserVideoCacheFolderPath:currentUser.username];
    //添加缓存文件
    NSString *path =  [userFilePath stringByAppendingPathComponent:
                       [self videoMD5StringForURLString:urlString]];
    return path;
}
//复制视频文件到缓存目录
- (void)copyVideoToCachedFolderWithPath:(NSURL *)path
                          serverFileUrl:(NSString *)fileUrl
                     deleteOriginalFile:(BOOL)isDelete
{
    NSString *cachePath = [self cachedVideoFilePathForURL:fileUrl];
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:path toURL:[NSURL fileURLWithPath:cachePath] error:&error];
    if(error){
        NSLog(@"error copying file: %@", [error localizedDescription]);
    }else{
        if (isDelete) {
//            NSError *removeError = nil;
            [[NSFileManager defaultManager] removeItemAtURL:path error:nil];
//            if (removeError) {
//                NSLog(@"删除原视频文件失败:%@",removeError);
//            }else{
//                NSLog(@"删除原视频文件成功");
//            }
        }
    }

}
#pragma mark - Static
+ (NSString *)videoMd5StringForString:(NSString *)string {
    const char *str = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (uint32_t)strlen(str), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}
@end
