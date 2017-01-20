//
// Created by lingqingwan on 9/18/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXPBBase.pb.h"

@interface TXHttpClient : NSObject

+ (instancetype)sharedInstance;

- (void)setupWithVersion:(NSString *)version;

- (void)sendRequest:(NSString *)url
              token:(NSString *)token
           bodyData:(NSData *)bodyData
        onCompleted:(void (^)(NSError *error, TXPBResponse *response))onCompleted;
@end