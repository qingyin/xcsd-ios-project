//
// Created by lingqingwan on 6/28/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXChatClientBase.h"


@implementation TXChatClientBase {
    NSOperationQueue *_operationQueue;
}

- (TXChatClientBase *)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)sendRequest:(NSString *)url
              token:(NSString *)token
           bodyData:(NSData *)bodyData
        onCompleted:(void (^)(NSError *error, TXPBResponse *response))onCompleted {
    TXPBRequestBuilder *txpbRequestBuilder = [TXPBRequest builder];
    txpbRequestBuilder.url = url;
    txpbRequestBuilder.token = token;
    txpbRequestBuilder.version = _version;
    txpbRequestBuilder.body = bodyData;

    TXPBRequest *txpbRequest = [txpbRequestBuilder build];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:TX_CHAT_SERVER_ENDPOINT]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long) txpbRequest.data.length] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setHTTPBody:txpbRequest.data];
    [urlRequest setTimeoutInterval:15];

    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:_operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSError *innerError;
                               TXPBResponse *txpbResponse;

                               //处理请求错误
                               if (error) {
                                   switch (error.code) {
                                       case NSURLErrorTimedOut: {
                                           innerError = TX_ERROR_MAKE_WITH_URL(TX_CLIENT_STATUS_TIMEOUT, TX_CLIENT_STATUS_TIMEOUT_DESC, url);
                                           break;
                                       }
                                       case NSURLErrorCannotConnectToHost: {
                                           innerError = TX_ERROR_MAKE_WITH_URL(error.code, @"无法连接到服务器", url);
                                           break;
                                       }
                                       default: {
                                           innerError = TX_ERROR_MAKE_WITH_URL(error.code, @"服务请求错误", url);
                                       }
                                   }
                                   goto completed;
                               }

                               //处理http code状态
                               NSInteger httpStatusCode = [(NSHTTPURLResponse *) response statusCode];
                               switch (httpStatusCode) {
                                   case 200: {
                                       //Do nothing
                                       break;
                                   }
                                   case 403: {
                                       innerError = TX_ERROR_MAKE_WITH_URL(TX_CLIENT_STATUS_UNAUTHORIZED, TX_CLIENT_STATUS_UNAUTHORIZED_DESC, url);
                                       goto completed;
                                   }
                                   case 404: {
                                       innerError = TX_ERROR_MAKE_WITH_URL(TX_CLIENT_STATUS_UN_KNOW_ERROR, @"服务器暂时离开了(404)", url);
                                       goto completed;
                                   }
                                   default: {
                                       innerError = TX_ERROR_MAKE_WITH_URL(-httpStatusCode, [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding], url);
                                       goto completed;
                                   }
                               }

                               @try {
                                   txpbResponse = [TXPBResponse parseFromData:data];
                               }
                               @catch (NSException *e) {
                                   innerError = TX_ERROR_MAKE_WITH_URL(TX_CLIENT_STATUS_PB_PARSE_ERROR, e.name, url);
                                   goto completed;
                               }

                               //处理协议code状态
                               switch (txpbResponse.status) {
                                   case TX_CLIENT_STATUS_OK: {
                                       break;
                                   };
                                   case 403: {
                                       innerError = TX_ERROR_MAKE_WITH_URL(TX_CLIENT_STATUS_UNAUTHORIZED, txpbResponse.statusTxt, url);
                                       goto completed;
                                   }
                                   default: {
                                       innerError = TX_ERROR_MAKE_WITH_URL(txpbResponse.status, txpbResponse.statusTxt, url);
                                       goto completed;
                                   }
                               }

                               if (txpbResponse.status != TX_CLIENT_STATUS_OK) {
                                   innerError = TX_ERROR_MAKE_WITH_URL(txpbResponse.status, txpbResponse.statusTxt, url);
                                   goto completed;
                               }

                               completed:
                               onCompleted(innerError, txpbResponse);
                           }];
}


@end