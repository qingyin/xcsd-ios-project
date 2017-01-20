

#import <Foundation/Foundation.h>


#import "ChildInfo.h"

#import "PreloginResponse.h"
#import "GetLocationResponse.h"

#import "LoginResponse.h"

#import "GetSchoolAgesResponse.h"

#import "GetChildListResponse.h"
#import "GetCategoryFirstResponse.h"
#import "GetCategorySecondResponse.h"

#import "GetTestsResponse.h"
#import "GetTaskDetailResponse.h"

#import "GetEvaluationResponse.h"
#import "GetAnswersResponse.h"

#import "GetTasksResponse.h"
#import "GetFollowersResponse.h"
#import "GetRankResponse.h"
#import "UploadPicRequest.h"
#import "UploadPicResponse.h"
#import "SearchUserResponse.h"
#import "RecommendResponse.h"
#import "DownloadUrlResponse.h"
#import "GetDiariesResponse.h"
#import "GetDiaryResponse.h"
#import "CommentListResponse.h"
#import "FavorListResponse.h"
#import "NotificationResponse.h"
#import "HomepageItemsResponse.h"
#import "SocialArticleResponse.h"
#import "TaskSearchFilterResponse.h"
#import "HotKeywordsResponse.h"
#import "TestListResponse.h"
#import "SearchArticleResponse.h"

#import "EduVacationListResponse.h"
#import "EduVacationResponse.h"
#import "EleArticleResponse.h"

#define kLoginV1ChWeibo @"weibo"
#define kLoginV1ChWeixin @"weixin"

#define kHotKeywordsTypeTask @"1"
#define kHotKeywordsTypeArticle @"2"

#define kFavorPostTypeDiary @"1"
#define kFavorPostTypeArticle @"2"


typedef BOOL (^EduApiBlock)(BOOL success, id response);

@interface EduApi : NSObject

+(void)checkUser:(NSString*)user completion:(EduApiBlock)completionBlock;

+(void)preloginWithCompletion:(EduApiBlock)completionBlock;

+(void)getLocationWithCompletion:(EduApiBlock)completionBlock;

+(void)registerWithUser:(NSString*)user district:(NSInteger)districtID password:(NSString*)password preloginResponse:(PreloginResponse *)preloginResponse completion:(EduApiBlock)completionBlock;


+(void)loginWithUser:(NSString*)user password:(NSString*)password preloginResponse:(PreloginResponse*)preloginResponse completion:(EduApiBlock)completionBlock;

+(void)loginV1WithUser:(NSString*)user
                    sp:(NSString*)sp
                    ch:(NSString*)ch
              nickName:(NSString*)nickName
                   pic:(NSString*)pic
           accessToken:(NSString*)accessToken
      preloginResponse:(PreloginResponse *)preloginResponse
            completion:(EduApiBlock)completionBlock;

+(void)userInfoWithToken:(NSString*)token
          viewController:(UIViewController*)viewController
              completion:(EduApiBlock)completionBlock;

+(void)updateUserWithToken:(NSString*)token
                  district:(NSInteger)districtID
                       pic:(NSString*)pic
                    gender:(NSString*)gender
                  birthday:(NSDate*)birthday
                  nickName:(NSString*)nickName
            viewController:(UIViewController*)viewController
                completion:(EduApiBlock)completionBlock;

+(void)updatePasswordWithToken:(NSString*)token password:(NSString*)password newPassword:(NSString*)newPassword preloginResponse:(PreloginResponse *)preloginResponse completion:(EduApiBlock)completionBlock;

+(void)getSchoolAgesWithCompletion:(EduApiBlock)completionBlock;

+(void)addChildWithToken:(NSString*)token
                   child:(ChildInfo*)child
              completion:(EduApiBlock)completionBlock;


+(void)getChildListWithToken:(NSString*)token
                   childType:(NSInteger)childType
                  completion:(EduApiBlock)completionBlock;


+(void)deleteChildWithToken:(NSString*)token
                    childID:(NSString*)childID
                 completion:(EduApiBlock)completionBlock;

+(void)updateChildWithToken:(NSString*)token child:(ChildInfo*)child
                 completion:(EduApiBlock)completionBlock;

+(void)getCategoryFirstWithToken:(NSString*)token
                       schoolAge:(NSString*)schoolAge
                      completion:(EduApiBlock)completionBlock;

+(void)getCategorySecondWithToken:(NSString*)token
                  categoryFirstId:(NSString*)cf
                          childID:(NSString*)childID
                       completion:(EduApiBlock)completionBlock;

+(void)getTestsWithToken:(NSString*)token
                  testID:(NSString*)testID
                 childID:(NSString*)childID
              completion:(EduApiBlock)completionBlock;


+(void)addAnswersWithToken:(NSString*)token
                    testID:(NSString*)testID
                   childID:(NSString*)childID
                   answers:(NSArray*)answers
                completion:(EduApiBlock)completionBlock;

+(void)getEvaluationWithToken:(NSString*)token
                       testID:(NSString*)testID
                      childID:(NSString*)childID
                   completion:(EduApiBlock)completionBlock;

+(void)getAnswersWithToken:(NSString*)token
                    testID:(NSString*)testID
                   childID:(NSString*)childID
                completion:(EduApiBlock)completionBlock;

+(void)getEvaluationTasksWithToken:(NSString*)token
                           childID:(NSString*)childID
                      evaluationID:(NSString*)evaluationID
                        completion:(EduApiBlock)completionBlock;

+(void)getTaskListWithToken:(NSString*)token
                    childID:(NSString*)childID
                     status:(NSString*)status
                 completion:(EduApiBlock)completionBlock;

//+(void)getTaskDetailWithToken:(NSString*)token
//                  childTaskID:(NSString*)childTaskID
//                   completion:(EduApiBlock)completionBlock;
+(void)getTaskDetailInfoWithToken:(NSString*)token
                           taskID:(NSString *)taskID
                          childID:(NSString*)childID
                       completion:(EduApiBlock)completionBlock;

//+(void)getTasksWithToken:(NSString*)token
//                 childID:(NSString*)childID
//                  status:(NSString*)status
//              completion:(EduApiBlock)completionBlock;

+(void)addTasksWithToken:(NSString*)token
                 childID:(NSString*)childID
                   tasks:(NSString*)tasks
              completion:(EduApiBlock)completionBlock;

+(void)updateTaskWithToken:(NSString*)token
                   childID:(NSString*)childID
                    taskID:(NSString*)taskID
                    status:(NSInteger)status
                completion:(EduApiBlock)completionBlock;

+(void)addFollowerWithToken:(NSString*)token
                       user:(NSString*)user
                 completion:(EduApiBlock)completionBlock;

+(void)getFollowersWithToken:(NSString*)token
                  completion:(EduApiBlock)completionBlock;

+(void)removeFollowerWithToken:(NSString*)token
                          user:(NSString*)user
                    completion:(EduApiBlock)completionBlock;


+(void)getObservablesWithToken:(NSString*)token
                    completion:(EduApiBlock)completionBlock;

+(void)removeObservableWithToken:(NSString*)token
                            user:(NSString*)user
                      completion:(EduApiBlock)completionBlock;



+(void)getRankWithToken:(NSString*)token
             completion:(EduApiBlock)completionBlock;

+(void)uploadPicWithToken:(NSString*)token
                base64Pic:(NSString*)base64Pic
                picFormat:(NSString*)picFormat
               completion:(EduApiBlock)completionBlock;

+(void)searchUserWithToken:(NSString*)token
                      user:(NSString*)user
                completion:(EduApiBlock)completionBlock;

+(void)recommendWithToken:(NSString*)token
              productType:(NSString*)productType
                      num:(NSInteger)num
               completion:(EduApiBlock)completionBlock;

+(void)downloadUrlWithToken:(NSString*)token
                 completion:(EduApiBlock)completionBlock;

+(void)addDiaryWithToken:(NSString*)token
                 childID:(NSString*)childID
                   diary:(NSString*)diary
                  picUrl:(NSString*)picUrl
                  taskID:(NSString*)taskID
              completion:(EduApiBlock)completionBlock;

+(void)getDiariesWithToken:(NSString*)token
                   childID:(NSString*)childID
                    lastID:(NSString*)lastID
                      size:(NSInteger)size
                completion:(EduApiBlock)completionBlock;

+(void)getDiaryWithToken:(NSString*)token
                  taskID:(NSString*)taskID
              completion:(EduApiBlock)completionBlock;

+(void)updateDiaryWithToken:(NSString*)token
                    diaryID:(NSString*)diaryID
                      diary:(NSString*)diary
                     picUrl:(NSString*)picUrl
                 completion:(EduApiBlock)completionBlock;

+(void)removeDiaryWithToken:(NSString*)token
                    diaryID:(NSString*)diaryID
                 completion:(EduApiBlock)completionBlock;

+(void)getShareUrlWithToken:(NSString*)token
                    childID:(NSString*)childID
                       type:(NSString*)type
                         ID:(NSString*)ID
                         ch:(NSString*)ch
                 completion:(EduApiBlock)completionBlock;


+(void)pushRegisterWithCompletion:(EduApiBlock)completionBlock;



+(void)socialDiariesWithToken:(NSString*)token
                       lastID:(NSString*)lastID
                         size:(NSInteger)size
                   completion:(EduApiBlock)completionBlock;

+(void)notificationWithToken:(NSString*)token
              viewController:(UIViewController*)viewController
                  completion:(EduApiBlock)completionBlock;

+(void)feedbackWithToken:(NSString*)token
                 contact:(NSString*)contact
                 content:(NSString*)content
          viewController:(UIViewController*)viewController
              completion:(EduApiBlock)completionBlock;

+(void)httpGetRequestWithUrl:(NSString*)url
              shouldRedirect:(BOOL)shouldRedirect
              viewController:(UIViewController*)viewController
                     showHUD:(BOOL)showHUD
                  completion:(EduApiBlock)completionBlock;

+(void)homepageItemsWithToken:(NSString*)token
                      childID:(NSString*)childID
                    schoolAge:(NSString*)schoolAge
               viewController:(UIViewController*)viewController
                   completion:(EduApiBlock)completionBlock;

+(void)socialArticleWithToken:(NSString*)token
                    articleID:(NSString*)articleID
               viewController:(UIViewController*)viewController
                   completion:(EduApiBlock)completionBlock;

+(void)taskSearchFilterWithSchoolAge:(NSString*)schoolAge
                      viewController:(UIViewController*)viewController
                          completion:(EduApiBlock)completionBlock;

+(void)taskSearchWithSchoolAge:(NSString*)schoolAge
                       keyword:(NSString*)keyword
                       subject:(NSString*)subject
                         scene:(NSString*)scene
                         count:(NSString*)count
                       childID:(NSString*)childID
                viewController:(UIViewController*)viewController
                    completion:(EduApiBlock)completionBlock;

+(void)relatedTaskWithSchoolAge:(NSString*)schoolAge
                   associateTag:(NSString*)associateTag
                 viewController:(UIViewController*)viewController
                     completion:(EduApiBlock)completionBlock;

+(void)hotKeywordsWithSchoolAge:(NSString*)schoolAge
                           type:(NSString*)type
                 viewController:(UIViewController*)viewController
                     completion:(EduApiBlock)completionBlock;

+(void)testListWithSchoolAge:(NSString*)schoolAge
                     childID:(NSString*)childID
              viewController:(UIViewController*)viewController
                  completion:(EduApiBlock)completionBlock;
+(void)relatedTestWithSchoolAge:(NSString*)schoolAge
                        childID:(NSString*)childID
                   associateTag:(NSString*)associateTag
                 viewController:(UIViewController*)viewController
                     completion:(EduApiBlock)completionBlock;

+(void)searchArticleWithSchoolAge:(NSString*)schoolAge
                          keyword:(NSString*)keyword
                   viewController:(UIViewController*)viewController
                       completion:(EduApiBlock)completionBlock;
+(void)relatedArticleWithSchoolAge:(NSString*)schoolAge
                      associateTag:(NSString*)associateTag
                    viewController:(UIViewController*)viewController
                        completion:(EduApiBlock)completionBlock;

#pragma mark ----------------------------------------------------------------
+(void)favorListWithPostID:(NSString*)postID
                  postType:(NSString*)postType
                    lastID:(NSString*)lastID
                      size:(NSInteger)size
                completion:(EduApiBlock)completionBlock;

+(void)favor:(BOOL)favor
    postType:(NSString*)postType
      postID:(NSString*)postID
  completion:(EduApiBlock)completionBlock;

+(void)commentPostWithContent:(NSString*)content
                     postType:(NSString*)postType
                       postID:(NSString*)postID
                      applyTo:(NSString*)applyTo
                   completion:(EduApiBlock)completionBlock;


+(void)commentListWithPostID:(NSString*)postID
                    postType:(NSString*)postType
                      lastID:(NSString*)lastID
                        size:(NSInteger)size
                  completion:(EduApiBlock)completionBlock;

+(void)commentDeleteWithID:(NSString*)commentID
                  postType:(NSString*)postType
                    postID:(NSString*)postID
                completion:(EduApiBlock)completionBlock;

#pragma mark ----------------------------------------------------------------
+(void)eduVolcationListWithViewController:(UIViewController*)viewController
                               completion:(EduApiBlock)completionBlock;
+(void)eduVolcationWithId:(NSString*)vacationId
           viewController:(UIViewController*)viewController
               completion:(EduApiBlock)completionBlock;
+(void)eleArticleWithId:(NSString*)articleId
         viewController:(UIViewController*)viewController
             completion:(EduApiBlock)completionBlock;
@end

