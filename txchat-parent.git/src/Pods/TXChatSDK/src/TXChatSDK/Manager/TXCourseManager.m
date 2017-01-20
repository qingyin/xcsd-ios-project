//
//  TXCourseManager.m
//  TXChatSDK
//
//  Created by shengxin on 16/4/6.
//  Copyright © 2016年 lingiqngwan. All rights reserved.
//

#import "TXCourseManager.h"
#import "TXHttpClient.h"
#import "TXApplicationManager.h"
#import "XCSDCourseLesson.h"

//static NSString *testToken = @"09d5d432c11846fd9521e8ecd541e173";
//static NSString *token = [TXApplicationManager sharedInstance].currentToken;

@implementation TXCourseManager

#pragma mark - Public
/**
 *  微家园列表页
 *
 *  @param aPage
 *  @param courses 返回课程数组
 */


- (void)fetchCourseList:(NSInteger)aPage
        onCompleted:(void (^)(NSError *error, NSArray *lessons,BOOL hasMore))onCompleted{
    TXPBFetchCourseLessonListRequestBuilder *requestBuilder = [TXPBFetchCourseLessonListRequest builder];
    requestBuilder.page = aPage;
    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_course_lesson_list"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       
                                    TXPBFetchCourseLessonListResponse *txpbFetchCourseListResponse;
      
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchCourseLessonListResponse, txpbFetchCourseListResponse);
                                       
                                       [[TXApplicationManager sharedInstance].currentUserDbManager.courseDao deleteAllCourse];
                                       for (TXPBCourseLesson *pbLesson in txpbFetchCourseListResponse.lessons) {
                                           
                                           XCSDCourseLesson *lesson = [XCSDCourseLesson loadValueFromPB:pbLesson];
                                           
                                           [[TXApplicationManager sharedInstance].currentUserDbManager.courseDao addCourse:lesson];
                                       }
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                          onCompleted(innerError, txpbFetchCourseListResponse.lessons,txpbFetchCourseListResponse.hasMore);
                                                          );
                                       }
                                   }];
    
}

/**
 *  目录列表
 *
 *  @param aCourseId
 */
- (void)fetchCourseLessonId:(NSInteger)aCourseId
        onCompleted:(void (^)(NSError *error, NSArray *lessons))onCompleted{
    TXPBFetchCourseLessonRequestBuilder *requestBuilder = [TXPBFetchCourseLessonRequest builder];
    requestBuilder.courseId = aCourseId;
    
    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_course_lesson"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       
                                       TXPBFetchCourseLessonResponse *txpbFetchCourseLessonResponse;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchCourseLessonResponse, txpbFetchCourseLessonResponse);
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                         onCompleted(innerError, txpbFetchCourseLessonResponse.lessons);
                                                          );
                                       }
                                   }];
    
}

/**
 *  评论列表
 */
- (void)fetchCourseLessonId:(NSInteger)aCourseId
                   andMaxId:(NSInteger)aMaxId
                onCompleted:(void (^)(NSError *error, NSArray *comments,BOOL hasMore))onCompleted{
    TXPBFetchCourseCommentRequestBuilder *requestBuilder = [TXPBFetchCourseCommentRequest builder];
    requestBuilder.courseId = aCourseId;
    requestBuilder.maxId = aMaxId;
    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_course_comment"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       
                                       TXPBFetchCourseCommentResponse *txpbTXPBFetchCourseCommentResponse;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchCourseCommentResponse, txpbTXPBFetchCourseCommentResponse);
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                               onCompleted(innerError, txpbTXPBFetchCourseCommentResponse.comments,txpbTXPBFetchCourseCommentResponse.hasMore);
                                                          );
                                       }
                                   }];
}

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
                onCompleted:(void (^)(NSError *error))onCompleted{
    TXPBAddCourseCommentRequestBuilder *requestBuilder = [TXPBAddCourseCommentRequest builder];
    requestBuilder.courseId = aCourseId;
    requestBuilder.score = aScoreId;
    aContentTest = [aContentTest stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    requestBuilder.content = aContentTest;
    [[TXHttpClient sharedInstance] sendRequest:@"/add_course_comment"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                            TX_RUN_ON_MAIN(
                                               onCompleted(innerError);
                                                           );
                                       }
                                   }];
}

/**
 *  简介
 *
 *  @param aCourseId
 *  @param onCompleted
 */
- (void)fetchCourseRequestCourseId:(NSInteger)aCourseId
                       onCompleted:(void (^)(NSError *error, TXPBCourse *course))onCompleted{
    TXPBFetchCourseRequestBuilder *requestBuilder = [TXPBFetchCourseRequest builder];
    requestBuilder.courseId = aCourseId;
    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_course"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       
                                       TXPBFetchCourseResponse *txpbTXPBFetchCourseResponse;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchCourseResponse, txpbTXPBFetchCourseResponse);
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                               onCompleted(innerError,txpbTXPBFetchCourseResponse.course);
                                                          );
                                       }
                                   }];
}


/**
 *  获取评论
 */
- (void)fetchCourseComment:(NSInteger)aCourseId
               onCompleted:(void (^)(NSError *error, TXPBCourseComment *content))onCompleted{
    TXPBFetchUserCourseCommentRequestBuilder *requestBuilder = [TXPBFetchUserCourseCommentRequest builder];
    requestBuilder.courseId = aCourseId;
    [[TXHttpClient sharedInstance] sendRequest:@"/fetch_user_course_comment"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       
                                       TXPBFetchUserCourseCommentResponse *txpbTXPBFetchUserCourseCommentResponse;
                                       
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                       TX_PARSE_PB_OBJECT(TXPBFetchUserCourseCommentResponse, txpbTXPBFetchUserCourseCommentResponse);
                                       
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                          onCompleted(innerError,txpbTXPBFetchUserCourseCommentResponse.content);
                                                          );
                                       }
                                   }];
}

/**
 *  点击目录增加观看人数
 */
- (void)addPlayCourseLesson:(NSInteger)aCourseLessonId
                onCompleted:(void (^)(NSError *error))onCompleted{
    
    TXPBPlayCourseLessonRequestBuilder *requestBuilder = [TXPBPlayCourseLessonRequest builder];
    requestBuilder.courseLessonId = aCourseLessonId;
    [[TXHttpClient sharedInstance] sendRequest:@"/play_course_lesson"
                                         token:[TXApplicationManager sharedInstance].currentToken
                                      bodyData:[requestBuilder build].data
                                   onCompleted:^(NSError *error, TXPBResponse *response) {
                                       NSError *innerError = nil;
                                       TX_GO_TO_COMPLETED_IF_ERROR(error);
                                   completed:
                                       {
                                           TX_POST_NOTIFICATION_IF_ERROR(innerError);
                                           TX_RUN_ON_MAIN(
                                                          onCompleted(innerError);
                                                          );
                                       }
                                   }];
    
    
}

- (void)addCourse:(XCSDCourseLesson *)lesson{
    
    [[TXApplicationManager sharedInstance].currentUserDbManager.courseDao addCourse:lesson];
}

- (NSArray *)queryCourses:(NSInteger)courseId count:(NSInteger)count{
    
    return [[TXApplicationManager sharedInstance].currentUserDbManager.courseDao queryCourses:courseId count:count];
}
@end
