//
//  XCSDTestManager.m
//  Pods
//
//  Created by gaoju on 16/7/26.
//
//

#import "XCSDTestManager.h"
#import "TXApplicationManager.h"

@implementation XCSDTestManager

+ (void)fetchTest:(NSInteger)userId onCompleted:(void (^)(NSError *, XCSDPBGameTestResponse *))onCompleted{
    
    XCSDPBGameTestRequestBuilder *builder = [XCSDPBGameTestRequest builder];
    builder.userId = userId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/game_test" token:[TXApplicationManager sharedInstance].currentToken bodyData:[builder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
        
        NSError *innerError = nil;
        
        XCSDPBGameTestResponse *testResponse;
        
        TX_GO_TO_COMPLETED_IF_ERROR(error);
        TX_PARSE_PB_OBJECT(XCSDPBGameTestResponse, testResponse);
        
    completed:
        {
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            TX_RUN_ON_MAIN(
                           onCompleted(innerError, testResponse);
                           );
        }
    }];
}

@end
