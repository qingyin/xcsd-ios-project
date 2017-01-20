

#import "BaseRequest.h"

#define kShareUrlTypeTestEvaluation @"1"
#define kShareUrlTypeTask @"2"
#define kShareUrlTypeTaskDiary @"3"
#define kShareUrlTypeDiary @"4"
#define kShareUrlTypeDownload @"5"
#define kShareUrlTypeTest @"6"
#define kShareUrlTypeArticle @"7"
#define kShareUrlTypeVacation @"8"
#define kShareUrlTypeEleArticle @"9"

#define kShareUrlCHSina @"1"
#define kShareUrlCHWechatTimeline @"2"
#define kShareUrlCHWechatSession @"3"
#define kShareUrlCHSMS @"4"



@interface GetShareUrlRequest : BaseRequest

@property NSString* childID;

@property NSString* type;
@property NSString* taskID;
@property NSString* testID;
@property NSString* socialArticleID;
@property NSString* eduVacationID;
@property NSString* eleArticleID;

@property NSString* ver;
@property NSString* ch;


//参数	类型	说明
//token	string	用户唯一标示
//ver	byte	版本，最新版本为1
//type	byte	分享类型 1.测试结果 2.任务 3.任务日记 4非任务日记,5. 推荐下载
//ch	byte	分享渠道：1 新浪微博, 2. 微信朋友圈 3. 微信好友 4 短信推荐
//childID（可选）	int	孩子ID
//childTaskID（可选）	int	孩子任务ID， type为2、3时传此参数
//testID（可选）	int	测试ID ,type为1时传此参数。
@end
