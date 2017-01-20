//
//  XCSDDataReportManager.m
//  Pods
//
//  Created by gaoju on 16/7/26.
//
//

#import "XCSDDataReportManager.h"
#import "TXApplicationManager.h"
#import "XCSDDataReportDao.h"

@implementation XCSDDataReportManager{
	int waitReportDataNum;
	BOOL reportingFlag;
	NSMutableArray *reportingReportData;
	int64_t reportingSerialNo;
	NSTimer *_timer;
}

#define KDataReport @"KDataReport"


#define WaitReportDataMaxNum 30
#define CountDown (60*2)  //5分钟

-(instancetype)init
{
	self = [super init];
	if (self) {
		reportingSerialNo = 0;
		waitReportDataNum = 0;
		reportingFlag = false;
		reportingReportData = [[NSMutableArray alloc]init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveObjData:) name:KDataReport object:nil];
		
		[self resetTimer];
		_timer = [NSTimer scheduledTimerWithTimeInterval:CountDown target:self selector:@selector(OnMyTime:) userInfo:nil repeats:YES];
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

-(void)turnTimerOnOff:(BOOL)onOff
{
	if (onOff) {
		//开启定时器
		[_timer setFireDate:[NSDate distantPast]];
	}else{
		//关闭定时器
		[_timer setFireDate:[NSDate distantFuture]];
	}
}
- (void)OnMyTime:(NSTimer *)timer
{
	NSLog(@"OnMyTime----------------");
	[self sendNotification:nil obj:nil];
}

- (void)resetTimer {
	if (!_timer)
		return;
	
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self resetTimer];
}

-(void)receiveObjData:(NSNotification*)notification
{
	NSLog(@"receiveObjData------: %@",notification);
	if(notification.object && [notification.object isKindOfClass:[XCSDPBEvent class]]){
		
		[[TXApplicationManager sharedInstance].currentUserDbManager.dataReportDao insertDR:[notification object] error:nil];
		
		waitReportDataNum = waitReportDataNum + 1;
		if (waitReportDataNum >= WaitReportDataMaxNum) {
            [self reportManager:nil];
		}
	}else{
		[self reportManager:nil];
	}
}

-(void)reportManager:(void (^)(NSError *))completed
{
	NSLog(@"---------reportManager-------");
	if (reportingFlag) {
		NSLog(@"---------reportManager------------is reporting");
		return;
	}
	if ([reportingReportData count] > 0) {
		NSLog(@"---------reportManager------------is reporting--count=%lu",(unsigned long)[reportingReportData count]);
		
		[self sendDataReport:reportingSerialNo eList:reportingReportData onCompleted:nil];
		return;
	}
	
	NSLog(@"---------reportManager-----getData1--");
	NSMutableArray *dataRes = [[TXApplicationManager sharedInstance].currentUserDbManager.dataReportDao getDR:WaitReportDataMaxNum error:nil];
	NSLog(@"---------reportManager-----getData2--");
	if (dataRes && dataRes.count > 0) {
		NSLog(@"---------reportManager-----getData3--%lu",(unsigned long)dataRes.count);
		reportingFlag = true;
		//waitReportDataNum = waitReportDataNum - dataRes.count;
		NSMutableArray *dataSending = [NSMutableArray arrayWithCapacity:dataRes.count];
		
		reportingSerialNo = [NSDate date].timeIntervalSince1970 * 1000;
		for (int i=0; i<dataRes.count; i++) {
			XCSDDataReport* data = dataRes[i];
			XCSDPBEventBuilder* inEventBuilder = [XCSDPBEvent builder];
			
			inEventBuilder.userId = data.userId;
			[inEventBuilder setEventType:data.eventType];
			inEventBuilder.bid = data.bid;
			inEventBuilder.timestamp = data.timestamp;
			inEventBuilder.extendedInfo = data.extendedInfo;
			[dataSending addObject:[inEventBuilder build]];
			
			[[TXApplicationManager sharedInstance].currentUserDbManager.dataReportDao updateDRState:reportingSerialNo drid:data.drid];
		}
		[reportingReportData addObjectsFromArray:dataSending];
        if (completed) {
            [self sendDataReport:reportingSerialNo eList:reportingReportData onCompleted:completed];
        }else{
            [self sendDataReport:reportingSerialNo eList:reportingReportData onCompleted:nil];
        }
	}
}

//发送消息的线程
- (void)sendNotification:(NSDictionary*)dict
					 obj:(XCSDPBEvent *)obj
{
	dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(defaultQueue, ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:KDataReport object:obj userInfo:dict];
		//[[NSNotificationCenter defaultCenter] postNotificationName:KDataReport object:obj];
	});
}

- (void)sendDataReport:(int64_t)serialNo eList:(NSArray *)eList onCompleted:(void (^)(NSError *))onCompleted{
	NSLog(@"---sendDataReport--serialNo=%lld,count=%lu",serialNo,(unsigned long)[eList count]);
	
	XCSDPBReportEventRequestBuilder *builder = [XCSDPBReportEventRequest builder];
	builder.serialNo = serialNo;
	builder.sendTime = (int64_t)[NSDate date].timeIntervalSince1970 * 1000;
	[builder setEventListArray:eList];
	NSData * data = [builder build].data;
	
	[[TXHttpClient sharedInstance] sendRequest:@"/data/event"
										 token:[TXApplicationManager sharedInstance].currentToken
									  bodyData:data
								   onCompleted:^(NSError *error, TXPBResponse *response) {
		
		NSError *innerError = nil;
		
		XCSDPBReportEventResponse *testResponse;
		TX_GO_TO_COMPLETED_IF_ERROR(error);
		TX_PARSE_PB_OBJECT(XCSDPBReportEventResponse, testResponse);
		if (innerError == nil && (testResponse.result == 1 || testResponse.result == 3)) {
			if (onCompleted == nil) {
				int64_t sNo = testResponse.serialNo;
				[[TXApplicationManager sharedInstance].currentUserDbManager.dataReportDao deleteDR:sNo];
				
				NSLog(@"back---sendDataReport--serialNo=%lld--waitReportDataNum=%d--reportingCount=%lu",sNo,waitReportDataNum,(unsigned long)[reportingReportData count]);
				waitReportDataNum = waitReportDataNum - (int)[reportingReportData count];
				
				[reportingReportData removeAllObjects];
				
				NSLog(@"back---sendDataReport--reportingCount=%lu--waitReportDataNum=%d",(unsigned long)[reportingReportData count],waitReportDataNum);
				if (waitReportDataNum < 0) {
					waitReportDataNum = 0;
				}
			}else{
				NSLog(@" logout------------");
			}
		}
		reportingFlag = false;
									   
	completed:
		{
			//TX_POST_NOTIFICATION_IF_ERROR(innerError);
			if (innerError) {
				DDLogDebug(@"error---sendDataReport--->error:%@,%ld",innerError,(long)innerError.code);			reportingFlag = false;
			}
			
            if (onCompleted) {
                TX_RUN_ON_MAIN(
					onCompleted(innerError);
				);
            }
		}
	}];
}
-(void)reportNow
{
	[self sendNotification:nil obj:nil];
}

- (void)reportNowCompleted:(void (^)(NSError *))completed {
    [self reportManager:completed];
}

-(void)reportEvent:(XCSDPBEventType)eType{
	NSLog(@"-----reportEvent--%d",(int)eType);
	
	XCSDPBEventBuilder* inEventBuilder = [XCSDPBEvent builder];
	inEventBuilder.userId = [TXApplicationManager sharedInstance].currentUser.userId;
	[inEventBuilder setEventType:eType];
	inEventBuilder.timestamp = (int64_t)[NSDate date].timeIntervalSince1970 * 1000;
	
	[self sendNotification:nil obj:[inEventBuilder build]];
}

-(void)reportEventBid:(XCSDPBEventType)eType
				  bid:(NSString *)bid{
	NSLog(@"-----reportEventBid--%d--%@",(int)eType,bid);
	
	XCSDPBEventBuilder* inEventBuilder = [XCSDPBEvent builder];
	inEventBuilder.userId = [TXApplicationManager sharedInstance].currentUser.userId;
	[inEventBuilder setEventType:eType];
	inEventBuilder.bid = bid;
	inEventBuilder.timestamp = (int64_t)[NSDate date].timeIntervalSince1970 * 1000;
	
	[self sendNotification:nil obj:[inEventBuilder build]];
}

-(void)reportGameData:(XCSDPBEventType)eType
				  bid:(NSString*)bid
			   userId:(int64_t)userid{
	NSLog(@"-----reportGameData--%d--%@--%lld",(int)eType,bid,userid);
	
	XCSDPBEventBuilder* inEventBuilder = [XCSDPBEvent builder];
	inEventBuilder.userId = userid;
	[inEventBuilder setEventType:eType];
	inEventBuilder.timestamp = (int64_t)[NSDate date].timeIntervalSince1970 * 1000;
	inEventBuilder.bid = bid;
	
	[self sendNotification:nil obj:[inEventBuilder build]];
}

-(void)reportExtendedInfo:(XCSDPBEventType)eType
					  bid:(NSString*)bid
				   userId:(int64_t)userid
			 extendedInfo:(NSString*)extendedInfo{
	NSLog(@"-----reportGameData--%d--%@--%lld--%@",(int)eType,bid,userid,extendedInfo);
	
	XCSDPBEventBuilder* inEventBuilder = [XCSDPBEvent builder];
	inEventBuilder.userId = userid;
	[inEventBuilder setEventType:eType];
	inEventBuilder.bid = bid;
	inEventBuilder.extendedInfo = extendedInfo;
	inEventBuilder.timestamp = (int64_t)[NSDate date].timeIntervalSince1970 * 1000;
	
	[self sendNotification:nil obj:[inEventBuilder build]];
}

-(void)reportEventNow:(XCSDPBEventType)eType
			   completed:(void(^)(NSError *error)) completed
{
    [self reportNow];
    
	XCSDPBEventBuilder* inEventBuilder = [XCSDPBEvent builder];
	
	inEventBuilder.userId = [TXApplicationManager sharedInstance].currentUser.userId;
	[inEventBuilder setEventType:eType];
	inEventBuilder.timestamp = (int64_t)[NSDate date].timeIntervalSince1970 * 1000;
	
	NSMutableArray *dataSending = [NSMutableArray arrayWithCapacity:1];
	[dataSending addObject:[inEventBuilder build]];
	
	NSMutableArray *rd =[[NSMutableArray alloc]init];
	[rd addObjectsFromArray:dataSending];
	[self sendDataReport:[NSDate date].timeIntervalSince1970 * 1000 eList:rd onCompleted:completed];
}

@end
