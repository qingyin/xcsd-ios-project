//
//  XCSDDataReportDao.h


#import "TXChatDaoBase.h"
#import "XCSDDataReport.h"

@interface XCSDDataReportDao : TXChatDaoBase

-(void) insertDR:(XCSDDataReport*)dr error:(NSError **)outError;

-(void) updateDRState:(int64_t)serialNo drid:(int64_t)drid;

-(void) deleteDR:(int64_t)serialNo;

-(NSMutableArray*) getDR:(int)count error:(NSError **)outError;

@end
