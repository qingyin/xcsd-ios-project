//
//  XCSDCourseDao.m
//  Pods
//
//  Created by gaoju on 16/9/5.
//
//

#import "XCSDCourseDao.h"
#import "XCSDCourseLesson.h"

@implementation XCSDCourseDao

//@property (readonly) SInt64 id;
//@property (readonly) SInt64 createOn;
//@property (readonly) SInt64 updateOn;
//@property (readonly) SInt64 courseId;
//@property (readonly, strong) NSString* title;
//@property (readonly) SInt64 startOn;
//@property (readonly) SInt64 endOn;
//@property (readonly, strong) NSString* videoUrl;
//@property (readonly) SInt64 hits;
//@property (readonly) SInt64 liveHits;
//@property (readonly) TXPBLessonLiveStatus liveStatus;
//@property (readonly, strong) TXPBCourse* course;
//@property (readonly, strong) NSString* pic;
//@property (readonly) SInt32 duration;
//@property (readonly) SInt32 resourceType;

- (void)addCourse:(XCSDCourseLesson *)lesson{
    
    NSString *sql = @"REPLACE INTO course(id, courseId, createOn, updateOn, title, videoUrl, pic, duration, resourceType, teacherName, teacherAvatar) VALUES(? ,? ,? ,? ,? ,? ,? ,? ,? ,?, ?)";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        
        NSError *error;
        
        [db executeUpdate:sql withErrorAndBindings:&error, @(lesson.id), @(lesson.courseId), @(lesson.createOn), @(lesson.updateOn), lesson.title, lesson.videoUrl, lesson.pic, @(lesson.duration), @(lesson.resourceType), lesson.course.teacherName, lesson.course.teacherAvatar];
        
        NSLog(@"%@",error);
    }];
}

- (NSArray *)queryCourses:(NSInteger)courseId count:(NSInteger)count{
    
//    NSString *sql = @"SELECT * FROM course WHERE courseId < ? ORDER BY courseId DESC LIMIT 0,?";
    NSString *sql = @"SELECT * FROM course WHERE courseId < ? LIMIT 0,?";
    
    __block NSMutableArray *courses = [NSMutableArray arrayWithCapacity:5];
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
       
        FMResultSet *resultSet = [db executeQuery:sql, @(courseId), @(count)];
        
        while (resultSet.next) {
            
            XCSDCourseLesson *lesson = [XCSDCourseLesson loadValueFromFMResultSet:resultSet];
            [courses addObject:lesson];
        }
    }];
    
    return courses.copy;
}

- (void)deleteAllCourses{
    
    NSString *sql = @"DELETE FROM course";
    
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

@end
