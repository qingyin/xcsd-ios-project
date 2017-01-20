//
//  XCSDLearningAbilityManager.h
//  Pods
//
//  Created by gaoju on 16/7/20.
//
//

//#import <TXChatSDK/TXChatSDK.h>
#import "TXChatManagerBase.h"
#import "XCSDLearningAbility.pb.h"

@interface XCSDLearningAbilityManager : TXChatManagerBase

- (void)fetchHomeworkResult:(NSInteger) childId onCompleted:(void(^)(NSError *error, XCSDPBAbilityStatResponse *abilityDetails)) onCompleted;

- (void)fetchGameStatus:(NSInteger) userId ability:(XCSDPBAbility) ability onCompleted:(void(^)(NSError *error, NSInteger totalScore, NSArray *gameList)) onCompleted;

@end
