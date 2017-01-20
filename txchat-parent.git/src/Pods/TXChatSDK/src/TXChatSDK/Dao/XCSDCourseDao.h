//
//  XCSDCourseDao.h
//  Pods
//
//  Created by gaoju on 16/9/5.
//
//

#import "TXChatDaoBase.h"
#import "XCSDCourseLesson.h"

@interface XCSDCourseDao : TXChatDaoBase


- (NSArray *)queryCourses:(NSInteger)courseId count:(NSInteger)count;

- (void)addCourse:(XCSDCourseLesson *)lesson;

- (void)deleteAllCourse;

@end
