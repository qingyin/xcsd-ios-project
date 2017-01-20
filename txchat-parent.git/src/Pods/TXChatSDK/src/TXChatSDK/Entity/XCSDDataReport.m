//
//  XCSDDataReport.m
//  Pods

#import "XCSDDataReport.h"

@implementation XCSDDataReport{

}
 


- (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
	//SET_BASE_PROPERTIES_FROM_RESULT_SET(self);
	
	_drid = [resultSet longLongIntForColumn:@"id"];
	_userId = [resultSet longLongIntForColumn:@"userId"];
	_eventType = [resultSet intForColumn:@"eventType"];
	_bid = [resultSet stringForColumn:@"bid"];
	_timestamp = [resultSet longLongIntForColumn:@"timestamp"];
	_extendedInfo = [resultSet stringForColumn:@"extendedInfo"];
	_sendedState = [resultSet intForColumn:@"sendedState"];
	_serialNo = [resultSet longLongIntForColumn:@"serialNo"];
	
	return self;
}

@end
