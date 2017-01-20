
#import "EduApi.h"

#import "JSONHTTPClient.h"


#import "AnswerInfo.h"

#import "CheckUserRequest.h"
#import "LoginRequest.h"

#import "RegisterRequest.h"
#import "UpdateUserRequest.h"
#import "UpdatePasswordRequest.h"


#import "AddChildRequest.h"
#import "GetChildListRequest.h"

#import "GetTestsRequest.h"

#import "DeleteChildRequest.h"
#import "GetCategoryFirstRequest.h"
#import "GetCategorySecondRequest.h"

#import "GetEvaluationTasksRequest.h"

#import "GetTasksRequest.h"
#import "AddTasksRequest.h"
#import "UpdateTaskRequest.h"
#import "AddFollowerRequest.h"

#import "RecommendRequest.h"

#import "AddDiaryRequest.h"
#import "GetDiariesRequest.h"

#import "UpdateDiaryRequest.h"
#import "RemoveDiaryRequest.h"
#import "GetDiaryRequest.h"


#import "GetTaskDetailRequest.h"

#import "GetShareUrlRequest.h"

#import "Reachability.h"

#import "MyRSA.h"

#import "UserPreference.h"

//#import "BPush.h"

#import "NSString+URL.h"

#import "OpenUDID.h"

#import "MyProgressDialog.h"
//#import "ASIHTTPRequest.h"
#import "LoginV1Request.h"

#import "AppDelegate.h"

#define kSourceIOS @"ios"

#define  SoftVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]


/** 图片服务器 */
#define kPicAPIHost @"http://api.pic.elooking.cn"

/** 上传图片 */
#define kUrlUploadPic @"/uploadpic/json"

#if DEV_TEST
	#define kServiceAPIHost @"http://121.41.101.14:8082/service" //测评模块地址（开发，测试）
#else
	#define kServiceAPIHost @"http://101.201.37.122:8090" //测评模块地址（正式）
#endif


/** 检测用户名是否存在 */
#define kUrlCheckUser @"/service/checkuser/json"

/** 预登录 */
#define kUrlPrelogin @"/service/prelogin/json"

/** 获取省份/城市/县区 */
#define kUrlGetLocation @"/service/getlocation/json"

/** 注册 */
#define kUrlRegister @"/service/register/json"

/** 登录 */
#define kUrlLogin @"/service/login/json"

/** 用户信息 */
#define kUrlUserInfo @"/service/userinfo/json"

/** 更新用户信息 */
#define kUrlUpdateUser @"/service/updateuser/json"

/** 修改密码 */
#define kUrlUpdatePassword @"/service/passwd/json"

/** 获取学龄列表 */
#define kUrlGetSchoolAges @"/service/getschoolages/json"

/** 添加孩子 */
#define kUrlAddChild @"/service/addchild/json"

/** 孩子列表 */
#define kUrlChildList @"/service/childlist/json"

/** 删除孩子 */
#define kUrlDeleteChild @"/service/deletechild/json"

/** 修改孩子 */
#define kUrlUpdateChild @"/service/updatechild/json"

/** 一级分类 */
#define kUrlCategoryFirst @"/service/categoryfirst/json"

/** 二级分类 */
#define kUrlCategorySecond @"/service/categorysecond/json"

/** 获取测试题 */
//#define kUrlGetTests @"/service/gettests/json"
#define kUrlGetTests @"/service/gettestslxt/json"

/** 批量保存答案 */
#define kUrlAddAnswers @"/service/addanswers/json"

/** 获取评价 */
//#define kUrlGetEvaluation @"/service/getevaluation/json"
#define kUrlGetEvaluation @"/service/getlxtevaluation/json"

/** 获取答案 */
#define kUrlGetAnswers @"/service/getanswers/json"

/** 获取评价任务 */
#define kUrlGetEvaluationTasks @"/service/getevaluationtasks/json"

/** 添加任务 */
#define kUrlAddTasks @"/service/addtasks/json"

/** 获取孩子任务 */
#define kUrlTaskList @"/service/tasklist/json"
//#define kUrlGetTasks @"/service/gettasks/json"

/** 任务详情 */
#define kUrlTaskDetail @"/service/taskdetail/json"

#define kUrlTaskDetailInfo @"/service/taskdetailinfo/json"

/** 更新任务 */
#define kUrlUpdateTask @"/service/updatetask/json"

/** 添加关注 */
#define kUrlAddFollower @"/service/addfollower/json"

/** 关注者列表 */
#define kUrlGetFollowers @"/service/getfollowers/json"

/** 删除关注者 */
#define kUrlRemoveFollower @"/service/removefollower/json"


/** 关注列表 */
#define kUrlGetObservables @"/service/getobservables/json"

/** 取消关注 */
#define kUrlRemoveObservable @"/service/removeobservable/json"


/** 排名 */
#define kUrlGetRank @"/service/getrank/json"

/** 查询用户 */
#define kUrlSearchUser @"/service/searchuser/json"

/** 推荐产品 */
#define kUrlRecommend @"/service/recommend/json"

/** 下载地址 */
#define kUrlDownloadUrl @"/service/downloadurl/json"

/** 添加日记 */
#define kUrlAddDiary @"/service/adddiary/json"

/** 日记列表 */
#define kUrlGetDiaries @"/service/getdiaries/json"

/** 社区日记 */
#define kUrlSocialDiaries @"/service/socialdiaries/json"


/** 更新日记 */
#define kUrlUpdateDiary @"/service/updatediary/json"

/** 删除日记 */
#define kUrlRemoveDiary @"/service/removediary/json"

/** 查询日记 */
#define kUrlGetDiary @"/service/getdiary/json"

/** 分享地址 */
#define kUrlShareUrl @"/service/shareurl/json"


/** 轮询接口 */
#define kUrlNotification @"/service/notification/json"

/** 反馈接口 */
#define kUrlFeedback @"/service/feedback/json"

/** 第三方登录 */
#define kUrlLoginV1 @"/service/loginv1/json"

/** 首页推荐 */
#define kUrlHomepageItems @"/service/homepageitems/json"

/** 文章 */
#define kUrlSocialArticle @"/service/socialarticle/json"

/** 游戏过滤项 */
#define kUrlTaskSearchFilter @"/service/searchfilter/json"

/** 搜索游戏 */
#define kUrlSearchTask @"/service/searchtask/json"

/** 相关游戏 */
#define kUrlRelatedTask @"/service/relatedtask/json"

/** 热词 */
#define kUrlHotKeywords @"/service/hotkeywords/json"

/** 测试列表 */
#define kUrlTestList @"/service/testlistlxt/json"

/** 相关测试 */
#define kUrlRelatedTest @"/service/relatedtest/json"

/** 搜索文章 */
#define kUrlSearchArticle @"/service/searcharticle/json"

/** 相关文章 */
#define kUrlRelatedArticle @"/service/relatedarticle/json"

#pragma mark --------------------酒景-------------------------
#define kUrlEduVacationList @"/service/eduvacationlist/json"
#define kUrlEduVacation @"/service/eduvacation/json"
#define kUrlEleArticle @"/service/elearticle/json"


#pragma mark ----------------------------------------------
/** push注册 */
#define kUrlPushRegister @"http://api.push.elooking.cn/register"

/** 赞 */
#define kUrlFavorW @"http://w.comment.elooking.cn/up"

#define kUrlFavorR @"http://r.comment.elooking.cn/up"

/** 评论 */
#define kUrlCommentW @"http://w.comment.elooking.cn/comment"

/** 评论 */
#define kUrlCommentR @"http://r.comment.elooking.cn/comment"




@implementation EduApi

/** 检测用户名是否存在 */
+(void)checkUser:(NSString*)user completion:(EduApiBlock)completionBlock
{
	
	//    参数	类型	说明
	//    user	string	用户名
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlCheckUser] ;
	
	
	CheckUserRequest *params = [[CheckUserRequest alloc]init ];
	params.source = kSourceIOS;
	params.user = user;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	
	
	
	
}

/** 获取省份、城市、区县 */
+(void)getLocationWithCompletion:(EduApiBlock)completionBlock
{
	//GCD
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// 耗时的操作
		
		//读取本地文件
		NSError *error;
		NSString *file = [[NSBundle mainBundle] pathForResource:@"getlocation.json" ofType:nil];
		NSString *json = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			// 更新界面
			// If there are no results, something went wrong
			if (json == nil||error)
			{
				// an error occurred
				NSLog(@"Error reading text file. %@", [error description]);
				[self completion:completionBlock response:nil];
			}else{
				
				GetLocationResponse *response =nil;
				
				NSError *jsonError;
				response= [[GetLocationResponse alloc]initWithString:json error:&jsonError];
				if (jsonError) {
					NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
					response=nil;
				}
				
				[self completion:completionBlock response:response];
				
			}
			
		});
	});
	
	
	
	
	//    NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetLocation] ;
	//
	//    BaseRequest *params = [[BaseRequest alloc]init ];
	//    params.source = kSourceIOS;
	//
	//    [self JSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetLocationResponse class] completion:completionBlock];
	
	
	
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }
	//
	//                                   GetLocationResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetLocationResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 获取学龄列表 */
+(void)getSchoolAgesWithCompletion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetSchoolAges] ;
	
	BaseRequest *params = [[BaseRequest alloc]init ];
	params.source = kSourceIOS;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetSchoolAgesResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }
	//
	//                                   GetSchoolAgesResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetSchoolAgesResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}


/** 预登录，获取加密信息 */
+(void)preloginWithCompletion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlPrelogin] ;
	
	BaseRequest *params = [[BaseRequest alloc]init ];
	params.source = kSourceIOS;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[PreloginResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//
	//                                   }
	//
	//                                   PreloginResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[PreloginResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"prelogin jsonError:%@",[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}


/** 注册  */
+(void)registerWithUser:(NSString*)user district:(NSInteger)districtID password:(NSString*)password preloginResponse:(PreloginResponse *)preloginResponse completion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRegister] ;
	
	
	//    password \t servertime \t random 用public key加密
	//    long long time = [preloginResponse.result.t longLongValue] + 1000 * 60 * 60;
	NSString *time = preloginResponse.result.t;
	NSString *sp = [NSString stringWithFormat:@"%@\t%@\t%@", password,time,preloginResponse.result.r];
	NSLog(@"login sp:%@",sp);
	
	NSString *modulus = [NSString stringWithFormat:@"%@",preloginResponse.result.m];
	NSString *exponent = [NSString stringWithFormat:@"%@",preloginResponse.result.p];
	
	sp = [MyRSA setPublicKey:sp Mod:modulus Exp:exponent];
	
	//测试
	//    sp = @"067552c8f9178519b7a61cfc88efcb5afc6f39b61778e2bbf6bc72138d4d09481c11d8520298582b4f8799b7e1d7fe557ec4f5ef8ea68a98f0b04f989e6455546bd9d4d96d7bfc8466a182fb171130d54457e34877268ea080eb3c99aaa3d2a59a3c5dffe0fb2187cee8e429777ee1ab398ed6c362c2b77d332d26f3b307fcab";
	NSLog(@"sp长度：%ld",sp.length);
	
	RegisterRequest *params = [[RegisterRequest alloc]init ];
	params.user=user;
	params.sp = sp;
	params.source = kSourceIOS;
	//    params.deviceID = [OpenUDID value];
	// by mey
	params.deviceID = NULL;
	
	
	params.districtID = districtID;
	NSLog(@"register params:%@",params);
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[LoginResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//
	//                                   }
	//
	//                                   LoginResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[LoginResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

#pragma mark 登录
+(void)loginWithUser:(NSString*)user
			password:(NSString*)password
	preloginResponse:(PreloginResponse *)preloginResponse
		  completion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlLogin] ;
	
	
	//    password \t servertime \t random 用public key加密
	//    long long time = [preloginResponse.result.t longLongValue] + 1000 * 60 * 60;
	NSString *time = preloginResponse.result.t;
	NSString *sp = [NSString stringWithFormat:@"%@\t%@\t%@", password,time,preloginResponse.result.r];
	NSLog(@"login sp:%@",sp);
	
	NSString *modulus = [NSString stringWithFormat:@"%@",preloginResponse.result.m];
	NSString *exponent = [NSString stringWithFormat:@"%@",preloginResponse.result.p];
	
	//    const char *key = [sp UTF8String];
	//    const char *mod = [modulus UTF8String];
	//    const char *p = [exponent UTF8String];
	//    sp=@"1";
	sp = [MyRSA setPublicKey:sp Mod:modulus Exp:exponent];
	
	//    sp = [RSALibrary signMessage:sp privateExponent:preloginResponse.result.p modulus:preloginResponse.result.m];
	
	//测试
	//    sp = @"067552c8f9178519b7a61cfc88efcb5afc6f39b61778e2bbf6bc72138d4d09481c11d8520298582b4f8799b7e1d7fe557ec4f5ef8ea68a98f0b04f989e6455546bd9d4d96d7bfc8466a182fb171130d54457e34877268ea080eb3c99aaa3d2a59a3c5dffe0fb2187cee8e429777ee1ab398ed6c362c2b77d332d26f3b307fcab";
	NSLog(@"sp长度：%ld",sp.length);
	
	LoginRequest *params = [[LoginRequest alloc]init ];
	params.user=user;
	params.sp = sp;
	params.source = kSourceIOS;
	params.deviceID = [OpenUDID value];
	
	NSLog(@"login params:%@",params);
	//    user=zhoubo&sp=067552c8f9178519b7a61cfc88efcb5afc6f39b61778e2bbf6bc72138d4d09481c11d8520298582b4f8799b7e1d7fe557ec4f5ef8ea68a98f0b04f989e6455546bd9d4d96d7bfc8466a182fb171130d54457e34877268ea080eb3c99aaa3d2a59a3c5dffe0fb2187cee8e429777ee1ab398ed6c362c2b77d332d26f3b307fcab
	
	//    urlString = [urlString stringByAppendingFormat:@"?user=%@&sp=%@",user,sp];
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[LoginResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//
	//                                   }
	//
	//                                   LoginResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[LoginResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"login jsonError:%@",[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 用户信息  */
+(void)userInfoWithToken:(NSString*)token
		  viewController:(UIViewController*)viewController
			  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlUserInfo] ;
	
	
	NSDictionary *params = @{@"token":token};
	
	[self getJSONFromURLWithString:urlString params:params responseClass:[LoginResponse class] completion:completionBlock];
	
	
}


/** 更新用户信息 */
+(void)updateUserWithToken:(NSString*)token
				  district:(NSInteger)districtID
					   pic:(NSString*)pic
					gender:(NSString*)gender
				  birthday:(NSDate*)birthday
				  nickName:(NSString*)nickName
			viewController:(UIViewController*)viewController
				completion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlUpdateUser] ;
	
	
	UpdateUserRequest *params = [[UpdateUserRequest alloc]init ];
	params.token=token;
	params.district = districtID;
	params.source = kSourceIOS;
	params.pic = pic;
	params.gender = gender;
	params.birthday = birthday;
	params.nickName = nickName;
	
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"updateUser jsonError:%@",[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 修改密码 */
+(void)updatePasswordWithToken:(NSString*)token
					  password:(NSString*)password
				   newPassword:(NSString*)newPassword
			  preloginResponse:(PreloginResponse *)preloginResponse
					completion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlUpdatePassword] ;
	
	
	UpdatePasswordRequest *params = [[UpdatePasswordRequest alloc]init ];
	params.source = kSourceIOS;
	params.token=token;
	
	NSString *sp = [NSString stringWithFormat:@"%@\t%@\t%@", password,preloginResponse.result.t,preloginResponse.result.r];
	sp = [MyRSA setPublicKey:sp Mod:preloginResponse.result.m Exp:preloginResponse.result.p];
	params.sp = sp;
	
	NSString *nsp = [NSString stringWithFormat:@"%@\t%@\t%@", newPassword,preloginResponse.result.t,preloginResponse.result.r];
	nsp = [MyRSA setPublicKey:nsp Mod:preloginResponse.result.m Exp:preloginResponse.result.p];
	params.nsp = nsp;
	
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 添加孩子 */
+(void)addChildWithToken:(NSString*)token
				   child:(ChildInfo*)child
			  completion:(EduApiBlock)completionBlock
{
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    name	string	孩子名字
	//    schoolAge	byte	孩子学龄,1：幼儿园大班，2：小学一年级，3：小学二年级，4：小学三年级，5：小学四年级
	//    gender	byte	孩子性别 1(male) ,2(female)
	//    blood（可选）	string	血型1(A), 2 (B),3(O),(4)AB,(5)other
	//    relation（可选）	string	关系
	//    picture（可选）	string	头像
	//    birthday	string	生日（格式为yyyy-MM-dd）
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlAddChild] ;
	
	
	AddChildRequest *params = [[AddChildRequest alloc]init ];
	params.source = kSourceIOS;
	params.token=token;
	params.name = child.childName;
	params.schoolAge = child.schoolAge.value;
	params.gender = child.gender;
	params.blood = child.blood;
	params.relation = child.relation;
	params.picture = child.picture;
	params.birthday = child.birthday;
	params.schoolName = child.schoolName;
	params.realName = child.realName;
	
	//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	//    [formatter setDateFormat:@"yyyy-MM-dd"];
	//    params.birthday = birthday;//[formatter stringFromDate:birthday];
	
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 获取孩子列表 */
+(void)getChildListWithToken:(NSString*)token
				   childType:(NSInteger)childType
				  completion:(EduApiBlock)completionBlock
{
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childType	byte	1表示可操作的孩子，2表示观察的孩子,0返回全部
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlChildList] ;
	
	
	GetChildListRequest *params = [[GetChildListRequest alloc]init ];
	params.source = kSourceIOS;
	params.token=token;
	params.childType = childType;
	params.ver = 1;
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetChildListResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//
	//                                   GetChildListResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetChildListResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 删除孩子 */
+(void)deleteChildWithToken:(NSString*)token
					childID:(NSString*)childID
				 completion:(EduApiBlock)completionBlock
{
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    id	int	孩子ID
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlDeleteChild] ;
	
	
	DeleteChildRequest *params = [[DeleteChildRequest alloc]init ];
	params.source = kSourceIOS;
	params.token=token;
	params.id = childID;
	
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 更新孩子 */
+(void)updateChildWithToken:(NSString*)token child:(ChildInfo*)child
				 completion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlUpdateChild] ;
	
	
	AddChildRequest *params = [[AddChildRequest alloc]init ];
	params.source = kSourceIOS;
	params.token=token;
	params.name = child.childName;
	params.schoolAge = child.schoolAge.value;
	params.gender = child.gender;
	params.blood = child.blood;
	params.relation = child.relation;
	params.picture = child.picture;
	params.birthday = child.birthday;
	params.schoolName = child.schoolName;
	params.realName = child.realName;
	
	params.id = child.id;
	
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}




/** 一级分类 */
+(void)getCategoryFirstWithToken:(NSString*)token
					   schoolAge:(NSString*)schoolAge
					  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlCategoryFirst] ;
	
	GetCategoryFirstRequest *params = [[GetCategoryFirstRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.schoolAge = schoolAge;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetCategoryFirstResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetCategoryFirstResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetCategoryFirstResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 二级分类 */
+(void)getCategorySecondWithToken:(NSString*)token
				  categoryFirstId:(NSString*)cf
						  childID:(NSString*)childID
					   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlCategorySecond] ;
	
	GetCategorySecondRequest *params = [[GetCategorySecondRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.cf = cf;
	params.childID = childID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetCategorySecondResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetCategorySecondResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetCategorySecondResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 获取测试题 */
+(void)getTestsWithToken:(NSString*)token
				  testID:(NSString*)testID
				 childID:(NSString*)childID
			  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetTests] ;
	
	GetTestsRequest *params = [[GetTestsRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.testID = testID;
	params.childID = childID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetTestsResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetTestsResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetTestsResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 批量保存答案 */
+(void)addAnswersWithToken:(NSString*)token
					testID:(NSString*)testID
				   childID:(NSString*)childID
				   answers:(NSArray*)answers
				completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlAddAnswers] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    testID	int	测试ID
	//    answers[i].subjectID	int	试题ID
	//    answers[i].option	byte	选择的选项（1-7）
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init ];
	[params setObject:kSourceIOS forKey:@"source"];
	[params setObject:token forKey:@"token"];
	[params setObject:testID forKey:@"testID"];
	[params setObject:childID forKey:@"childID"];
	
	NSUInteger i=0;
	for (AnswerInfo *info in answers)
	{
		[params setObject:info.subjectID forKey:[NSString stringWithFormat:@"answers[%ld].subjectID",i]];
		[params setObject:info.option forKey:[NSString stringWithFormat:@"answers[%ld].option",i]];
		
		i++;
	}
	
	NSLog(@"%s:%d :%@",__func__,__LINE__,params);
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:params  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 获取评价 */
+(void)getEvaluationWithToken:(NSString*)token
					   testID:(NSString*)testID
					  childID:(NSString*)childID
				   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetEvaluation] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    testID	int	测试ID
	
	GetTestsRequest *params = [[GetTestsRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.testID = testID;
	params.childID = childID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetEvaluationResponse class] completion:completionBlock];
	
	
}

/** 获取答案 */
+(void)getAnswersWithToken:(NSString*)token
					testID:(NSString*)testID
				   childID:(NSString*)childID
				completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetAnswers] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    testID	int	测试ID
	
	
	GetTestsRequest *params = [[GetTestsRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.testID = testID;
	params.childID = childID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetAnswersResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetAnswersResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetAnswersResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 获取评价任务 */
+(void)getEvaluationTasksWithToken:(NSString*)token
						   childID:(NSString*)childID
					  evaluationID:(NSString*)evaluationID
						completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetEvaluationTasks] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    evaluationID	int	评价ID
	//    childID	int	孩子ID
	
	
	
	GetEvaluationTasksRequest *params = [[GetEvaluationTasksRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.evaluationID = evaluationID;
	params.childID = childID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetTasksResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetTasksResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetTasksResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

#pragma mark 添加任务
+(void)addTasksWithToken:(NSString*)token
				 childID:(NSString*)childID
				   tasks:(NSString*)tasks
			  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlAddTasks] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    tasks	string	任务ID，例如：1,2,3（英文逗号）
	
	
	
	
	AddTasksRequest *params = [[AddTasksRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.childID = childID;
	params.tasks = tasks;
	params.ver = 1;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	//
}

/** 获取孩子任务 */
+(void)getTaskListWithToken:(NSString*)token
					childID:(NSString*)childID
					 status:(NSString*)status
				 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlTaskList] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    status	byte(可选,默认为全部)	状态（1表示任务已添加，2表示任务开始，3表示任务已结束）
	
	
	
	GetTasksRequest *params = [[GetTasksRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.status = status;
	params.childID = childID;
	
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetTasksResponse class] completion:completionBlock];
	
}

#pragma mark 任务详情
//+(void)getTaskDetailWithToken:(NSString*)token
//                  childTaskID:(NSString *)childTaskID
//                   completion:(EduApiBlock)completionBlock
//{
//    NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlTaskDetail] ;
//
//
//    //    参数	类型	说明
//    //    参数	类型	说明
//    //    token	string	用户唯一标示
//    //    childTaskID	int	孩子任务ID
//
//
//    GetTaskDetailRequest *params = [[GetTaskDetailRequest alloc]init ];
//    params.source = kSourceIOS;
//    params.token = token;
//    params.childTaskID = childTaskID;
//
//
//    [self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetTaskDetailResponse class] completion:completionBlock];
//
//}

#pragma mark 任务详情
+(void)getTaskDetailInfoWithToken:(NSString*)token
						   taskID:(NSString *)taskID
						  childID:(NSString*)childID
					   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlTaskDetailInfo] ;
	
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	
	if(token){
		[params setObject:token forKey:@"token"];
	}
	[params setObject:taskID forKey:@"id"];
	if (childID) {
		[params setObject:childID forKey:@"childID"];
	}
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[GetTaskDetailResponse class] completion:completionBlock];
	
}

//+(void)getTasksWithToken:(NSString*)token
//                 childID:(NSString*)childID
//                  status:(NSString*)status
//          completion:(EduApiBlock)completionBlock
//{
//    NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetTasks] ;
//
//
//    //    参数	类型	说明
//    //    token	string	用户唯一标示
//    //    childID	int	孩子ID
//    //    status	byte(可选,默认为全部)	状态（1表示任务已添加，2表示任务开始，3表示任务已结束）
//
//
//
//    GetTasksRequest *params = [[GetTasksRequest alloc]init ];
//    params.source = kSourceIOS;
//    params.token = token;
//    params.status = status;
//    params.childID = childID;
//
//
//
//     [self JSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetTasksResponse class] completion:completionBlock];
////    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
////                               completion:^(NSDictionary *json, JSONModelError *err) {
////
////                                   if (err) {
////                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
////                                   }else{
////                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
////                                   }
////
////                                   GetTasksResponse *response =nil;
////                                   if (err==nil&&json) {
////                                       NSError *jsonError;
////                                       response= [[GetTasksResponse alloc]initWithDictionary:json error:&jsonError];
////                                       if (jsonError) {
////                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
////                                       }else{
////                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
////                                       }
////
////                                   }
////
////                                   if (completionBlock) {
////                                       completionBlock(response);
////                                   }
////                               }];
//
//}

#pragma mark 更新孩子任务
+(void)updateTaskWithToken:(NSString*)token
				   childID:(NSString*)childID
					taskID:(NSString*)taskID
					status:(NSInteger)status
				completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlUpdateTask] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    taskID	int	任务ID
	//    status	byte（可选）	状态（1表示任务已添加，2表示任务开始，3表示任务已结束）
	
	
	
	UpdateTaskRequest *params = [[UpdateTaskRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.childID = childID;
	params.taskID = taskID;
	params.status = status;
	params.ver = 1;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 添加关注 */
+(void)addFollowerWithToken:(NSString*)token
					   user:(NSString*)user
				 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlAddFollower] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    user	string	需要添加关注的用户id
	
	
	
	AddFollowerRequest *params = [[AddFollowerRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.user = user;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 关注者列表 */
+(void)getFollowersWithToken:(NSString*)token
				  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetFollowers] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	
	
	
	
	BaseRequest *params = [[BaseRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetFollowersResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetFollowersResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetFollowersResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 删除关注者 */
+(void)removeFollowerWithToken:(NSString*)token
						  user:(NSString*)user
					completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRemoveFollower] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    user	string	需要添加关注的用户id
	
	
	
	AddFollowerRequest *params = [[AddFollowerRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.user = user;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 关注列表 */
+(void)getObservablesWithToken:(NSString *)token completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetObservables] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	
	
	
	
	BaseRequest *params = [[BaseRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetFollowersResponse class] completion:completionBlock];
	
	
}

/** 取消关注 */
+(void)removeObservableWithToken:(NSString *)token user:(NSString *)user completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRemoveObservable] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    user	string	需要添加关注的用户id
	
	
	
	AddFollowerRequest *params = [[AddFollowerRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.user = user;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	
	
}

/** 获取排名 */
+(void)getRankWithToken:(NSString*)token
			 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetRank] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	
	BaseRequest *params = [[BaseRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetRankResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetRankResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetRankResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 上传图片 */
+(void)uploadPicWithToken:(NSString*)token
				base64Pic:(NSString*)base64Pic
				picFormat:(NSString*)picFormat
			   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kPicAPIHost stringByAppendingString: kUrlUploadPic] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    base64Pic	string	Base64编码后的图片
	//    picFormat	string	jpg/png/git
	
	UploadPicRequest *params = [[UploadPicRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.base64Pic = base64Pic;
	params.picFormat= picFormat;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[UploadPicResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   UploadPicResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[UploadPicResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 查询用户 */
+(void)searchUserWithToken:(NSString*)token
					  user:(NSString*)user
				completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlSearchUser] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    user	string	需要查询的用户名，支持模糊匹配
	
	AddFollowerRequest *params = [[AddFollowerRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.user = user;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[SearchUserResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   SearchUserResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[SearchUserResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 推荐产品 */
+(void)recommendWithToken:(NSString*)token
			  productType:(NSString*)productType
					  num:(NSInteger)num
			   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRecommend] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    productType	byte	产品类型(1.酒店。2.门票。3.团购)
	//    num	byte	返回产品数量（小于500）
	
	RecommendRequest *params = [[RecommendRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.productType = productType;
	params.num = num;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[RecommendResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   RecommendResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[RecommendResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 下载地址 */
+(void)downloadUrlWithToken:(NSString*)token
				 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlDownloadUrl] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	
	
	BaseRequest *params = [[BaseRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[DownloadUrlResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   DownloadUrlResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[DownloadUrlResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 添加日记 */
+(void)addDiaryWithToken:(NSString*)token
				 childID:(NSString*)childID
				   diary:(NSString*)diary
				  picUrl:(NSString*)picUrl
				  taskID:(NSString*)taskID
			  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlAddDiary] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子ID
	//    diary	string	日记内容（最多4000个字符）
	//    picUrl（可选）	string	图片
	//    childTaskID（可选）	int	任务ID
	
	
	AddDiaryRequest *params = [[AddDiaryRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.childID = childID;
	params.diary = diary;
	params.picUrl = picUrl;
	params.taskID = taskID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 日记列表 */
+(void)getDiariesWithToken:(NSString*)token
				   childID:(NSString*)childID
					lastID:(NSString*)lastID
					  size:(NSInteger)size
				completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetDiaries] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childID	int	孩子
	//    lastID	上一页最后一个ID，第一页为0
	//    size	int	每一页的大小
	
	
	GetDiariesRequest *params = [[GetDiariesRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.childID = childID;
	params.lastID = lastID;
	params.size= size;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetDiariesResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetDiariesResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetDiariesResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 更新日记 */
+(void)updateDiaryWithToken:(NSString*)token
					diaryID:(NSString*)diaryID
					  diary:(NSString*)diary
					 picUrl:(NSString*)picUrl
				 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlUpdateDiary] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    diaryID	int	日记ID
	//    diary（可选）	string	日记内容（最多4000个字符）
	//    picUrl（可选）	string	图片地址
	
	
	UpdateDiaryRequest *params = [[UpdateDiaryRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.diaryID = diaryID;
	params.diary = diary;
	
	if (picUrl==nil) {
		picUrl=@"";
	}
	params.picUrl = picUrl;
	
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}


/** 删除日记 */
+(void)removeDiaryWithToken:(NSString*)token
					diaryID:(NSString*)diaryID
				 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRemoveDiary] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    diaryID	int	日记ID
	
	
	
	RemoveDiaryRequest *params = [[RemoveDiaryRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.diaryID = diaryID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[BaseResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   BaseResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[BaseResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 查询日记 */
+(void)getDiaryWithToken:(NSString*)token
				  taskID:(NSString*)taskID
			  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlGetDiary] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    childTaskID	int	任务ID
	
	
	
	GetDiaryRequest *params = [[GetDiaryRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.taskID = taskID;
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetDiaryResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary]  orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//                                   }else{
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,json);
	//                                   }
	//
	//                                   GetDiaryResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[GetDiaryResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
	//                                       }else{
	//                                           NSLog(@"%s:%d :%@",__func__,__LINE__,response);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

/** 分享地址 */
+(void)getShareUrlWithToken:(NSString*)token
					childID:(NSString*)childID
					   type:(NSString*)type
						 ID:(NSString*)ID
						 ch:(NSString*)ch
				 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlShareUrl] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    taskID（可选）	int	ver=2时，任务ID，type为2、3时此参数和childID参数一起传
	//    testID（可选）	int	测试ID ,type为1时传此参数。
	
	//    ver	byte	版本，最新版本为1
	//    type	byte	分享类型 1.测试结果 2.任务 3.任务日记 4非任务日记,5. 推荐下载
	//    ch	byte	分享渠道：1 新浪微博, 2. 微信朋友圈 3. 微信好友 4 短信推荐
	
	
	
	GetShareUrlRequest *params = [[GetShareUrlRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.childID = childID;
	params.type = type;
	
	params.ver = @"2";
	params.ch = ch;
	
	if ([kShareUrlTypeTask isEqual:type]||[kShareUrlTypeTaskDiary isEqual:type]) {
		params.taskID = ID;
	}
	else if([kShareUrlTypeTest isEqual:type]||[kShareUrlTypeTestEvaluation isEqual:type]){
		params.testID = ID;
	}
	else if([kShareUrlTypeArticle isEqual:type]){
		params.socialArticleID = ID;
	}
	else if([kShareUrlTypeVacation isEqual:type]){
		params.eduVacationID  = ID;
	}
	else if([kShareUrlTypeEleArticle isEqual:type]){
		params.eleArticleID = ID;
	}
	
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[DownloadUrlResponse class] completion:completionBlock];
	
	
}


/** push注册  */
+(void)pushRegisterWithCompletion:(EduApiBlock)completionBlock
{
	
	NSString *passport = [UserPreference getAccount];
	NSString *uid = [UserPreference getPushid];
	NSString *dt = [UserPreference getDeviceToken];
	if (passport.length<=0||uid.length<=0 || dt.length<=0) {
		return;
	}
	
	//设置tag
	
	//by sck
	//[BPush setTag:passport];
	
	
	NSString *urlString = kUrlPushRegister ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	
	[params setObject:@"0" forKey:@"platform"];
	[params setObject:passport forKey:@"passport"];
	[params setObject:uid forKey:@"uid"];
	[params setObject:SoftVersion forKey:@"version"];
	[params setObject:dt forKey:@"dt"];
	
	[self getJSONFromURLWithString:urlString params:params responseClass:[LoginResponse class] completion:completionBlock];
	
}


#pragma mark 社区日记
+(void)socialDiariesWithToken:(NSString*)token
					   lastID:(NSString*)lastID
						 size:(NSInteger)size
				   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlSocialDiaries] ;
	
	
	//    参数	类型	说明
	//    token	string	用户唯一标示
	//    lastID	上一页最后一个ID，第一页为0
	//    size	int	每一页的大小
	
	GetDiariesRequest *params = [[GetDiariesRequest alloc]init ];
	params.source = kSourceIOS;
	params.token = token;
	params.lastID = lastID;
	params.size= size;
	params.ver = 1;
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[GetDiariesResponse class] completion:completionBlock];
	
	
	
}

/** 轮询  */
+(void)notificationWithToken:(NSString*)token
			  viewController:(UIViewController*)viewController
				  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlNotification] ;
	
	
	NSDictionary *params = @{@"token":token};
	
	[self getJSONFromURLWithString:urlString params:params responseClass:[NotificationResponse class] completion:completionBlock];
	
	
}

/** 反馈  */
+(void)feedbackWithToken:(NSString*)token
				 contact:(NSString*)contact
				 content:(NSString*)content
		  viewController:(UIViewController*)viewController
			  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlFeedback] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	if(token){
		[params setObject:token forKey:@"token"];
	}
	[params setObject:[OpenUDID value] forKey:@"deviceID"];
	[params setObject:kSourceIOS forKey:@"source"];
	[params setObject:SoftVersion forKey:@"appVersion"];
	[params setObject:content forKey:@"content"];
	
	if (contact) {
		[params setObject:contact forKey:@"contact"];
	}
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[BaseResponse class] completion:completionBlock];
	
	
}

#pragma mark --------------
#pragma mark 第三方登录
+(void)loginV1WithUser:(NSString*)user
					sp:(NSString*)sp
					ch:(NSString*)ch
			  nickName:(NSString*)nickName
				   pic:(NSString*)pic
		   accessToken:(NSString*)accessToken
	  preloginResponse:(PreloginResponse *)preloginResponse
			completion:(EduApiBlock)completionBlock
{
	
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlLoginV1] ;
	
	
	//    password \t servertime \t random 用public key加密
	//    long long time = [preloginResponse.result.t longLongValue] + 1000 * 60 * 60;
	NSString *time = preloginResponse.result.t;
	sp = [NSString stringWithFormat:@"%@\t%@\t%@", sp,time,preloginResponse.result.r];
	NSLog(@"login sp:%@",sp);
	
	NSString *modulus = [NSString stringWithFormat:@"%@",preloginResponse.result.m];
	NSString *exponent = [NSString stringWithFormat:@"%@",preloginResponse.result.p];
	
	//    const char *key = [sp UTF8String];
	//    const char *mod = [modulus UTF8String];
	//    const char *p = [exponent UTF8String];
	//    sp=@"1";
	sp = [MyRSA setPublicKey:sp Mod:modulus Exp:exponent];
	
	//    sp = [RSALibrary signMessage:sp privateExponent:preloginResponse.result.p modulus:preloginResponse.result.m];
	
	//测试
	//    sp = @"067552c8f9178519b7a61cfc88efcb5afc6f39b61778e2bbf6bc72138d4d09481c11d8520298582b4f8799b7e1d7fe557ec4f5ef8ea68a98f0b04f989e6455546bd9d4d96d7bfc8466a182fb171130d54457e34877268ea080eb3c99aaa3d2a59a3c5dffe0fb2187cee8e429777ee1ab398ed6c362c2b77d332d26f3b307fcab";
	NSLog(@"sp长度：%ld",sp.length);
	
	LoginV1Request *params = [[LoginV1Request alloc]init ];
	params.source = kSourceIOS;
	params.deviceID = [OpenUDID value];
	
	params.user=user;
	params.sp = sp;
	params.ch = ch;
	params.nickName = nickName;
	params.pic = pic;
	
	params.deviceType = kSourceIOS;
	params.accessToken = accessToken;
	
	NSLog(@"login params:%@",params);
	//    user=zhoubo&sp=067552c8f9178519b7a61cfc88efcb5afc6f39b61778e2bbf6bc72138d4d09481c11d8520298582b4f8799b7e1d7fe557ec4f5ef8ea68a98f0b04f989e6455546bd9d4d96d7bfc8466a182fb171130d54457e34877268ea080eb3c99aaa3d2a59a3c5dffe0fb2187cee8e429777ee1ab398ed6c362c2b77d332d26f3b307fcab
	
	//    urlString = [urlString stringByAppendingFormat:@"?user=%@&sp=%@",user,sp];
	
	[self postJSONFromURLWithString:urlString params:[params toDictionary] responseClass:[LoginResponse class] completion:completionBlock];
	//    [JSONHTTPClient JSONFromURLWithString:urlString method:kHTTPMethodPOST params:[params toDictionary] orBodyString:nil headers:[self getRequestHeaders]
	//                               completion:^(NSDictionary *json, JSONModelError *err) {
	//
	//                                   if (err) {
	//                                       NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
	//
	//                                   }
	//
	//                                   LoginResponse *response =nil;
	//                                   if (err==nil&&json) {
	//                                       NSError *jsonError;
	//                                       response= [[LoginResponse alloc]initWithDictionary:json error:&jsonError];
	//                                       if (jsonError) {
	//                                           NSLog(@"login jsonError:%@",[jsonError description]);
	//                                       }
	//
	//                                   }
	//
	//                                   if (completionBlock) {
	//                                       completionBlock(response);
	//                                   }
	//                               }];
	
}

#pragma mark 首页推荐
+(void)homepageItemsWithToken:(NSString*)token
					  childID:(NSString*)childID
					schoolAge:(NSString*)schoolAge
			   viewController:(UIViewController*)viewController
				   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlHomepageItems] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	if (token)
	{
		[params setObject:token forKey:@"token"];
	}
	if (childID.length>0) {
		[params setObject:childID forKey:@"childID"];
	}
	if (schoolAge.length>0) {
		[params setObject:schoolAge forKey:@"schoolAge"];
	}
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[HomepageItemsResponse class] completion:completionBlock];
	
	
}

#pragma mark 文章
+(void)socialArticleWithToken:(NSString*)token
					articleID:(NSString*)articleID
			   viewController:(UIViewController*)viewController
				   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlSocialArticle] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	if(token){
		[params setObject:token forKey:@"token"];
	}
	
	[params setObject:articleID forKey:@"id"];
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[SocialArticleResponse class] completion:completionBlock];
	
	
}

#pragma mark 游戏过滤项
+(void)taskSearchFilterWithSchoolAge:(NSString*)schoolAge
					  viewController:(UIViewController*)viewController
						  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlTaskSearchFilter] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[TaskSearchFilterResponse class] completion:completionBlock];
	
	
}


#pragma mark 热词
+(void)hotKeywordsWithSchoolAge:(NSString*)schoolAge
						   type:(NSString*)type
				 viewController:(UIViewController*)viewController
					 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlHotKeywords] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	[params setObject:type forKey:@"type"];
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[HotKeywordsResponse class] completion:completionBlock];
	
	
}



#pragma mark 搜索游戏
+(void)taskSearchWithSchoolAge:(NSString*)schoolAge
					   keyword:(NSString*)keyword
					   subject:(NSString*)subject
						 scene:(NSString*)scene
						 count:(NSString*)count
					   childID:(NSString*)childID
				viewController:(UIViewController*)viewController
					completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlSearchTask] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	//    参数	类型	说明
	//    schoolAge	byte	学龄
	//    keyword	string	关键词
	//    subject	string	主题
	//    scene	string	场景
	//    count	string	人数
	
	if (keyword) {
		[params setObject:keyword forKey:@"keyword"];
	}
	if (subject) {
		[params setObject:subject forKey:@"subject"];
	}
	if (scene) {
		[params setObject:scene forKey:@"scene"];
	}
	if (count) {
		[params setObject:count forKey:@"count"];
	}
	[params setObject:childID forKey:@"childID"];
	
	NSString* token = [UserPreference getToken];
	if (token) {
		[params setObject:token forKey:@"token"];
	}
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[GetTasksResponse class] completion:completionBlock];
	
	
}
#pragma mark 相关游戏
+(void)relatedTaskWithSchoolAge:(NSString*)schoolAge
				   associateTag:(NSString*)associateTag
				 viewController:(UIViewController*)viewController
					 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRelatedTask] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	
	NSString* token = [UserPreference getToken];
	if (token)
	{
		[params setObject:token forKey:@"token"];
	}
	
	if (associateTag)
	{
		[params setObject:associateTag forKey:@"associateTag"];
	}
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[GetTasksResponse class] completion:completionBlock];
	
	
}

#pragma mark 测试列表
+(void)testListWithSchoolAge:(NSString*)schoolAge
					 childID:(NSString*)childID
			  viewController:(UIViewController*)viewController
				  completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlTestList] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	NSString* token = [UserPreference getToken];
	if (token)
	{
		[params setObject:token forKey:@"token"];
	}
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	[params setObject:childID forKey:@"childID"];
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[TestListResponse class] completion:completionBlock];
	
}

#pragma mark 相关测试
+(void)relatedTestWithSchoolAge:(NSString*)schoolAge
						childID:(NSString*)childID
				   associateTag:(NSString*)associateTag
				 viewController:(UIViewController*)viewController
					 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRelatedTest] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	[params setObject:childID forKey:@"childID"];
	
	if (associateTag) {
		[params setObject:associateTag forKey:@"associateTag"];
	}
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[TestListResponse class] completion:completionBlock];
	
}

#pragma mark 搜索文章
+(void)searchArticleWithSchoolAge:(NSString*)schoolAge
						  keyword:(NSString*)keyword
				   viewController:(UIViewController*)viewController
					   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlSearchArticle] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	if (keyword) {
		[params setObject:keyword forKey:@"keyword"];
	}
	NSString* token = [UserPreference getToken];
	if (token) {
		[params setObject:token forKey:@"token"];
	}
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[SearchArticleResponse class] completion:completionBlock];
	
}

#pragma mark 相关文章
+(void)relatedArticleWithSchoolAge:(NSString*)schoolAge
					  associateTag:(NSString*)associateTag
					viewController:(UIViewController*)viewController
						completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlRelatedArticle] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	NSString* token = [UserPreference getToken];
	if (token) {
		[params setObject:token forKey:@"token"];
	}
	
	[params setObject:schoolAge forKey:@"schoolAge"];
	
	
	if (associateTag)
	{
		[params setObject:associateTag forKey:@"associateTag"];
	}
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[SearchArticleResponse class] completion:completionBlock];
	
}

#pragma mark -------------------------------------------------------

#pragma mark  赞
+(void)favor:(BOOL)favor
	postType:(NSString*)postType
	  postID:(NSString*)postID
  completion:(EduApiBlock)completionBlock
{
	
	if (favor) {
		NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
		
		[params setObject:[UserPreference getToken] forKey:@"token"];
		[params setObject:postID forKey:@"postID"];
		[params setObject:postType forKey:@"postType"];
		
		NSString *bodyString = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
		
		NSString *urlString = kUrlFavorW ;
		
		
		
		[self JSONFromURLWithString:urlString method:kHTTPMethodPOST params:nil bodyString:bodyString responseClass:BaseResponse.class completion:completionBlock];
	}else{
		
		NSString *token = [[UserPreference getToken] encodeToPercentEscapeString];
		NSString *urlString =  [NSString stringWithFormat: @"%@?postID=%@&postType=%@&token=%@",kUrlFavorW,postID,postType,token];
		
		
		[self JSONFromURLWithString:urlString method:@"DELETE" params:nil bodyString:nil responseClass:BaseResponse.class completion:completionBlock];
	}
	
	
	
	
}



#pragma mark 赞 list
+(void)favorListWithPostID:(NSString*)postID
				  postType:(NSString*)postType
					lastID:(NSString*)lastID
					  size:(NSInteger)size
				completion:(EduApiBlock)completionBlock
{
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	
	[params setObject:[UserPreference getToken] forKey:@"token"];
	[params setObject:postID forKey:@"postID"];
	[params setObject:postType forKey:@"postType"];
	[params setObject:[NSString stringWithFormat:@"%ld",size] forKey:@"size"];
	[params setObject:lastID forKey:@"lastID"];
	[params setObject:@"1" forKey:@"ver"];
	
	NSString *bodyString = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
	
	NSString *urlString = kUrlFavorR ;
	NSLog(@"%s:%d :%@-%@",__func__,__LINE__,urlString,bodyString);
	
	
	[self JSONFromURLWithString:urlString method:kHTTPMethodPOST params:nil bodyString:bodyString responseClass:FavorListResponse.class completion:completionBlock];
	
}

#pragma mark 发表评论
+(void)commentPostWithContent:(NSString*)content
					 postType:(NSString*)postType
					   postID:(NSString*)postID
					  applyTo:(NSString*)applyTo
				   completion:(EduApiBlock)completionBlock
{
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	
	[params setObject:[UserPreference getToken] forKey:@"token"];
	[params setObject:postID forKey:@"postID"];
	[params setObject:postType forKey:@"postType"];
	[params setObject:content forKey:@"content"];
	
	NSString *bodyString = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
	
	NSString *urlString = kUrlCommentW ;
	
	
	
	[self JSONFromURLWithString:urlString method:kHTTPMethodPOST params:nil bodyString:bodyString responseClass:BaseResponse.class completion:completionBlock];
	
}

#pragma mark 评论列表
+(void)commentListWithPostID:(NSString*)postID
					postType:(NSString*)postType
					  lastID:(NSString*)lastID
						size:(NSInteger)size
				  completion:(EduApiBlock)completionBlock
{
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
	
	[params setObject:[UserPreference getToken] forKey:@"token"];
	[params setObject:postID forKey:@"postID"];
	[params setObject:postType forKey:@"postType"];
	[params setObject:[NSString stringWithFormat:@"%ld",size] forKey:@"size"];
	[params setObject:lastID forKey:@"lastID"];
	[params setObject:@"1" forKey:@"ver"];
	
	NSString *bodyString = [[NSString alloc]initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
	
	NSString *urlString = kUrlCommentR ;
	NSLog(@"%s:%d :%@-%@",__func__,__LINE__,urlString,bodyString);
	
	
	[self JSONFromURLWithString:urlString method:kHTTPMethodPOST params:nil bodyString:bodyString responseClass:CommentListResponse.class completion:completionBlock];
	
}

#pragma mark 删除评论
+(void)commentDeleteWithID:(NSString*)commentID
				  postType:(NSString*)postType
					postID:(NSString*)postID
				completion:(EduApiBlock)completionBlock
{
	
	NSString *token = [[UserPreference getToken] encodeToPercentEscapeString];
	NSString *urlString =  [NSString stringWithFormat: @"%@?id=%@&postID=%@&postType=%@&token=%@",kUrlCommentW,commentID,postID,postType,token];
	
	
	
	[self JSONFromURLWithString:urlString method:@"DELETE" params:nil bodyString:nil responseClass:BaseResponse.class completion:completionBlock];
	
	
	
}



#pragma mark ------------------------酒景-------------------------------

#pragma mark 教游列表
+(void)eduVolcationListWithViewController:(UIViewController*)viewController
							   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlEduVacationList] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[EduVacationListResponse class] completion:completionBlock];
	
}

#pragma mark 教游详情
+(void)eduVolcationWithId:(NSString*)vacationId
		   viewController:(UIViewController*)viewController
			   completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlEduVacation] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:vacationId forKey:@"id"];
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[EduVacationResponse class] completion:completionBlock];
	
}

#pragma mark 电子任务
+(void)eleArticleWithId:(NSString*)articleId
		 viewController:(UIViewController*)viewController
			 completion:(EduApiBlock)completionBlock
{
	NSString *urlString = [kServiceAPIHost stringByAppendingString: kUrlEleArticle] ;
	
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc]init] ;
	
	[params setObject:articleId forKey:@"id"];
	
	
	[self postJSONFromURLWithString:urlString params:params responseClass:[SocialArticleResponse class] completion:completionBlock];
	
}


#pragma mark -------------------------------------------------------


+(NSMutableDictionary*)getRequestHeaders{
	NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
	
	//    NSString *cookie =[UserPreference getCookie];
	//
	//    if (cookie) {
	//        [headers setObject:cookie forKey:@"Cookie"];
	//    }
	//
	//    [headers setObject:@"application/json; encoding=utf-8" forKey:@"Content-Type"];
	[headers setObject:@"application/json" forKey:@"Accept"];
	
	return  headers;
}

+(void)postJSONFromURLWithString:(NSString*)url params:(NSDictionary*)params responseClass:(Class)clazz completion:(EduApiBlock)completionBlock
{
	[self JSONFromURLWithString:url method:kHTTPMethodPOST params:params bodyString:nil responseClass:clazz completion:completionBlock];
}

+(void)getJSONFromURLWithString:(NSString*)url params:(NSDictionary*)params responseClass:(Class)clazz completion:(EduApiBlock)completionBlock
{
	[self JSONFromURLWithString:url method:kHTTPMethodGET params:params bodyString:nil  responseClass:clazz completion:completionBlock];
}

+(void)JSONFromURLWithString:(NSString*)url method:(NSString*)method params:(NSDictionary*)params bodyString:(NSString*)bodyString responseClass:(Class)clazz completion:(EduApiBlock)completionBlock
{
	//超时时间
	[JSONHTTPClient setTimeoutInSeconds:6];
	
	
	[JSONHTTPClient JSONFromURLWithString:url method:method params:params orBodyString:bodyString headers:[self getRequestHeaders] completion:^(id json, JSONModelError *err) {
		
		if (err) {
			NSLog(@"%s:%d :%@",__func__,__LINE__,[err description]);
		}else{
			NSLog(@"%s:%d :%@",__func__,__LINE__,json);
		}
		
		
		BaseResponse *response = NULL;
		if (err==nil&&json) {
			NSError *jsonError;
			response= [[clazz alloc]initWithDictionary:json error:&jsonError];
			if (jsonError) {
				NSLog(@"%s:%d :%@",__func__,__LINE__,[jsonError description]);
			}else{
				NSLog(@"%s:%d :%@",__func__,__LINE__,response);
			}
		}else{
			response = [[BaseResponse alloc] init];
			response.error = err;
		}
		
		[self completion:completionBlock response:response];
	}];
	
	
}


+(void)completion:(EduApiBlock)completionBlock response:(BaseResponse*)response
{
	BOOL isSuccess= [response isSuccess];
	
	if(isSuccess)
	{
		if(completionBlock)
		{
			completionBlock(YES, response);
		}
	}
	else
	{
		if ([response isTokenExpired])
		{
			//token过期
			NSLog(@"token过期");
			
			[[UserPreference sharedInstance]logout];
			
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"账号登陆信息已经过期，请重新登陆。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
			[alertView show];
			
			return;
		}
		
		//if(completionBlock&&completionBlock(NO, response))
		if(completionBlock)
		{
			//UI层处理异常
//			[response.error.userInfo setValue:@"网络异常，请检查网络" forKey:kErrorMessage];
			NSDictionary *dict = @{kErrorMessage : @"网络异常，请检查网络"};
			[response.error setValue:dict forKey:@"userInfo"];
			[response.error setValue:@"0" forKey:@"code"];
			completionBlock(NO, response);
		}
		else
		{
			
			NSString *msg = @"连接服务器失败，请稍后重试";
			if(response==nil)
			{
				if (![[Reachability reachabilityForInternetConnection] isReachable]) {
					
					//网络异常
					
					msg =@"网络异常，请检查网络";
					
				}else{
					
					//连接服务器出错
					
				}
				
			}else{
				
				if ([response isTokenExpired])
				{
					//token过期
					msg = @"账号登陆信息已经过期，请重新登陆。";
				}
				else if(response.message)
				{
					msg = response.message;
				}
			}
			
			
			
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
			[alertView show];
		}
	}
	
}
/*
#pragma mark --------------------------------------
#pragma mark http
+(void)httpGetRequestWithUrl:(NSString*)url
			  shouldRedirect:(BOOL)shouldRedirect
			  viewController:(UIViewController*)viewController
					 showHUD:(BOOL)showHUD
				  completion:(EduApiBlock)completionBlock
{
	if (showHUD&&viewController) {
		//show HUD
		[MyProgressDialog showHUDAddedTo:viewController.view];
	}
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"%@",url);
	
	ASIHTTPRequest *_request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
	
	//默认编码
	[_request setDefaultResponseEncoding:NSUTF8StringEncoding];
	
	__weak ASIHTTPRequest *request = _request;
	[request setUseCookiePersistence:NO];
	[request setTimeOutSeconds:60];
	
	
	request.shouldRedirect = shouldRedirect;//donot auto redirect
	
	[request setCompletionBlock:^{
		
		if (showHUD&&viewController) {
			//hide HUD
			[MBProgressHUD hideHUDForView:viewController.view animated:YES];
		}
		
		
		NSString *responseString = request.responseString;
		NSLog(@"responseString:%@",responseString);
		if (request.responseStatusCode == 200)
		{
			
		}
		else if(!shouldRedirect&&request.responseStatusCode == 302)
		{
			//donot auto redirect
			responseString = [request.responseHeaders valueForKey:@"Location"];
		}
		
		
		if (completionBlock) {
			completionBlock(YES,responseString);
		}
		
		
		
		
	}];
	[request setFailedBlock:^{
		if (showHUD&&viewController) {
			//hide HUD
			[MBProgressHUD hideHUDForView:viewController.view animated:YES];
		}
		
		if (completionBlock) {
			completionBlock(NO,nil);
		}
	}];
	
	[request startAsynchronous];
}
*/

@end
