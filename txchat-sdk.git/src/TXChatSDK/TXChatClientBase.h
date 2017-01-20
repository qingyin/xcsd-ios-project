//
// Created by lingqingwan on 6/28/15.
// Copyright (c) 2015 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXChatDef.h"
#import "TXPBBase.pb.h"
#import "TXPBChat.pb.h"

@interface TXChatClientBase : NSObject {
    NSString *_version;
}

- (void)sendRequest:(NSString *)url
              token:(NSString *)token
           bodyData:(NSData *)bodyData
        onCompleted:(void (^)(NSError *error, TXPBResponse *response))onCompleted;
@end