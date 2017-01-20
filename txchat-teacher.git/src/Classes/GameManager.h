//
//  GameManager.h
//  TXChatTeacher
//
//  Created by apple on 16/7/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject
{
	NSString* userToken;
	int64_t userId;
	BOOL enterGameFlag;
}

+(instancetype)getInstance;
-(void)resetData;

-(UIViewController*)createGameLobbyViewController;
-(UIViewController*)createGameTestViewController:(NSString*)gameList
									 isFirstTest:(NSInteger)isFirstTest
										  testId:(NSInteger)testId;
-(UIViewController*)createGameHomeWorkViewController:(NSString*)gameList;

-(BOOL)getEnterGameFlag;
-(int64_t)getEnterGameUserId;

@end
