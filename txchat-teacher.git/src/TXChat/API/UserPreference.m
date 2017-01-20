

#import "UserPreference.h"

#import "AppDelegate.h"
#import "Cache.h"

#define  PREFERENCE_NAME @"user_preference.plist"

/** 登录信息 */
/** 账号 */
#define  kKeyAccount @"UserAccount"


#define kKeyAccountChannel @"kKeyAccountChannel"
#define kKeyLoginResult @"LoginResult"
#define kKeySchoolAge @"schoolAge"
#define kKeyTaskKeywords @"kKeyTaskKeywords"
#define kKeyArticleKeywords @"kKeyArticleKeywords"

/** 介绍版本 */
/** 用户教育版本，有更新，升级kIntroduceVerson */
#define kIntroduceVerson @"1" //版本号1-v0.8
#define KEY_INTRODUCE_VERSION @"introduce_version"
#define NEED_INTRODUCE YES

/** 百度push */
#define  kKeyPushID @"pushid"

#define kKeyDeviceToken @"DeviceToken"

static UserPreference *instance;

@interface UserPreference()<UIAlertViewDelegate>
{
    
    
}
@end


@implementation UserPreference

+(UserPreference*)sharedInstance
{
    if (instance==nil)
    {
        instance = [[UserPreference alloc]init];
    }
    
    return instance;
}

-(void)logout
{
	//by sck
    //[[Cache sharedInstance] clear];
    
    [UserPreference setLoginResult:nil];
    [UserPreference setSchoolAge:nil];
	
	//[(AppDelegate*)[UIApplication sharedApplication].delegate launcherOverWithIntroduce:NO];
}

-(BOOL)checkLogin
{
    if ([UserPreference isLogin]) {
        return YES;
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"快去注册，享受更贴合宝宝特征的针对性教育帮助吧！" delegate:self cancelButtonTitle:@"稍后注册" otherButtonTitles:@"返回注册", nil];
    [alert show];
    
    return NO;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [self logout];
    }
}


-(void)setAccountChannel:(NSString *)value
{
    [UserPreference setObject:value forKey:kKeyAccountChannel];
}
-(NSString*)accountChannel
{
    return [UserPreference objectForKey:kKeyAccountChannel];
}


+(void) setAccount:(NSString*) value
{
    [self setObject:value forKey:kKeyAccount];
}

+ (NSString*) getAccount
{
    if ([self isLogin])
    {
        return [self getLoginResult].userName;
    }
    return [self objectForKey:kKeyAccount];
}


/** 是否已经登录 */
+(BOOL) isLogin
{
    if ([self getToken]) {
        return YES;
    }
    return NO;
}


+(void) setLoginResult:(LoginResult *)result
{
    if (result) {
//        result.province.cities=nil;
//        result.city.districts=nil;
        NSString *json = [result toJSONString];
        [self setObject:json forKey:kKeyLoginResult];

    }
    else
    {
        [self setObject:nil forKey:kKeyLoginResult];
    }
}
+(LoginResult*)getLoginResult
{
    NSString *json = [self objectForKey:kKeyLoginResult];
    if (json) {
        return [[LoginResult alloc]initWithString:json error:nil];
    }
    return nil;
}

+(NSString*) getToken
{
//    LoginResult *result = [self getLoginResult];
//    if (result) {
//        return result.token;
//    }
//    return nil;
	return [[TXChatClient sharedInstance] getCurrentUserToken];
}

 


+(id)objectForKey:(id)key
{
    NSString *myFile = [self getFile];
    
    //读取文件
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:myFile];
    
    return [dic objectForKey:key];
}

+ (void) setObject:(id)value forKey:(id<NSCopying>)key
{
    
    //    value cannot be NSMutableArray
    if ([value isKindOfClass:[NSMutableArray class]]) {
        value = [NSArray arrayWithArray:value];
    }
    
    NSString *myFile = [self getFile];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithContentsOfFile:myFile];
    if (dic==nil) {
        dic = [[NSMutableDictionary alloc]init];
    }
    
    if(value){
        // dictionary setObject:nil 会crash
        [dic setObject:value forKey:key];
    }else{
        [dic removeObjectForKey:key ];
        
    }
    [ dic  writeToFile:myFile atomically:YES];
}

+ (NSString *)getFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    //    NSLog(docPath,nil);
    
    NSString *myFile = [docPath stringByAppendingPathComponent:PREFERENCE_NAME];
    return myFile;
}

/** 是否需要介绍 */
+(BOOL)isNeedIntroduce
{
    if (!NEED_INTRODUCE) {
        return NO;
    }
    
    NSString *currentVersion = kIntroduceVerson;
    
    NSString *introduceVersion = [self objectForKey:KEY_INTRODUCE_VERSION];
    if (introduceVersion&&[introduceVersion isEqualToString:currentVersion]) {
        return NO;
    }
    
    [self setObject:currentVersion forKey:KEY_INTRODUCE_VERSION];
    return YES;
}


+(void) setPusid:(NSString*) value
{
    [self setObject:value forKey: kKeyPushID];
}

+(NSString*) getPushid
{
    return [self objectForKey:kKeyPushID];
}

+(void) setDeviceToken:(NSString*) value
{
    [self setObject:value forKey: kKeyDeviceToken];
}

+(NSString*) getDeviceToken
{
    return [self objectForKey:kKeyDeviceToken];
}


+(SchoolAgeInfo *)getSchoolAge
{
    
    NSString *json = [self objectForKey:kKeySchoolAge];
    
    if (json)
    {
        return [[SchoolAgeInfo alloc]initWithString:json error:nil];
    }
    
    return nil;
    
}

+(void)setSchoolAge:(SchoolAgeInfo *)value
{
    
    NSString *json = [value toJSONString];
    [self setObject:json forKey:kKeySchoolAge];
    
    
}

+(NSArray *)getTaskKeywords
{
    
    return  [self objectForKey:kKeyTaskKeywords];
   
}

+(void)addTaskKeyword:(NSString *)value
{
    
    NSArray *array = [self getTaskKeywords];
    
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    
    if (value)
    {
        [mArray addObject:value];
    }
    
    if (array)
    {
        for (NSString* string in array)
        {
            if (![string isEqualToString:value])
            {
                [mArray addObject:string];
            }
        }
    }
    
   
    [self setObject:mArray forKey:kKeyTaskKeywords];
    
    
}


+(void)clearTaskKeywords
{
    [self setObject:nil forKey:kKeyTaskKeywords];
}


+(NSArray *)getArticleKeywords
{
    
    return  [self objectForKey:kKeyArticleKeywords];
    
}

+(void)addArticleKeyword:(NSString *)value
{
    
    NSArray *array = [self getArticleKeywords];
    
    NSMutableArray *mArray = [[NSMutableArray alloc]init];
    
    if (value)
    {
        [mArray addObject:value];
    }
    
    if (array)
    {
        for (NSString* string in array)
        {
            if (![string isEqualToString:value])
            {
                [mArray addObject:string];
            }
        }
    }
    
    
    [self setObject:mArray forKey:kKeyArticleKeywords];
    
    
}


+(void)clearArticleKeywords
{
    [self setObject:nil forKey:kKeyArticleKeywords];
}



@end
