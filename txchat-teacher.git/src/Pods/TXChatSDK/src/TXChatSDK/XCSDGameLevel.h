//
//  XCSDGameLevel.h
//  Pods
//
//  Created by gaoju on 16/6/27.
//
//

#import <TXChatSDK/TXChatSDK.h>
#import "TXEntityBase.h"
#import "XCSDPBGame.pb.h"

@interface XCSDGameLevel : TXEntityBase

//required int64 gameId = 1;
//required int32 level = 2;
//optional string gameName = 3;
//optional string abilityName = 4;
//optional string picUrl = 5;
//optional int32 stars = 6;

@property (nonatomic, assign)  NSInteger gameId;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, copy) NSString *gameName;

@property (nonatomic, copy) NSString *abilityName;

@property (nonatomic, copy) NSInteger stars;

- (instancetype)loadValueFromPbObject:(XCSDPBGameLevel *)xcsdHomeWork;


@end
