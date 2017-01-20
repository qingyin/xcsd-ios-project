//
//  TXVideoCacheManager.h
//  TXChatParent
//
//  Created by 陈爱彬 on 15/10/8.
//  Copyright © 2015年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFDownloadRequestOperation;
@interface TXVideoCacheManager : NSObject

//单例
+ (TXVideoCacheManager *)sharedManager;

//通过URL读取缓存的视频路径，如果为nil说明该视频尚未下载到本地
- (NSString *)videoCachePathForURL:(NSString *)urlString;

//下载视频
- (AFDownloadRequestOperation *)downloadVideoWithURL:(NSString *)urlString
                                            progress:(void(^)(CGFloat progress))progressBlock
                                         onCompleted:(void(^)(NSString *localFileURLString,NSError *error))onCompleted;

//取消视频下载
- (void)cancelDownloadVideoWithOperation:(AFDownloadRequestOperation *)operation;


//删除所有缓存的亲子圈视频
- (void)removeAllCachedCircleVideo;

/**
 *  复制视频文件到缓存目录
 *
 *  @param path     要被复制的视频的路径
 *  @param fileUrl  服务端的文件url地址，用来做md5之后匹配文件名
 *  @param isDelete 是否删除原文件
 */
- (void)copyVideoToCachedFolderWithPath:(NSURL *)path
                          serverFileUrl:(NSString *)fileUrl
                     deleteOriginalFile:(BOOL)isDelete;

@end
