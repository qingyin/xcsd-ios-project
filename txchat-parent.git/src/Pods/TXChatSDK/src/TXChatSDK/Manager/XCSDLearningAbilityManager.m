//
//  XCSDLearningAbilityManager.m
//  Pods
//
//  Created by gaoju on 16/7/20.
//
//

#import "XCSDLearningAbilityManager.h"
#import "XCSDLearningAbility.pb.h"
#import "TXHttpClient.h"
#import "TXApplicationManager.h"

@implementation XCSDLearningAbilityManager

- (void)fetchHomeworkResult:(NSInteger)childId onCompleted:(void (^)(NSError *, XCSDPBAbilityStatResponse *))onCompleted{
    
    XCSDPBAbilityStatRequestBuilder *builder = [XCSDPBAbilityStatRequest builder];
    builder.childUserId = childId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/learning_ability" token:[TXApplicationManager sharedInstance].currentToken bodyData:[builder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
       
        NSError *innerError = nil;
        XCSDPBAbilityStatResponse *evaluationResponse;
        
        TX_GO_TO_COMPLETED_IF_ERROR(innerError);
        
        TX_PARSE_PB_OBJECT(XCSDPBAbilityStatResponse, evaluationResponse);
        
        completed:{
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                onCompleted(innerError, evaluationResponse);
            });
        }
    }];
}

- (void)fetchGameStatus:(NSInteger) userId ability:(XCSDPBAbility) ability onCompleted:(void (^)(NSError *, NSInteger, NSArray *)) onCompleted{
    
    XCSDPBAbilityScoreRequestBuilder *builder = [XCSDPBAbilityScoreRequest builder];
    builder.userId = userId;
    builder.ability = ability;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/learning_ability/game_stat" token:[TXApplicationManager sharedInstance].currentToken bodyData:[builder build].data onCompleted:^(NSError *error, TXPBResponse *response) {
            
        NSError *innerError = nil;
            
        XCSDPBAbilityScoreResponse *scoreResponse;
        NSMutableArray *scoreArr = [NSMutableArray arrayWithCapacity:scoreResponse.gameList.count];
        
        
        TX_GO_TO_COMPLETED_IF_ERROR(innerError);
        
        TX_PARSE_PB_OBJECT(XCSDPBAbilityScoreResponse, scoreResponse);
        
        for (XCSDPBAbilityScoreResponseGameScore *gameScore in scoreResponse.gameList) {
            [scoreArr addObject:gameScore];
        }
            
        completed:{
            TX_POST_NOTIFICATION_IF_ERROR(innerError);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                onCompleted(innerError, scoreResponse.totalScore, scoreArr.copy);
            });
        }
    }];
}

@end
