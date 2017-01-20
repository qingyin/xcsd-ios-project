//
//  XCSDTestManager.h
//  Pods
//
//  Created by gaoju on 16/7/26.
//
//

#import <TXChatSDK/TXChatSDK.h>
#import "XCSDTest.pb.h"

@interface XCSDTestManager : TXChatManagerBase

+ (void)fetchTest:(NSInteger) userId onCompleted:(void (^)(NSError *error, XCSDPBGameTestResponse *response)) onCompleted;

@end
