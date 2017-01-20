//
//  GameManager.m
//  TXChatTeacher
//
//  Created by apple on 16/7/21.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "GameManager.h"

#import "GameMainController.h"

@interface GameManager()

-(NSString*)getGameLobbyArgsStr;
//gameList:"1_2;3_4"--->1->gameId;2->level;
-(NSString*)getGameTestArgsStr:(NSString*)gameList
				   isFirstTest:(Boolean)isFirstTest
						testId:(NSInteger)testId;
//gameList:"1_2;3_4"--->1->gameId;2->level;
-(NSString*)getGameHomeWorkArgsStr:(NSString*) gameList
						  memberId:(int64_t) memberId
						childUserId:(int64_t) childUserId;
-(NSString*)getJsonStr:(NSString*)gameList
				  key1:(NSString*)key1
				  key2:(NSString*)key2
                  key3:(NSString*)key3
                  key4:(NSString*)key4;

@end


@implementation GameManager

-(id)init
{
	self = [super init];
	if (self) {
		[self resetData];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:KUpdateToken object:nil];
	}
	return self;
}

+(instancetype)getInstance
{
	static dispatch_once_t once;
	static id instance;
	dispatch_once(&once,^{
		instance = [[self alloc]init];
	});
	return instance;
}
-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:KUpdateToken
												  object:nil];
}

-(void)resetData
{
	NSDictionary *dict = [[TXChatClient sharedInstance] getCurrentUserProfiles:nil];		if (dict) {
		userToken = [dict valueForKey:TX_PROFILE_KEY_CURRENT_TOKEN] ? dict[TX_PROFILE_KEY_CURRENT_TOKEN] : @"";
	}
    
    userToken = [TXApplicationManager sharedInstance].currentToken;
	
	TXUser * user = [[TXChatClient sharedInstance]getCurrentUser:nil];
	if ([user.childUserIdAndRelationsList count] == 0) {
		//         todo
	}
	else
	{
		TXPBChild *child= (TXPBChild*)user.childUserIdAndRelationsList[0];
		userId = child.userId;//[NSNumber numberWithLongLong:child.userId];
	}
}

-(NSString*)getGameLobbyArgsStr
{
    enterGameFlag = true;
	NSString* argsStr = @"action=10001&";
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"token=%@&",userToken]];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"memberId=%lld",userId]];
	
	return argsStr;
}

-(NSString*)getGameTestArgsStr:(NSString*)gameList
				   isFirstTest:(Boolean)isFirstTest
						testId:(NSInteger)testId
{
    enterGameFlag = false;
	NSString* argsStr = @"action=10003&";
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"token=%@&",userToken]];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"memberId=%lld&",userId]];
	
	NSString* jsonStr = [self getJsonStr:gameList key1:@"gameId" key2:@"level" key3:@"abilityId" key4:@"hasGuide"];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"gameList=%@&",jsonStr]];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"isFirstTest=%@&",isFirstTest?@"true":@"false"]];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"testId=%ld",(long)testId]];
	
	return argsStr;
}


-(NSString*)getGameHomeWorkArgsStr:(NSString*) gameList
						  memberId:(int64_t) memberId
						childUserId:(int64_t) childUserId
{
    enterGameFlag = false;
	NSString* argsStr = @"action=10004&";
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"token=%@&",userToken]];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"memberId=%lld&",memberId]];
	
	NSString* jsonStr = [self getJsonStr:gameList key1:@"gameId" key2:@"level" key3:@"abilityId" key4:@"hasGuide"];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"taskList=%@&",jsonStr]];
	argsStr = [argsStr stringByAppendingString:[NSString stringWithFormat:@"childUserId=%lld",childUserId]];

	return argsStr;
}



-(EventViewController *)createGameLobbyViewController
{
	GameMainController *avc = [[GameMainController alloc] init];
	avc.param = [self getGameLobbyArgsStr];
	return avc;
}

//gameList:"1#2$5_true;3#7$9_true"--->1->gameId;2->level;5->abilityId,true->hasGuide
//[{\"gameId\":1,\"level\":2,\"abilityId\":5,\"hasGuide\":\"true\"},{\"gameId\":1,\"level\":2,\"abilityId\":5,\"hasGuide\":\"true\"}]
-(UIViewController*)createGameTestViewController:(NSString*)gameList
									 isFirstTest:(Boolean)isFirstTest
										  testId:(NSInteger)testId
{
	GameMainController *avc = [[GameMainController alloc] init];
	avc.param = [self getGameTestArgsStr:gameList isFirstTest:isFirstTest testId:testId];
	return avc;
}

//gameList:"1#2$5_true;3#7$9_true"--->1->gameId;2->level;5->abilityId,true->hasGuide
//[{\"gameId\":1,\"level\":2,\"abilityId\":5,\"hasGuide\":\"true\"},{\"gameId\":1,\"level\":2,\"abilityId\":5,\"hasGuide\":\"true\"}]
-(UIViewController*)createGameHomeWorkViewController:(NSString*)gameList
											memberId:(int64_t) memberId
										  childUserId:(int64_t) childUserId
{
	GameMainController *avc = [[GameMainController alloc] init];
	avc.param = [self getGameHomeWorkArgsStr:gameList memberId:memberId childUserId:childUserId];
	return avc;
}

-(NSString*)getJsonStr:(NSString*)gameList
				  key1:(NSString*)key1
				  key2:(NSString*)key2
				  key3:(NSString*)key3
				  key4:(NSString*)key4
{
	//gameList:"1#2$5_true;3#7$9_true"--->1->gameId;2->level;5->abilityId,true->hasGuide
	//[{\"gameId\":1,\"level\":2,\"abilityId\":5,\"hasGuide\":\"true\"},{\"gameId\":1,\"level\":2,\"abilityId\":5,\"hasGuide\":\"true\"}]
	NSUInteger len = [gameList length];
	if (len == 0) {
		return @"[]";
	}
	NSString* temp =@"";
	temp = [temp stringByAppendingString:[NSString stringWithFormat:@"[{\"%@\":",key1]];
	NSMutableString *mstr = [[NSMutableString alloc] initWithString:temp];
	NSString* strEnd = [gameList substringFromIndex:(len-1)];
	if([strEnd compare:@";"] == 0){
		[mstr appendString:[gameList substringToIndex:(len-1)]];
	}
	else{
		[mstr appendString:gameList];
	}
	
	NSString* search1 = @"#";
	NSString* search2 = @"$";
	NSString* search3 = @"_";
	NSString* search4 = @";";
	
	NSString* replace1 = @"";
	replace1 = [replace1 stringByAppendingString:[NSString stringWithFormat:@",\"%@\":",key2]];
	
	NSString* replace2 = @"";
	replace2 = [replace2 stringByAppendingString:[NSString stringWithFormat:@",\"%@\":",key3]];
	
	NSString* replace3 = @"";
	replace3 = [replace3 stringByAppendingString:[NSString stringWithFormat:@",\"%@\":\"",key4]];
	NSString* replace4 = @"";
	replace4 = [replace4 stringByAppendingString:[NSString stringWithFormat:@"\"},{\"%@\":",key1]];
	
	NSRange substr = [mstr rangeOfString:search1];
	while (substr.location != NSNotFound) {
		[mstr replaceCharactersInRange:substr withString:replace1];
		substr = [mstr rangeOfString:search1];
	}
	
	substr = [mstr rangeOfString:search2];
	while (substr.location != NSNotFound) {
		[mstr replaceCharactersInRange:substr withString:replace2];
		substr = [mstr rangeOfString:search2];
	}
	
	substr = [mstr rangeOfString:search3];
	while (substr.location != NSNotFound) {
		[mstr replaceCharactersInRange:substr withString:replace3];
		substr = [mstr rangeOfString:search3];
	}
	
	substr = [mstr rangeOfString:search4];
	while (substr.location != NSNotFound) {
		[mstr replaceCharactersInRange:substr withString:replace4];
		substr = [mstr rangeOfString:search4];
	}
	
	[mstr appendString:@"\"}]"];
	return mstr;
}

-(BOOL)getEnterGameFlag
{
    return enterGameFlag;
}
-(int64_t)getEnterGameUserId
{
    return userId;
}

@end
