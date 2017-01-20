//
//  XCSDHomeWorkDao.h
//  Pods
//
//  Created by gaoju on 16/3/15.
//
//

#import <Foundation/Foundation.h>
#import "TXChatDaoBase.h"
#import "XCSDHomeWork.h"

@interface XCSDHomeWorkDao : TXChatDaoBase{
    
}

- (NSArray *)queryHomeWork:(int64_t)maxhomeWorkId count:(int64_t)count error:(NSError **)outError;
- (XCSDHomeWork *)queryLastHomework:(NSError **)outError;
- (void)addHomeWork:(XCSDHomeWork *)homeWork error:(NSError **)outError;

- (void)markHomeworkAsRead:(int64_t)homeworkId error:(NSError **)outError;

- (void)deleteAllHomework;
- (void)deleteAllHomework:(BOOL)isInbox;
-(void)deleteHomework:(int64_t)homeWorkId;
@end
