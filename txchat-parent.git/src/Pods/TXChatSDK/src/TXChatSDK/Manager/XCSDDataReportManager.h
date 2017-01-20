//
//  XCSDDataReportManager.h
//  Pods
//
//  Created by gaoju on 16/7/26.
//
//

#import <Foundation/Foundation.h>
#import "TXChatManagerBase.h"
#import "XCSDDataProto.pb.h"

@interface XCSDDataReportManager : TXChatManagerBase

-(void)reportNow;

-(void)reportEvent:(XCSDPBEventType)eType;

-(void)reportEventNow:(XCSDPBEventType)eType
			   completed:(void(^)(NSError *error)) completed;

-(void)reportEventBid:(XCSDPBEventType)eType
				  bid:(NSString *)bid;


-(void)reportGameData:(XCSDPBEventType)eType
			  bid:(NSString*)bid
		   userId:(int64_t)userid;

-(void)reportExtendedInfo:(XCSDPBEventType)eType
					  bid:(NSString*)bid
				   userId:(int64_t)userid
			 extendedInfo:(NSString*)extendedInfo;

-(void)turnTimerOnOff:(BOOL)onOff;


- (void)reportNowCompleted:(void(^)(NSError *error)) completed;

@end
