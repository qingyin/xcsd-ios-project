//
//  XCSDCourseLesson.h
//  Pods
//
//  Created by gaoju on 16/9/5.
//
//

#import "TXEntityBase.h"
#import "TXPBCourse.pb.h"
@class XCSDCourse;

@interface XCSDCourseLesson : TXEntityBase

@property (nonatomic, assign) SInt64 id;
@property (nonatomic, assign) SInt64 createOn;
@property (nonatomic, assign) SInt64 updateOn;
@property (nonatomic, assign) SInt64 courseId;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) SInt64 startOn;
@property (nonatomic, assign) SInt64 endOn;
@property (nonatomic, strong) NSString* videoUrl;
@property (nonatomic, assign) SInt64 hits;
@property (nonatomic, assign) SInt64 liveHits;
@property (nonatomic, assign) TXPBLessonLiveStatus liveStatus;
@property (nonatomic, strong) TXPBCourse* course;
@property (nonatomic, strong) NSString* pic;
@property (nonatomic, assign) SInt32 duration;
@property (nonatomic, assign) SInt32 resourceType;

+ (instancetype)loadValueFromFMResultSet:(FMResultSet *)resultSet;

+ (instancetype)loadValueFromPB:(TXPBCourseLesson *)lesson;

@end

@interface XCSDCourse : TXEntityBase

@property (nonatomic) SInt64 id;
@property (nonatomic) SInt64 createOn;
@property (nonatomic) SInt64 updateOn;
@property (nonatomic) SInt64 teacherId;
@property (nonatomic, strong) NSString* teacherName;
@property (nonatomic) SInt64 labelId;
@property (nonatomic, strong) NSString* labelName;
@property (nonatomic) TXPBCourseType type;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* pb_description;
@property (nonatomic, strong) NSString* cover;
@property (nonatomic) TXPBCourseStatus status;
@property (nonatomic) SInt64 hits;
@property (nonatomic) Float64 score;
@property (nonatomic) SInt64 scoreCnt;
@property (nonatomic) SInt64 startOn;
@property (nonatomic) SInt64 endOn;
@property (nonatomic, strong) NSString* teacherDesc;
@property (nonatomic, strong) NSString* teacherAvatar;

@end
