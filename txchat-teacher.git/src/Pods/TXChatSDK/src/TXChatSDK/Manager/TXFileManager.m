//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "QNUploadManager.h"
#import "TXFileManager.h"
#import "QNUploadOption.h"
#import "QNResponseInfo.h"
#import "TXApplicationManager.h"

@implementation TXFileManager {
    QNUploadManager *_qnUploadManager;
}

- (TXFileManager *)init {
    if (self = [super init]) {
        _qnUploadManager = [[QNUploadManager alloc] init];
    }
    return self;
}

- (void)fetchFileUploadTokenWithCompleted:(void (^)(NSError *error, NSString *token))onCompleted {
    DDLogInfo(@"%s", __FUNCTION__);
    
    TXPBGetUploadinfoRequestBuilder *requestBuilder = [TXPBGetUploadinfoRequest builder];

    [[TXHttpClient sharedInstance] sendRequest:@"/get_uploadinfo"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TXPBGetUploadinfoResponse *getUploadInfoResponse = nil;

                                       TX_GO_TO_COMPLETED_IF_ERROR(error);

                                       TX_PARSE_PB_OBJECT(TXPBGetUploadinfoResponse, getUploadInfoResponse);

                                       completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               onCompleted(innerError, getUploadInfoResponse.token);
                                           });
                                       }
                                   }];
}

- (void)uploadData:(NSData *)data
           uuidKey:(NSUUID *)uuidKey
     fileExtension:(NSString *)fileExtension
cancellationSignal:(BOOL (^)())cancellationSignal
   progressHandler:(void (^)(NSString *key, float percent))progressHandler
       onCompleted:(void (^)(NSError *error, NSString *serverFileKey, NSString *serverFileUrl))onCompleted {
    DDLogInfo(@"%s uuidKey=%@ fileExtension=%@", __FUNCTION__,uuidKey,fileExtension );
    
    [self fetchFileUploadTokenWithCompleted:^(NSError *error, NSString *token) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleted(error, nil, nil);
            });
            return;
        }

        NSString *serverFileName = [NSString stringWithFormat:@"%@.%@", [uuidKey UUIDString], fileExtension];

        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                            progressHandler:progressHandler
                                                                     params:nil
                                                                   checkCrc:FALSE
                                                         cancellationSignal:cancellationSignal];

        [_qnUploadManager putData:data
                              key:serverFileName
                            token:token
                         complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                             NSString *serverFileUrl = [NSString stringWithFormat:@"%@/%@", TX_QINIU_DOMAIN, key];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 onCompleted(info.error, key, serverFileUrl);
                             });
                         } option:uploadOption];
    }];
}
@end