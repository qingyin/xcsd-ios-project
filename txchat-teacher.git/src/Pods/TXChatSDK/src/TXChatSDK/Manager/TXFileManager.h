//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"


@interface TXFileManager : TXChatManagerBase
/**
* 获取文件上传token
*/
- (void)fetchFileUploadTokenWithCompleted:(void (^)(NSError *error, NSString *token))onCompleted;

/**
* 上传文件
*/
- (void)uploadData:(NSData *)data
           uuidKey:(NSUUID *)uuidKey
     fileExtension:(NSString *)fileExtension
cancellationSignal:(BOOL (^)())cancellationSignal
   progressHandler:(void (^)(NSString *key, float percent))progressHandler
       onCompleted:(void (^)(NSError *error, NSString *serverFileKey, NSString *serverFileUrl))onCompleted;

@end