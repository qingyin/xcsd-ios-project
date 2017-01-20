//
//  GameManager.h
//  TXChatTeacher
//
//  Created by apple on 16/7/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EventViewController;

@interface GameManager : NSObject
{
    NSString* userToken;
    int64_t userId;
    BOOL enterGameFlag;
}

+(instancetype)getInstance;

-(void)resetData;

-(EventViewController *)createGameLobbyViewController;
-(EventViewController *)createGameTestViewController:(NSString*)gameList
									 isFirstTest:(Boolean)isFirstTest
										  testId:(NSInteger)testId;
-(EventViewController *)createGameHomeWorkViewController:(NSString*)gameList
											memberId:(int64_t) memberId
											childUserId:(int64_t) childUserId;


-(BOOL)getEnterGameFlag;
-(int64_t)getEnterGameUserId;
@end
