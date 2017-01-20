

#import <Foundation/Foundation.h>

#import "LoginResult.h"
#import "SchoolAgeInfo.h"

@interface UserPreference : NSObject


+(UserPreference*)sharedInstance;

-(void)logout;

/** 账号类型 */
@property (nonatomic) NSString* accountChannel;


/** 随便逛逛，弹框 */
-(BOOL)checkLogin;


+(void) setAccount:(NSString*) value;
+(NSString*) getAccount;

+(NSString*) getToken;

+(void)setLoginResult:(LoginResult*)result;
+(LoginResult*)getLoginResult;


/** 是否已经登录 */
+(BOOL) isLogin;

+(BOOL)isNeedIntroduce;

+(void) setPusid:(NSString*) value;
+(NSString*) getPushid;

+(void) setDeviceToken:(NSString*) value;

+(NSString*) getDeviceToken;


+(SchoolAgeInfo*)getSchoolAge;
+(void)setSchoolAge:(SchoolAgeInfo*)value;

+(NSArray*)getTaskKeywords;
+(void)addTaskKeyword:(NSString*)value;
+(void)clearTaskKeywords;

+(NSArray*)getArticleKeywords;
+(void)addArticleKeyword:(NSString*)value;
+(void)clearArticleKeywords;


@end
