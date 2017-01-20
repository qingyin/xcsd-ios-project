//
//  XCSDTestDao.h
//  Pods
//
//  Created by gaoju on 16/8/30.
//
//

#import "TXChatDaoBase.h"
#import "XCSDTestInfo.h"

@interface XCSDTestDao : TXChatDaoBase

//- (NSArray *)queryHomeWork:(int64_t)maxhomeWorkId count:(int64_t)count error:(NSError **)outError;
//- (XCSDHomeWork *)queryLastHomework:(NSError **)outError;
//- (void)addHomeWork:(XCSDHomeWork *)homeWork error:(NSError **)outError;
//
//- (void)markHomeworkAsRead:(int64_t)homeworkId error:(NSError **)outError;
//
//- (void)deleteAllHomework;
//- (void)deleteAllHomework:(BOOL)isInbox;
//-(void)deleteHomework:(int64_t)homeWorkId;

- (NSArray *)queryTest:(NSString *) testId count:(NSInteger)count error:(NSError *) outError;

- (void)updateTest:(XCSDTestInfo *) testInfo;

- (void)addTest:(XCSDTestInfo *)testInfo error:(NSError **) outError;
- (XCSDTestInfo *)queryLastTest;

- (void)deleteAllTest;
- (void)deleteTest:(NSString *) testId;

@end
