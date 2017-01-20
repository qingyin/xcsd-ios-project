//
//  TXCourseManager.h
//  TXChatSDK
//
//  Created by shengxin on 16/4/6.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXPBCourse.pb.h"
@class XCSDCourseLesson;

@interface TXCourseManager : NSObject

/**
 *  微课堂列表页
 *
 *  @param aCourseId
 *  @param courses 返回课程数组
 */
- (void)fetchCourseList:(NSInteger)aPage
            onCompleted:(void (^)(NSError *error, NSArray *lessons,BOOL hasMore))onCompleted;

/**
 *  目录列表
 *
 *  @param aCourseId
 */
- (void)fetchCourseLessonId:(NSInteger)aCourseId
                onCompleted:(void (^)(NSError *error, NSArray *lessons))onCompleted;

/**
 *  评论列表
 *  @param aMaxId 第一次上传传Long.Max 后续上传最后一个id
 */
- (void)fetchCourseLessonId:(NSInteger)aCourseId
                   andMaxId:(NSInteger)aMaxId
                onCompleted:(void (^)(NSError *error, NSArray *comments,BOOL hasMore))onCompleted;

/**
 *  提交评论
 *
 *  @param aCourseId
 *  @param aScoreId  星星
 *  @param aContentTest 内容 直接输入textView框中的内容即可不需要转格式
 *  @param onCompleted
 */
- (void)postCourseCourseId:(NSInteger)aCourseId
                 andScoreId:(NSInteger)aScoreId
                 andContent:(NSString*)aContentTest
                onCompleted:(void (^)(NSError *error))onCompleted;

/**
 *  简介
 *
 *  @param aCourseId
 *  @param onCompleted
 */
- (void)fetchCourseRequestCourseId:(NSInteger)aCourseId
                       onCompleted:(void (^)(NSError *error, TXPBCourse *course))onCompleted;

/**
 *  获取评论
 */

- (void)fetchCourseComment:(NSInteger)aCourseId
               onCompleted:(void (^)(NSError *error, TXPBCourseComment *content))onCompleted;


/**
 *  点击目录增加观看人数
 */
- (void)addPlayCourseLesson:(NSInteger)aCourseLessonId
                onCompleted:(void (^)(NSError *error))onCompleted;


- (NSArray *)queryCourses:(NSInteger) courseId count:(NSInteger) count;

- (NSArray *)queryCourse:(XCSDCourseLesson *)lesson;

@end
