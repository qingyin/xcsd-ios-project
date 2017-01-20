//
//  XCSDDataReportDao.m


#import "XCSDDataReportDao.h"

@implementation XCSDDataReportDao{

}

-(void) insertDR:(XCSDDataReport*)dr  error:(NSError **)outError{
	NSString *sql = @"insert into tblDataReport(userId,eventType,bid,timestamp,extendedInfo)values(?,?,?,?,?)";

	dr.extendedInfo = (dr.extendedInfo ? dr.extendedInfo : @"");
	dr.bid = (dr.bid ? dr.bid : @"");
	[_databaseQueue inDatabase:^(FMDatabase *db) {
		if (![db executeUpdate:sql
		  withErrorAndBindings:outError,
			  @(dr.userId),
			  @(dr.eventType),
			  dr.bid,
			  @(dr.timestamp),
			  dr.extendedInfo
			  ]) {
			FILL_OUT_ERROR_IF_NULL(sql);
		}
	}];
}

-(void) updateDRState:(int64_t)serialNo drid:(int64_t)drid{
	NSString *sql = @"update tblDataReport set sendedState=1,serialNo=? where id=?";
	
	[_databaseQueue inDatabase:^(FMDatabase *db) {
		if (![db executeUpdate:sql withErrorAndBindings:nil, @(serialNo),@(drid)]) {
			//FILL_OUT_ERROR_IF_NULL(sql);
		}
	}];
}
-(void) deleteDR:(int64_t)serialNo{
	NSString *sql = @"DELETE FROM tblDataReport where serialNo=?";
	
	[_databaseQueue inDatabase:^(FMDatabase *db) {
		[db executeUpdate:sql, @(serialNo)];
	}];
}
-(NSMutableArray*) getDR:(int)count error:(NSError **)outError{
	__block NSMutableArray *dr = [[NSMutableArray alloc] init];
	NSString *sql = @"SELECT * FROM tblDataReport WHERE sendedState=0 LIMIT 0,?";
	
	[_databaseQueue inDatabase:^(FMDatabase *db) {
		FMResultSet *resultSet = [db executeQuery:sql, @(count)];
		while (resultSet.next) {
			XCSDDataReport *xcDR = [[[XCSDDataReport alloc] init] loadValueFromFMResultSet:resultSet];
			[dr addObject:xcDR];
		}
		[resultSet close];
	}];
	return dr;
}

@end
