//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import "TXHttpClient.h"
#import "TXChatDef.h"


@implementation TXHttpClient {
    NSOperationQueue *_operationQueue;
    NSString *_version;
}

- (TXHttpClient *)init {
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)setupWithVersion:(NSString *)version {
    _version = version;
}


+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)handleResponse:(NSURLResponse *)response
                  data:(NSData *)data
                 error:(NSError *)error
                   url:(NSString *)url
           onCompleted:(void (^)(NSError *error, TXPBResponse *response))onCompleted {
    NSError *innerError;
    TXPBResponse *txpbResponse;

    //处理请求错误
    if (error) {
        switch (error.code) {
            case NSURLErrorTimedOut: {
                innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_TIMEOUT, TX_STATUS_TIMEOUT_DESC, url);
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

    //处理http code
    NSInteger httpStatusCode = [(NSHTTPURLResponse *) response statusCode];
    switch (httpStatusCode) {
        case 200: {
            //Do nothing
            break;
        }
        case 403: {
            innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_UNAUTHORIZED, TX_STATUS_UNAUTHORIZED_DESC, url);
            goto completed;
        }
        default: {
            innerError = TX_ERROR_MAKE_WITH_URL(httpStatusCode + 1000000, @"服务器错误", url);
            goto completed;
        }
    }

    //将http body内容解析成pb对象
    @try {
        txpbResponse = [TXPBResponse parseFromData:data];
    }
    @catch (NSException *e) {
        innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_PB_PARSE_ERROR, e.name, url);
        goto completed;
    }

    //处理协议code状态
    switch (txpbResponse.status) {
        case TX_STATUS_OK: {
            break;
        };
        case TX_STATUS_UNAUTHORIZED: {
            innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_UNAUTHORIZED, txpbResponse.statusTxt, url);
            goto completed;
        }
        default: {
            innerError = TX_ERROR_MAKE_WITH_URL(txpbResponse.status, txpbResponse.statusTxt, url);
            goto completed;
        }
    }

    completed:
    {
        onCompleted(innerError, txpbResponse);
    }
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
    txpbRequestBuilder.osName = @"ios";
    txpbRequestBuilder.osVersion = [UIDevice currentDevice].systemVersion;

    TXPBRequest *txpbRequest = [txpbRequestBuilder build];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:TX_CHAT_SERVER_ENDPOINT]];
    
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:txpbRequest.data];
    [urlRequest setTimeoutInterval:15];

#ifdef TX_SYNC_HTTP_REQUEST
    NSURLResponse *syncResponse;
    NSError *syncError;
    NSData *syncData;
    syncData = [NSURLConnection sendSynchronousRequest:urlRequest
                                     returningResponse:&syncResponse
                                                 error:&syncError];
    [self handleResponse:syncResponse data:syncData error:syncError url:url onCompleted:onCompleted];
#else
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:_operationQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self handleResponse:response data:data error:error url:url onCompleted:onCompleted];
                           }];
#endif
}


- (void)myHandleResponse:(NSURLResponse *)response
					data:(NSData *)data
				   error:(NSError *)error
					 url:(NSString *)url
			 onCompleted:(void (^)(NSError *error, NSData *responseData))onCompleted {
	NSError *innerError;
	//TXPBResponse *txpbResponse;
	
	//处理请求错误
	if (error) {
		switch (error.code) {
			case NSURLErrorTimedOut: {
				innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_TIMEOUT, TX_STATUS_TIMEOUT_DESC, url);
				break;
			}
			case NSURLErrorCannotConnectToHost: {
				innerError = TX_ERROR_MAKE_WITH_URL(error.code, @"无法连接到服务器", url);
				break;
			}
			default: {
				innerError = TX_ERROR_MAKE_WITH_URL(error.code, @"网络异常,请检查网络", url);
			}
		}
		goto completed;
	}
	
	//处理http code
	NSInteger httpStatusCode = [(NSHTTPURLResponse *) response statusCode];
	switch (httpStatusCode) {
		case 200: {
			//Do nothing
			break;
		}
		case 403: {
			innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_UNAUTHORIZED, TX_STATUS_UNAUTHORIZED_DESC, url);
			goto completed;
		}
		default: {
			innerError = TX_ERROR_MAKE_WITH_URL(httpStatusCode + 1000000, @"服务器错误", url);
			goto completed;
		}
	}
	
	//将http body内容解析成pb对象
	@try {
		//txpbResponse = [TXPBResponse parseFromData:data];
		
	}
	@catch (NSException *e) {
		innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_PB_PARSE_ERROR, e.name, url);
		goto completed;
	}
	
	//处理协议code状态
	//	switch (txpbResponse.status) {
	//		case TX_STATUS_OK: {
	//			break;
	//		};
	//		case TX_STATUS_UNAUTHORIZED: {
	//			innerError = TX_ERROR_MAKE_WITH_URL(TX_STATUS_UNAUTHORIZED, txpbResponse.statusTxt, url);
	//			goto completed;
	//		}
	//		default: {
	//			innerError = TX_ERROR_MAKE_WITH_URL(txpbResponse.status, txpbResponse.statusTxt, url);
	//			goto completed;
	//		}
	//	}
	
completed:
	{
		onCompleted(innerError, data);
	}
}

- (void)sendRequest:(NSString *)url
			  token:(NSString *)token
		   bodyData:(NSData *)bodyData
			hostUrl:(NSString*)hostUrl
		onCompleted:(void (^)(NSError *error, NSData *responseData))onCompleted{
	//TXPBRequestBuilder *txpbRequestBuilder = [TXPBRequest builder];
	//	txpbRequestBuilder.url = url;
	//	txpbRequestBuilder.token = token;
	//	txpbRequestBuilder.version = _version;
	//txpbRequestBuilder.body = bodyData;
	//	txpbRequestBuilder.osName = @"ios";
	//	txpbRequestBuilder.osVersion = [[NSBundle mainBundle].infoDictionary valueForKey:@"DTPlatformVersion"];
	
	//TXPBRequest *txpbRequest = [txpbRequestBuilder build];
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[[NSURL alloc] initWithString:hostUrl]];
	//    NSString *baseURL = [NSString stringWithFormat:@"%@http_invoke",[[TXSystemManager sharedManager] webBaseUrlString]];
	//    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:baseURL]];
	
	[urlRequest setHTTPMethod:@"POST"];
	//[urlRequest setHTTPBody:txpbRequest.data];
	[urlRequest setHTTPBody:bodyData];
	[urlRequest setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	//[urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[urlRequest setTimeoutInterval:15];
	
#ifdef TX_SYNC_HTTP_REQUEST
	NSURLResponse *syncResponse;
	NSError *syncError;
	NSData *syncData;
	syncData = [NSURLConnection sendSynchronousRequest:urlRequest
									 returningResponse:&syncResponse
												 error:&syncError];
	[self handleResponse:syncResponse data:syncData error:syncError url:url onCompleted:onCompleted];
#else
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:_operationQueue
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
							   [self myHandleResponse:response data:data error:error url:url onCompleted:onCompleted];
						   }];
#endif
}

@end