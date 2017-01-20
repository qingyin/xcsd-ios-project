//
//  XCSDCourseLesson.m
//  Pods
//
//  Created by gaoju on 16/9/5.
//
//

#import "XCSDCourseLesson.h"

@implementation XCSDCourseLesson


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

//    NSString *sql = @"REPLACE INTO course(courseId, createOn, updateOn, title, videoUrl, pic, duration, resourceType, teacherName, teacherAvatar) VALUES(? ,? ,? ,? ,? ,? ,? ,? ,? ,?)";

+ (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet{
    
    XCSDCourseLesson *lesson = [[self alloc] init];
    TXPBCourse *course = [[TXPBCourse alloc] init];
    lesson.course = course;
    
    lesson.courseId = [resultSet intForColumn:@"courseId"];
    lesson.createOn = [resultSet intForColumn:@"createOn"];
    lesson.updateOn = [resultSet intForColumn:@"updateOn"];
    lesson.title = [resultSet stringForColumn:@"title"];
    lesson.videoUrl = [resultSet stringForColumn:@"videoUrl"];
    lesson.pic = [resultSet stringForColumn:@"pic"];
    lesson.duration = [resultSet intForColumn:@"duration"];
    lesson.resourceType = [resultSet intForColumn:@"resourceType"];
    
    [lesson.course setValue:[resultSet stringForColumn:@"teacherName"] forKey:@"teacherName"];
    [lesson.course setValue:[resultSet stringForColumn:@"teacherAvatar"] forKey:@"teacherAvatar"];
    
    return lesson;
}

+ (instancetype)loadValueFromPB:(TXPBCourseLesson *)lesson{
    
    XCSDCourseLesson *pbLesson = [[XCSDCourseLesson alloc] init];
    
    pbLesson.id = lesson.id;
    pbLesson.createOn = lesson.createOn;
    pbLesson.updateOn = lesson.updateOn;
    pbLesson.courseId = lesson.courseId;
    pbLesson.title = lesson.title;
    pbLesson.startOn = lesson.startOn;
    pbLesson.endOn = lesson.endOn;
    pbLesson.videoUrl = lesson.videoUrl;
    pbLesson.hits = lesson.hits;
    pbLesson.liveHits = lesson.liveHits;
    pbLesson.liveStatus = lesson.liveStatus;
    pbLesson.course = lesson.course;
    pbLesson.pic = lesson.pic;
    pbLesson.duration = lesson.duration;
    pbLesson.resourceType = lesson.resourceType;
    
    return pbLesson;
}

@end
